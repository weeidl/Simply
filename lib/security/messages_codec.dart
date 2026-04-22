import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/models/message.dart';
import 'package:simply/security/crypto_service.dart';
import 'package:simply/security/encrypted_value.dart';

class MessagesCodec {
  static const schemaVersion = 2;

  final CryptoService _cryptoService;

  MessagesCodec({CryptoService? cryptoService})
      : _cryptoService = cryptoService ?? CryptoService();

  Future<Map<String, dynamic>> encodeConversation({
    required Conversation conversation,
    required List<int> masterKey,
  }) async {
    final encryptedTitle = await _cryptoService.encryptString(
      plaintext: conversation.title,
      masterKey: masterKey,
    );
    final encryptedLastMessage = await _cryptoService.encryptString(
      plaintext: conversation.lastMessage,
      masterKey: masterKey,
    );
    final conversationId = _cryptoService.conversationIdForSender(
      sender: conversation.title,
      masterKey: masterKey,
    );

    return {
      'id': conversationId,
      'schema_version': schemaVersion,
      'is_encrypted': true,
      'encrypted_title': encryptedTitle.toJson(),
      'encrypted_last_message': encryptedLastMessage.toJson(),
      'last_message_date':
          Timestamp.fromDate(conversation.lastMessageDate.toUtc()),
      'unread_messages_count': conversation.unreadMessagesCount,
    };
  }

  Future<Conversation> decodeConversation(
    Map<String, dynamic> raw, {
    required List<int>? masterKey,
  }) async {
    final encryptedTitle = raw['encrypted_title'];
    final encryptedLastMessage = raw['encrypted_last_message'];

    if (encryptedTitle is Map && encryptedLastMessage is Map) {
      if (masterKey == null) {
        throw StateError('Master key is required for encrypted conversation.');
      }

      return Conversation(
        id: raw['id']?.toString() ?? '',
        title: await _cryptoService.decryptString(
          value: EncryptedValue.fromJson(
            Map<String, dynamic>.from(encryptedTitle),
          ),
          masterKey: masterKey,
        ),
        lastMessage: await _cryptoService.decryptString(
          value: EncryptedValue.fromJson(
            Map<String, dynamic>.from(encryptedLastMessage),
          ),
          masterKey: masterKey,
        ),
        unreadMessagesCount:
            (raw['unread_messages_count'] as num?)?.toInt() ?? 0,
        lastMessageDate: _readDate(raw['last_message_date']),
      );
    }

    return Conversation.fromJson(raw);
  }

  Future<Map<String, dynamic>> encodeMessage({
    required Message message,
    required List<int> masterKey,
  }) async {
    final encryptedText = await _cryptoService.encryptString(
      plaintext: message.text,
      masterKey: masterKey,
    );

    return {
      'schema_version': schemaVersion,
      'is_encrypted': true,
      'encrypted_text': encryptedText.toJson(),
      'date': Timestamp.fromDate(message.date.toUtc()),
    };
  }

  Future<Message> decodeMessage(
    Map<String, dynamic> raw, {
    required List<int>? masterKey,
  }) async {
    final encryptedText = raw['encrypted_text'];

    if (encryptedText is Map) {
      if (masterKey == null) {
        throw StateError('Master key is required for encrypted message.');
      }

      return Message(
        text: await _cryptoService.decryptString(
          value: EncryptedValue.fromJson(
            Map<String, dynamic>.from(encryptedText),
          ),
          masterKey: masterKey,
        ),
        date: _readDate(raw['date']),
      );
    }

    return Message.fromJson(raw);
  }

  static DateTime _readDate(dynamic rawValue) {
    if (rawValue is Timestamp) {
      return rawValue.toDate();
    }
    if (rawValue is DateTime) {
      return rawValue;
    }
    if (rawValue is String) {
      return DateTime.tryParse(rawValue) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
