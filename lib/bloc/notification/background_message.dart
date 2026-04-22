import 'package:another_telephony/telephony.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:simply/models/message.dart';
import 'package:simply/models/messages.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(SmsMessage msg) async {
  await Firebase.initializeApp();

  // Background isolate starts with no Dart-side auth state. Wait for the
  // native SDK to hydrate currentUser before touching Firestore, otherwise
  // writes land under user_messages/null/... and the app never sees them.
  var user = FirebaseAuth.instance.currentUser;
  user ??= await FirebaseAuth.instance
      .authStateChanges()
      .firstWhere((u) => u != null)
      .timeout(const Duration(seconds: 5), onTimeout: () => null);

  if (user == null) return;

  final messages = Messages.updateFireStore(msg);
  final messageTitle = MessageDetails.updateFireStore(msg);

  final userDoc =
      FirebaseFirestore.instance.collection('user_messages').doc(user.uid);

  await userDoc.collection('messages').doc(messages.title).set({
    'messages': {
      ...messages.toJson(),
      'unread_messages_count': FieldValue.increment(1),
    },
  }, SetOptions(merge: true));

  await userDoc
      .collection('message')
      .doc('items')
      .collection(messages.id)
      .add(messageTitle.toJson());
}
