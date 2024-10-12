import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sms_forward_app/extensions.dart';
import 'package:sms_forward_app/models/messages.dart';
import 'package:sms_forward_app/screens/message_details/screen/message_details_screen.dart';
import 'package:sms_forward_app/screens/messages_list/widget/avatar_with_indicator.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class MessagesListWidget extends StatelessWidget {
  final Messages message;

  const MessagesListWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final unreadMessageCount = message.unreadMessagesCount;
    final notificationCount =
        unreadMessageCount == 0 ? null : unreadMessageCount;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MessageDetailsScreen.route(
            id: message.id,
            title: message.title,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWithIndicator(notificationCount: notificationCount),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.title,
                        style: AppTextStyle.title5(AppColor.greyDark),
                      ),
                      const Spacer(),
                      Text(
                        message.lastMessageDate.formatDateTime(),
                        style: AppTextStyle.captionS(AppColor.grey),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    message.lastMessage,
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
