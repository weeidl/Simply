import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_forward_app/repositories/firebase_api.dart';
import 'package:sms_forward_app/models/messages.dart';

import '../models/message.dart';

class MessagesRepository {
  final FirebaseApi _firebaseApi = FirebaseApi();
  static const _url = "user_messages";
  static const _messages = "messages";
  static const _message = "message";

  Future<List<Messages>> fetchMessages() async {
    final documentReference = await _firebaseApi.documentReference(_url);

    final response = await documentReference.collection(_messages).get();

    List<Messages> messagesWithTitles = response.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      return Messages.fromJson(data[_messages]);
    }).toList();

    messagesWithTitles.sort((a, b) {
      return b.lastMessageDate.compareTo(a.lastMessageDate);
    });

    return messagesWithTitles;
  }

  Future<List<MessageThread>> fetchMessage(String id) async {
    final documentSnapshot = await _firebaseApi.documentReference(_url);

    final messagesDocument =
        documentSnapshot.collection(_message).doc('items').collection(id);

    final response = await messagesDocument.get();

    List<MessageThread> messagesWithTitles = response.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      return MessageThread.fromJson(data);
    }).toList();

    return messagesWithTitles;
  }

  Future<void> update(String id, String title) async {
    final documentSnapshot = await _firebaseApi.documentReference(_url);

    DocumentReference docRef =
        documentSnapshot.collection(_messages).doc(title);

    await docRef.set(
      {
        _messages: {"unread_messages_count": 0},
      },
      SetOptions(merge: true),
    );
  }

  Future<void> sendMessageFirebase({
    required MessageThread messageTitle,
    required Messages messages,
  }) async {
    final documentSnapshot = await _firebaseApi.documentReference(_url);

    DocumentReference docRef =
        documentSnapshot.collection(_messages).doc(messages.title);

    await docRef.set(
      {
        _messages: messages.toJson(),
      },
      SetOptions(merge: true),
    );

    CollectionReference messagesCollection = documentSnapshot
        .collection(_message)
        .doc('items')
        .collection(messages.id);

    await messagesCollection.add(messageTitle.toJson());
  }
}
