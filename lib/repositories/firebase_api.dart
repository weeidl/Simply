import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseApi();

  Future<User?> get currentUser async => _auth.currentUser;

  String? get userId => _auth.currentUser?.uid;

  // Future<DocumentSnapshot> get(String path) async {
  //   return await _firestore.doc(path).get();
  // }

  Future<QuerySnapshot> getList(String path) async {
    return await _firestore.collection(path).get();
  }

  Future<QuerySnapshot> getListId(String path) async {
    return await _firestore
        .collection(path)
        .where(userId.toString(), isEqualTo: userId)
        .get();
  }

  Future<DocumentReference> documentReference(String path, [String? id]) async {
    final documentReference = _firestore.collection(path).doc(id ?? userId);
    return documentReference;
  }

  Future<CollectionReference<Map<String, dynamic>>> itemsBackend(
    String path,
  ) async {
    final documentReference =
        _firestore.collection(path).doc(userId).collection('items');
    return documentReference;
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(uid).get();
    return snapshot.data() as Map<String, dynamic>?;
  }

  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
