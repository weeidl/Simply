import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/screens/common/standard_list_cubit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simply/screens/common/standard_list_state.dart';
import 'package:simply/themes/colors.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class CubitListView<T, C extends StandardListCubit<T>> extends StatefulWidget {
  const CubitListView({
    Key? key,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.controller,
    this.placeHolder,
    this.header,
    this.error,
    this.reverse = false,
  }) : super(key: key);

  final ItemWidgetBuilder<T> itemBuilder;
  final bool shrinkWrap;
  final ScrollController? controller;
  final Widget? placeHolder;
  final Widget? header;
  final Widget? error;
  final bool reverse;

  @override
  _CubitListViewState<T, C> createState() => _CubitListViewState<T, C>();
}

class _CubitListViewState<T, C extends StandardListCubit<T>>
    extends State<CubitListView<T, C>> {
  late ScrollController _scrollController;
  int _previousItemCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      final offset =
          widget.reverse ? position.minScrollExtent : position.maxScrollExtent;
      _scrollController.jumpTo(offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, StandardListState<T>>(
      builder: (context, state) {
        if (state.isInitial) {
          context.read<C>().fetch();
        }
        if (state.hasError && widget.error != null) {
          return widget.error!;
        }
        if (state.isLoaded || state.isPaginate) {
          if (state.items.isEmpty) {
            return widget.placeHolder ?? Container();
          }

          // Переворачиваем список элементов, если reverse == true
          final items =
              widget.reverse ? state.items.reversed.toList() : state.items;

          // Проверяем, были ли добавлены новые элементы в нижнюю часть списка
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              if (_previousItemCount < items.length) {
                // Если не происходит пагинация (т.е. не загружаются более старые сообщения)
                if (!state.isPaginate) {
                  _scrollToBottom();
                }
              }
              _previousItemCount = items.length;
            }
          });

          return RefreshIndicator(
            onRefresh: widget.reverse
                ? context.read<C>().loadOlderMessages
                : context.read<C>().refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo is ScrollUpdateNotification) {
                  context.read<C>().onScroll(scrollInfo.metrics);
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12),
                itemCount: items.length + (state.isPaginate ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (state.isPaginate && index == items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: SpinKitThreeBounce(
                          color: AppColor.orange,
                          size: 24,
                        ),
                      ),
                    );
                  } else {
                    return widget.itemBuilder(context, items[index]);
                  }
                },
                shrinkWrap: widget.shrinkWrap,
                controller: _scrollController,
                reverse: widget.reverse,
              ),
            ),
          );
        } else if (state.isLoading) {
          return Center(
            child: SpinKitFadingCube(
              color: AppColor.orange.withOpacity(0.5),
            ),
          );
        } else {
          return widget.placeHolder ?? Container();
        }
      },
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
}
