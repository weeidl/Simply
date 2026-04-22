import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/models/paginated_response.dart';

class FirebaseApi {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseApi({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  String? get userId => _auth.currentUser?.uid;

  FirebaseFirestore get firestore => _firestore;

  String requireUserId() {
    final uid = userId;
    if (uid == null || uid.isEmpty) {
      throw StateError('User is not logged in.');
    }
    return uid;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String path) async {
    try {
      return await _firestore.doc(path).get();
    } catch (e) {
      throw Exception("Failed to fetch document: $e");
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getList(
      String collectionPath) async {
    try {
      final querySnapshot = await _firestore.collection(collectionPath).get();
      return querySnapshot.docs;
    } catch (e) {
      throw Exception("Failed to fetch documents: $e");
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getListForUser(
      String collectionPath) async {
    final uid = userId;
    if (uid == null) throw StateError('User is not logged in.');

    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: uid)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      throw Exception("Failed to fetch user's documents: $e");
    }
  }

  DocumentReference<Map<String, dynamic>> documentReference(
    String path, [
    String? documentId,
  ]) {
    return _firestore.collection(path).doc(documentId ?? requireUserId());
  }

  CollectionReference<Map<String, dynamic>> itemsCollection(String path) {
    final uid = userId;
    if (uid == null) throw StateError('User is not logged in.');
    return _firestore.collection(path).doc(uid).collection('items');
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      return snapshot.data();
    } catch (e) {
      throw Exception("Failed to fetch user data: $e");
    }
  }

  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to set user data: $e");
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<PaginatedResponse<T>> fetchPaginatedData<T>({
    required CollectionReference collection,
    required T Function(Map<String, dynamic> data) fromJson,
    required int limit,
    DocumentSnapshot? startAfter,
    required String orderByField,
    bool descending = true,
  }) async {
    Query query = collection.orderBy(orderByField, descending: descending);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    query = query.limit(limit);

    final response = await query.get();

    final items = response.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return fromJson(data);
    }).toList();

    final lastDoc =
        response.docs.isNotEmpty ? response.docs.last : null;

    return PaginatedResponse<T>(items: items, lastDocument: lastDoc);
  }
}
