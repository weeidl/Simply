import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/models/paginated_response.dart';
import 'package:simply/repositories/firebase_api.dart';
import 'package:simply/models/messages.dart';
import '../models/message.dart';

class MessagesRepository {
  final FirebaseApi _firebaseApi;
  static const _url = "user_messages";
  static const _messages = "messages";
  static const _message = "message";

  MessagesRepository({FirebaseApi? firebaseApi})
      : _firebaseApi = firebaseApi ?? FirebaseApi();

  Future<PaginatedResponse<Messages>> fetchMessages({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final documentReference = _firebaseApi.documentReference(_url);
    final collection = documentReference.collection(_messages);

    return _firebaseApi.fetchPaginatedData(
      collection: collection,
      fromJson: (data) => Messages.fromJson(data[_messages] ?? data),
      limit: limit,
      startAfter: startAfter,
      orderByField: 'messages.last_message_date',
    );
  }

  Future<PaginatedResponse<MessageDetails>> fetchMessage(
    String id, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final documentReference = _firebaseApi.documentReference(_url);
    final collection =
        documentReference.collection(_message).doc('items').collection(id);

    return _firebaseApi.fetchPaginatedData(
      collection: collection,
      fromJson: (data) => MessageDetails.fromJson(data),
      limit: limit,
      startAfter: startAfter,
      orderByField: 'date',
    );
  }

  /// Resets the unread counter for a conversation when the user opens it.
  Future<void> markConversationRead(String title) async {
    final documentReference = _firebaseApi.documentReference(_url);
    final docRef = documentReference.collection(_messages).doc(title);

    await docRef.set(
      {
        _messages: {'unread_messages_count': 0},
      },
      SetOptions(merge: true),
    );
  }

  /// Persists an incoming SMS: updates the conversation preview and appends
  /// the message body. The unread counter is incremented atomically via
  /// [FieldValue.increment] so the client never races with other writers.
  Future<void> sendMessageFirebase({
    required MessageDetails messageTitle,
    required Messages messages,
  }) async {
    final documentReference = _firebaseApi.documentReference(_url);

    final previewRef =
        documentReference.collection(_messages).doc(messages.title);

    await previewRef.set(
      {
        _messages: {
          ...messages.toJson(),
          'unread_messages_count': FieldValue.increment(1),
        },
      },
      SetOptions(merge: true),
    );

    final messagesCollection = documentReference
        .collection(_message)
        .doc('items')
        .collection(messages.id);

    await messagesCollection.add(messageTitle.toJson());
  }
}
