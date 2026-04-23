import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/models/message.dart';
import 'package:simply/repositories/firebase_api.dart';
import 'package:simply/security/encryption_readiness.dart';
import 'package:simply/security/messages_codec.dart';
import 'package:simply/security/security_repository.dart';

class MessagesRepository {
  final FirebaseApi _firebaseApi;
  final SecurityRepository _securityRepository;
  final MessagesCodec _messagesCodec;

  static const _url = "user_messages";
  static const _messages = "messages";
  static const _message = "message";
  static const _devices = "devices";

  MessagesRepository({
    FirebaseApi? firebaseApi,
    SecurityRepository? securityRepository,
    MessagesCodec? messagesCodec,
  })  : _firebaseApi = firebaseApi ?? FirebaseApi(),
        _securityRepository = securityRepository ?? SecurityRepository(),
        _messagesCodec = messagesCodec ?? MessagesCodec();

  Query<Map<String, dynamic>> _conversationsQuery() {
    return _userDocument()
        .collection(_messages)
        .orderBy('messages.last_message_date', descending: true);
  }

  Query<Map<String, dynamic>> _messagesQuery(String conversationId) {
    return _messagesCollection(conversationId)
        .orderBy('date', descending: true);
  }

  DocumentReference<Map<String, dynamic>> _userDocument() {
    return _firebaseApi.documentReference(_url);
  }

  CollectionReference<Map<String, dynamic>> _messagesCollection(
    String conversationId,
  ) {
    return _userDocument()
        .collection(_message)
        .doc('items')
        .collection(conversationId);
  }

  Future<List<Conversation>> getConversations() async {
    final snapshot = await _conversationsQuery().get();
    return _decodeConversations(snapshot.docs);
  }

  Stream<List<Conversation>> watchConversations() {
    return _conversationsQuery()
        .snapshots()
        .asyncMap((snapshot) => _decodeConversations(snapshot.docs));
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final snapshot = await _messagesQuery(conversationId).get();
    return _decodeMessages(snapshot.docs);
  }

  Stream<List<Message>> watchMessages(String conversationId) {
    return _messagesQuery(conversationId)
        .snapshots()
        .asyncMap((snapshot) => _decodeMessages(snapshot.docs));
  }

  /// Resets the unread counter for a conversation when the user opens it.
  Future<void> markConversationRead(String conversationId) async {
    final docRef = _userDocument().collection(_messages).doc(conversationId);

    await docRef.set(
      {
        _messages: {'unread_messages_count': 0},
      },
      SetOptions(merge: true),
    );
  }

  /// Persists an incoming SMS: updates the conversation preview and appends
  /// the message body inside a Firestore transaction so both writes land
  /// together.
  Future<void> saveIncomingMessage({
    required Message message,
    required Conversation conversation,
  }) async {
    final masterKey = await _securityRepository.requireEncryptionReady();
    final previewPayload = await _buildConversationPayload(
      conversation: conversation,
      masterKey: masterKey,
    );
    final conversationId = previewPayload['id']?.toString().isNotEmpty == true
        ? previewPayload['id'].toString()
        : conversation.id;
    final messagePayload = await _buildMessagePayload(
      message: message,
      masterKey: masterKey,
    );

    final previewRef =
        _userDocument().collection(_messages).doc(conversationId);
    final messageRef = _messagesCollection(conversationId).doc();
    final sourceDeviceId =
        message.sourceDeviceId ?? conversation.sourceDeviceId;
    final deviceRef = sourceDeviceId == null || sourceDeviceId.isEmpty
        ? null
        : _firebaseApi.itemsCollection(_devices).doc(sourceDeviceId);

    await _firebaseApi.firestore.runTransaction((transaction) async {
      transaction.set(
        previewRef,
        {
          _messages: {
            ..._sanitizeEncryptedConversationPayload(previewPayload),
            'id': conversationId,
            'unread_messages_count': FieldValue.increment(1),
            'last_message_date': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          },
        },
        SetOptions(merge: true),
      );
      transaction.set(
        messageRef,
        {
          ...messagePayload,
          'date': FieldValue.serverTimestamp(),
        },
      );

      if (deviceRef != null) {
        final snapshot = await transaction.get(deviceRef);
        final nextStats = _nextDeviceStats(
          existing: snapshot.data() ?? const <String, dynamic>{},
          messageDate: message.date,
        );
        transaction.set(deviceRef, nextStats, SetOptions(merge: true));
      }
    });
  }

