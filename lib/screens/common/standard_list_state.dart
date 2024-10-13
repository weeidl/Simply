import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:simply/screens/common/status.dart';

@immutable
class StandardListState<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool isPaginate;
  final StandardStatus status;
  final String? errorMessage;

  const StandardListState({
    required this.items,
    this.lastDocument,
    this.isPaginate = false,
    this.status = StandardStatus.initial,
    this.errorMessage,
  });

  StandardListState<T> copyWith({
    List<T>? items,
    DocumentSnapshot? lastDocument,
    bool? isPaginate,
    StandardStatus? status,
    String? errorMessage,
  }) {
    return StandardListState<T>(
      items: items ?? this.items,
      lastDocument: lastDocument ?? this.lastDocument,
      isPaginate: isPaginate ?? this.isPaginate,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasNext => lastDocument != null;

  bool get isInitial => status == StandardStatus.initial;
  bool get isLoading => status == StandardStatus.loading;
  bool get isLoaded => status == StandardStatus.loaded;
  bool get hasError => status == StandardStatus.error;
}
