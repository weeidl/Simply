// paginated_response.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginatedResponse<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;

  PaginatedResponse({
    required this.items,
    this.lastDocument,
  });
}
