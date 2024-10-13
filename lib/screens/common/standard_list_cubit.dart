import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/models/paginated_response.dart';
import 'package:simply/screens/common/standard_list_state.dart';
import 'package:simply/screens/common/status.dart';

typedef StandardListFetch<T> = Future<PaginatedResponse<T>> Function({
  DocumentSnapshot? startAfter,
});

class StandardListCubit<T> extends Cubit<StandardListState<T>> {
  final StandardListFetch<T> _fetch;

  StandardListCubit({required StandardListFetch<T> fetch})
      : _fetch = fetch,
        super(StandardListState<T>(
          status: StandardStatus.initial,
          items: const [],
          lastDocument: null,
        ));

  Future<void> fetch() async {
    emit(state.copyWith(status: StandardStatus.loading));
    try {
      final response = await _fetch();
      emit(state.copyWith(
        status: StandardStatus.loaded,
        items: response.items,
        lastDocument: response.lastDocument,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StandardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> paginate() async {
    if (state.isLoaded && !state.isPaginate && state.hasNext) {
      emit(state.copyWith(isPaginate: true));

      try {
        final response = await _fetch(startAfter: state.lastDocument);

        final items = [...state.items, ...response.items];
        final hasNewItems = response.items.isNotEmpty;

        emit(state.copyWith(
          items: items,
          lastDocument: hasNewItems ? response.lastDocument : null,
          isPaginate: false,
          status: StandardStatus.loaded,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: StandardStatus.error,
          errorMessage: e.toString(),
          isPaginate: false,
        ));
      }
    } else if (state.isPaginate) {
      emit(state.copyWith(isPaginate: false));
    }
  }

  Future<void> refresh() async {
    try {
      final response = await _fetch();
      emit(state.copyWith(
        items: response.items,
        lastDocument: response.lastDocument,
        status: StandardStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StandardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void onScroll(ScrollMetrics metrics) {
    if (state.isLoaded && !state.isPaginate && state.hasNext) {
      final threshold = metrics.maxScrollExtent * 0.9;
      if (metrics.pixels >= threshold) {
        paginate();
      }
    }
  }
}
