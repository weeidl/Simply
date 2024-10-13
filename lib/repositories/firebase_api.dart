import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/models/paginated_response.dart';

class FirebaseApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _cachedUser;

  FirebaseApi();

  /// Retrieve the current authenticated user (caching to avoid repeated fetches)
  Future<User?> get currentUser async {
    _cachedUser ??= _auth.currentUser;
    return _cachedUser;
  }

  /// Fetch the current user's ID. Returns null if no user is logged in.
  String? get userId => _auth.currentUser?.uid;

  /// Get a Firestore document as a snapshot for a given path.
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String path) async {
    try {
      return await _firestore.doc(path).get();
    } catch (e) {
      throw Exception("Failed to fetch document: $e");
    }
  }

  /// Fetch a list of documents from a given Firestore collection.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getList(
      String collectionPath) async {
    try {
      final querySnapshot = await _firestore.collection(collectionPath).get();
      return querySnapshot.docs;
    } catch (e) {
      throw Exception("Failed to fetch documents: $e");
    }
  }

  /// Fetch a list of documents for a specific user based on their user ID.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getListForUser(
      String collectionPath) async {
    if (userId == null) throw Exception("User is not logged in.");

    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      throw Exception("Failed to fetch user's documents: $e");
    }
  }

  /// Get a reference to a document by path and optional document ID.
  DocumentReference<Map<String, dynamic>> documentReference(
    String path, [
    String? documentId,
  ]) {
    return _firestore.collection(path).doc(documentId ?? userId);
  }

  /// Get a collection reference under a user's document.
  CollectionReference<Map<String, dynamic>> itemsCollection(String path) {
    if (userId == null) throw Exception("User is not logged in.");
    return _firestore.collection(path).doc(userId).collection('items');
  }

  /// Fetch the data of a specific user by their UID.
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      return snapshot.data();
    } catch (e) {
      throw Exception("Failed to fetch user data: $e");
    }
  }

  /// Set user data for a specific UID.
  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).set(data);
    } catch (e) {
      throw Exception("Failed to set user data: $e");
    }
  }

  /// Sign in using email and password, with error handling.
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _cachedUser =
          userCredential.user; // Update cached user on successful sign-in
      return userCredential;
    } catch (e) {
      throw Exception("Failed to sign in: $e");
    }
  }

  /// Sign out the current user and clear cached data.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _cachedUser = null; // Clear the cached user
    } catch (e) {
      throw Exception("Failed to sign out: $e");
    }
  }

  Future<PaginatedResponse<T>> fetchPaginatedData<T>({
    required CollectionReference collection,
    required T Function(Map<String, dynamic> data) fromJson,
    required int limit,
    DocumentSnapshot? startAfter,
    required String orderByField,
    bool descending = true,
  }) async {
    Query orderBy = collection.orderBy(orderByField, descending: descending);
    Query query = orderBy.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final response = await query.get();

    List<T> items = response.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return fromJson(data);
    }).toList();

    DocumentSnapshot? lastDoc =
        response.docs.isNotEmpty ? response.docs.last : null;

    return PaginatedResponse<T>(
      items: items,
      lastDocument: lastDoc,
    );
  }
}
