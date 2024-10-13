import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:simply/extensions.dart';
import 'package:simply/models/messages.dart';
import 'package:simply/screens/message_details/screen/message_details_screen.dart';
import 'package:simply/screens/messages_list/cubit/messages_list_cubit.dart';
import 'package:simply/screens/messages_list/widget/avatar_with_indicator.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class MessagesListWidget extends StatefulWidget {
  final Messages message;

  const MessagesListWidget({
    super.key,
    required this.message,
  });

  @override
  State<MessagesListWidget> createState() => MessagesListWidgetState();
}

class MessagesListWidgetState extends State<MessagesListWidget> {
  int? unreadMessagesCount;

  @override
  void initState() {
    super.initState();

    unreadMessagesCount = widget.message.unreadMessagesCount != 0
        ? widget.message.unreadMessagesCount
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          MessageDetailsScreen.route(
            id: widget.message.id,
            title: widget.message.title,
          ),
        );
        if (unreadMessagesCount != null) {
          final cubit = context.read<MessagesListCubit>();
          await cubit.updatedUnreadMessagesCount(widget.message);
          setState(() {
            unreadMessagesCount = null;
          });
        }
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
                        widget.message.title,
                        style: AppTextStyle.title5(AppColor.greyDark),
                      ),
                      const Spacer(),
                      Text(
                        widget.message.lastMessageDate.formatDateTime(),
                        style: AppTextStyle.captionS(AppColor.grey),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    widget.message.lastMessage,
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
