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
    this.error,
  }) : super(key: key);

  final ItemWidgetBuilder<T> itemBuilder;
  final bool shrinkWrap;
  final ScrollController? controller;
  final Widget? placeHolder;
  final Widget? error;

  @override
  CubitListViewState<T, C> createState() => CubitListViewState<T, C>();
}

class CubitListViewState<T, C extends StandardListCubit<T>>
    extends State<CubitListView<T, C>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
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
            return widget.placeHolder ?? const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: () => context.read<C>().refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo is ScrollUpdateNotification) {
                  context.read<C>().onScroll(scrollInfo.metrics);
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: widget.shrinkWrap,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.items.length + (state.isPaginate ? 1 : 0),
                itemBuilder: (BuildContext ctx, int index) {
                  if (state.isPaginate && index == state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: SpinKitThreeBounce(
                          color: AppColor.orange,
                          size: 24,
                        ),
                      ),
                    );
                  }
                  return widget.itemBuilder(ctx, state.items[index]);
                },
              ),
            ),
          );
        }

        if (state.isLoading) {
          return Center(
            child: SpinKitFadingCube(
              color: AppColor.orange.withValues(alpha: 0.5),
            ),
          );
        }

        return widget.placeHolder ?? const SizedBox.shrink();
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
