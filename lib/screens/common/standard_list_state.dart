import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:simply/screens/common/status.dart';

@immutable
class StandardListState<T> extends Equatable {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool isPaginate;
  final StandardStatus status;
  final String? errorMessage;
  final bool hasNext;

  const StandardListState({
    this.items = const [],
    this.lastDocument,
    this.isPaginate = false,
    this.status = StandardStatus.initial,
    this.errorMessage,
    this.hasNext = true,
  });

  StandardListState<T> copyWith({
    List<T>? items,
    DocumentSnapshot? lastDocument,
    bool? isPaginate,
    StandardStatus? status,
    String? errorMessage,
    bool? hasNext,
  }) {
    return StandardListState<T>(
      items: items ?? this.items,
      lastDocument: lastDocument ?? this.lastDocument,
      isPaginate: isPaginate ?? this.isPaginate,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      hasNext: hasNext ?? this.hasNext,
    );
  }

  bool get isInitial => status == StandardStatus.initial;
  bool get isLoading => status == StandardStatus.loading;
  bool get isLoaded => status == StandardStatus.loaded;
  bool get hasError => status == StandardStatus.error;

  @override
  List<Object?> get props => [
        items,
        lastDocument,
        isPaginate,
        status,
        errorMessage,
        hasNext,
      ];
}
