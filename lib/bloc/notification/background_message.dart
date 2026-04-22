import 'package:another_telephony/telephony.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/models/message.dart';
import 'package:simply/repositories/firebase_api.dart';
import 'package:simply/repositories/messages_repository.dart';

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

  final firebaseApi = FirebaseApi(auth: FirebaseAuth.instance);
  final repository = MessagesRepository(firebaseApi: firebaseApi);

  try {
    await repository.saveIncomingMessage(
      conversation: Conversation.fromSms(msg),
      message: Message.fromSms(msg),
    );
  } catch (_) {
    // The app can safely skip the write here when the encryption key is not
    // available yet. This avoids leaking plaintext to Firestore.
  }
}
