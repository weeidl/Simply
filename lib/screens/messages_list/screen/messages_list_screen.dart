import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/screens/messages_list/cubit/messages_list_cubit.dart';
import 'package:simply/screens/messages_list/widget/messages_list_widget.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/screens/widget/place_holder/no_messages_available.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: const AppBarWidget(
        nameScreen: 'Messages',
        showIconPeople: true,
        isLight: false,
      ),
      child: BlocBuilder<MessagesListCubit, MessagesListState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: SpinKitFadingCube(
                color: AppColor.orange.withValues(alpha: 0.5),
              ),
            );
          }

          if (state.hasError) {
            return _MessagesErrorView(
              onRetry: () => context.read<MessagesListCubit>().refresh(),
            );
          }

          if (!state.isLoaded || state.items.isEmpty) {
            return const NoMessagesAvailable();
          }

          return RefreshIndicator(
            onRefresh: () => context.read<MessagesListCubit>().refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final Conversation conversation = state.items[index];
                return MessagesListWidget(conversation: conversation);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MessagesErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _MessagesErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load conversations',
            style: AppTextStyle.title5(AppColor.greyDark),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
