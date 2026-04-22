import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simply/models/message.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/screens/message_details/cubit/message_details_cubit.dart';
import 'package:simply/screens/message_details/widget/message_details_widget.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/screens/widget/place_holder/no_messages_available.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class MessageDetailsScreen extends StatelessWidget {
  final String title;

  const MessageDetailsScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  static Route route({
    required String conversationId,
    required String title,
  }) {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => MessageDetailsCubit(
            messagesRepository: MessagesRepository(),
            conversationId: conversationId,
          ),
          child: MessageDetailsScreen(title: title),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: AppBarWidget(
        nameScreen: title,
        isLight: false,
        showBackButton: true,
      ),
      child: BlocBuilder<MessageDetailsCubit, MessageDetailsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: SpinKitFadingCube(
                color: AppColor.orange.withValues(alpha: 0.5),
              ),
            );
          }

          if (state.hasError) {
            return _MessagesDetailsErrorView(
              onRetry: () => context.read<MessageDetailsCubit>().refresh(),
            );
          }

          if (!state.isLoaded || state.items.isEmpty) {
            return const NoMessagesAvailable();
          }

          return RefreshIndicator(
            onRefresh: () => context.read<MessageDetailsCubit>().refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final Message message = state.items[index];
                return MessageDetailsWidget(message: message);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MessagesDetailsErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _MessagesDetailsErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load messages',
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
