import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/screens/common/standard_list_cubit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sms_forward_app/screens/common/standard_list_state.dart';
import 'package:sms_forward_app/themes/colors.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class CubitListView<T, C extends StandardListCubit<T>> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocBuilder<C, StandardListState<T>>(
      builder: (context, state) {
        if (state.isInitial) {
          context.read<C>().fetch();
        }
        if (state.hasError && error != null) {
          return error!;
        }
        if (state.isLoaded || state.isPaginate) {
          if (state.items.isEmpty) {
            return placeHolder ?? Container();
          }
          return RefreshIndicator(
            onRefresh: reverse ? () async {} : context.read<C>().refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo is ScrollUpdateNotification) {
                  context.read<C>().onScroll(scrollInfo.metrics);
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12),
                itemCount: state.items.length + (state.isPaginate ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
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
                  } else {
                    final itemIndex =
                        reverse ? state.items.length - 1 - index : index;
                    return itemBuilder(context, state.items[itemIndex]);
                  }
                },
                shrinkWrap: shrinkWrap,
                controller: controller,
                reverse: reverse,
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
          return placeHolder ?? Container();
        }
      },
    );
  }
}
