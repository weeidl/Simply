import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:simply/extensions.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/screens/message_details/screen/message_details_screen.dart';
import 'package:simply/screens/messages_list/cubit/messages_list_cubit.dart';
import 'package:simply/screens/messages_list/widget/avatar_with_indicator.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class MessagesListWidget extends StatelessWidget {
  final Conversation conversation;

  const MessagesListWidget({
    super.key,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    final unreadMessagesCount =
        conversation.unreadMessagesCount == 0 ? null : conversation.unreadMessagesCount;

    return InkWell(
      onTap: () async {
        await context
            .read<MessagesListCubit>()
            .markConversationRead(conversation.id);

        if (!context.mounted) return;

        Navigator.push(
          context,
          MessageDetailsScreen.route(
            conversationId: conversation.id,
            title: conversation.title,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWithIndicator(notificationCount: unreadMessagesCount),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        style: AppTextStyle.title5(AppColor.greyDark),
                      ),
                      const Spacer(),
                      Text(
                        conversation.lastMessageDate.formatDateTime(),
                        style: AppTextStyle.captionS(AppColor.grey),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    conversation.lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.captionSM(AppColor.greyDark),
                  ),
                ],
              ),
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}