  Future<void> migrateLegacyDataIfNeeded() async {
    final hasRemoteEnvelope = await _securityRepository.hasRemoteEnvelope();
    final masterKey = await _securityRepository.readMasterKey();

    if (!EncryptionReadiness.isReady(
      hasRemoteEnvelope: hasRemoteEnvelope,
      hasLocalMasterKey: masterKey != null,
    )) {
      return;
    }
    final encryptionKey = masterKey!;

    final previewSnapshot = await _conversationsQuery().get();
    for (final previewDoc in previewSnapshot.docs) {
      final previewPayload = _conversationPayload(previewDoc.data());
      final legacyConversation = await _messagesCodec.decodeConversation(
        previewPayload,
        masterKey: encryptionKey,
      );
      final encryptedPreview = await _messagesCodec.encodeConversation(
        conversation: legacyConversation,
        masterKey: encryptionKey,
      );
      final targetConversationId =
          encryptedPreview['id']?.toString() ?? previewDoc.id;
      final previewNeedsMigration = !_isEncryptedConversation(previewPayload) ||
          previewDoc.id != targetConversationId;

      final messageSnapshot = await _messagesCollection(previewDoc.id).get();
      final messageWrites = <Map<String, dynamic>>[];
      var messagesNeedMigration = previewDoc.id != targetConversationId;

      for (final messageDoc in messageSnapshot.docs) {
        final rawMessage = _messagePayload(messageDoc.data());
        if (!_isEncryptedMessage(rawMessage)) {
          messagesNeedMigration = true;
        }

        final decodedMessage = await _messagesCodec.decodeMessage(
          rawMessage,
          masterKey: encryptionKey,
        );
        final encryptedMessage = await _messagesCodec.encodeMessage(
          message: decodedMessage,
          masterKey: encryptionKey,
        );
        encryptedMessage['date'] = _coerceTimestamp(
          rawMessage['date'],
          fallback: encryptedMessage['date'],
        );

        messageWrites.add(
          {
            'id': messageDoc.id,
            'payload': encryptedMessage,
          },
        );
      }

      if (!previewNeedsMigration && !messagesNeedMigration) {
        continue;
      }

      final targetPreviewRef =
          _userDocument().collection(_messages).doc(targetConversationId);

      await targetPreviewRef.set(
        {
          _messages: {
            ..._sanitizeEncryptedConversationPayload(encryptedPreview),
            'id': targetConversationId,
            'last_message_date': _coerceTimestamp(
              previewPayload['last_message_date'],
              fallback: encryptedPreview['last_message_date'],
            ),
            'unread_messages_count':
                (previewPayload['unread_messages_count'] as num?)?.toInt() ?? 0,
            'updated_at': FieldValue.serverTimestamp(),
          },
        },
        SetOptions(merge: true),
      );

      for (final messageWrite in messageWrites) {
        await _messagesCollection(targetConversationId)
            .doc(messageWrite['id'] as String)
            .set(Map<String, dynamic>.from(messageWrite['payload'] as Map));
      }

      if (previewDoc.id != targetConversationId) {
        for (final messageDoc in messageSnapshot.docs) {
          await messageDoc.reference.delete();
        }
        await previewDoc.reference.delete();
      }
    }
  }

  Future<List<Conversation>> _decodeConversations(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final masterKey = await _securityRepository.readMasterKey();

    return Future.wait(
      docs.map(
        (doc) => _messagesCodec.decodeConversation(
          _conversationPayload(doc.data()),
          masterKey: masterKey,
        ),
      ),
    );
  }

  Future<List<Message>> _decodeMessages(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final masterKey = await _securityRepository.readMasterKey();

    return Future.wait(
      docs.map(
        (doc) => _messagesCodec.decodeMessage(
          _messagePayload(doc.data()),
          masterKey: masterKey,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _buildConversationPayload({
    required Conversation conversation,
    required List<int> masterKey,
  }) async {
    return _messagesCodec.encodeConversation(
      conversation: conversation,
      masterKey: masterKey,
    );
  }

  Future<Map<String, dynamic>> _buildMessagePayload({
    required Message message,
    required List<int> masterKey,
  }) async {
    return _messagesCodec.encodeMessage(
      message: message,
      masterKey: masterKey,
    );
  }

  Map<String, dynamic> _conversationPayload(Map<String, dynamic> data) {
    final raw = data[_messages] ?? data;
    return Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
  }

  Map<String, dynamic> _messagePayload(Map<String, dynamic> data) {
    return Map<String, dynamic>.from(data);
  }

  bool _isEncryptedConversation(Map<String, dynamic> payload) {
    return payload['encrypted_title'] is Map &&
        payload['encrypted_last_message'] is Map;
  }

  bool _isEncryptedMessage(Map<String, dynamic> payload) {
    return payload['encrypted_text'] is Map;
  }

  Map<String, dynamic> _sanitizeEncryptedConversationPayload(
    Map<String, dynamic> payload,
  ) {
    return {
      ...payload,
      'title': FieldValue.delete(),
      'last_message': FieldValue.delete(),
    };
  }

  Map<String, dynamic> _nextDeviceStats({
    required Map<String, dynamic> existing,
    required DateTime messageDate,
  }) {
    final local = messageDate.toLocal();
    final dayKey = _dayKey(local);
    final rawSparkline = existing['today_sparkline'];
    final sparkline = rawSparkline is Iterable
        ? rawSparkline.map((value) => (value as num?)?.toInt() ?? 0).toList()
        : List<int>.filled(6, 0);
    final normalizedSparkline = sparkline.length == 6
        ? List<int>.from(sparkline)
        : List<int>.filled(6, 0);
    final existingDay = existing['today_sparkline_day']?.toString();
    final sameDay = existingDay == dayKey;
    final nextSparkline =
        sameDay ? normalizedSparkline : List<int>.filled(6, 0);
    final bucketIndex = ((local.hour.clamp(0, 23) * 6) / 24).floor();
    nextSparkline[bucketIndex] = nextSparkline[bucketIndex] + 1;

    return {
      'today_message_count':
          (sameDay ? (existing['today_message_count'] as num?)?.toInt() : 0)! +
              1,
      'today_sparkline': nextSparkline,
      'today_sparkline_day': dayKey,
      'last_message_at': Timestamp.fromDate(messageDate.toUtc()),
    };
  }

  String _dayKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  dynamic _coerceTimestamp(dynamic rawValue, {required dynamic fallback}) {
    if (rawValue is Timestamp) {
      return rawValue;
    }
    if (rawValue is DateTime) {
      return Timestamp.fromDate(rawValue.toUtc());
    }
    if (rawValue is String) {
      final parsed = DateTime.tryParse(rawValue);
      if (parsed != null) {
        return Timestamp.fromDate(parsed.toUtc());
      }
    }
    return fallback;
  }
}
