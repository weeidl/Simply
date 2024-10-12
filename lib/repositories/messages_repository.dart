import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_forward_app/models/paginated_response.dart';
import 'package:sms_forward_app/repositories/firebase_api.dart';
import 'package:sms_forward_app/models/messages.dart';
import '../models/message.dart';

class MessagesRepository {
  final FirebaseApi _firebaseApi = FirebaseApi();
  static const _url = "user_messages";
  static const _messages = "messages";
  static const _message = "message";

  Future<PaginatedResponse<Messages>> fetchMessages({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final documentReference = _firebaseApi.documentReference(_url);
    final collection = documentReference.collection(_messages);

    final response = await _firebaseApi.fetchPaginatedData(
      collection: collection,
      fromJson: (data) => Messages.fromJson(data[_messages]),
      limit: limit,
      startAfter: startAfter,
      orderByField: 'messages.last_message_date',
    );

    return response;
  }

  Future<PaginatedResponse<MessageDetails>> fetchMessage(
    String id, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final documentReference = _firebaseApi.documentReference(_url);
    final collection =
        documentReference.collection(_message).doc('items').collection(id);

    final response = await _firebaseApi.fetchPaginatedData(
      collection: collection,
      fromJson: (data) => MessageDetails.fromJson(data),
      limit: limit,
      // descending: false,
      startAfter: startAfter,
      orderByField: 'date',
    );

    return response;
  }

  Future<void> update(String id, String title) async {
    final documentReference = _firebaseApi.documentReference(_url);
    DocumentReference docRef =
        documentReference.collection(_messages).doc(title);

    await _setData(
      docRef: docRef,
      data: {
        _messages: {"unread_messages_count": 0},
      },
    );
  }

  Future<void> sendMessageFirebase({
    required MessageDetails messageTitle,
    required Messages messages,
  }) async {
    final documentReference = _firebaseApi.documentReference(_url);

    // Обновляем информацию о сообщениях
    DocumentReference docRef =
        documentReference.collection(_messages).doc(messages.title);
    await _setData(
      docRef: docRef,
      data: {
        _messages: messages.toJson(),
      },
    );

    // Добавляем новое сообщение в коллекцию
    CollectionReference messagesCollection = documentReference
        .collection(_message)
        .doc('items')
        .collection(messages.id);
    await messagesCollection.add(messageTitle.toJson());
  }

  Future<void> _setData({
    required DocumentReference docRef,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await docRef.set(data, SetOptions(merge: merge));
  }
}
