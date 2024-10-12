import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/extensions.dart';
import 'package:sms_forward_app/models/messages.dart';
import 'package:sms_forward_app/screens/message_thread/screen/message_thread_screen.dart';
import 'package:sms_forward_app/screens/messages_list/cubit/messages_cubit.dart';
import 'package:sms_forward_app/screens/common/cubit_list_view.dart';
import 'package:sms_forward_app/screens/messages_list/widget/messages_list_widget.dart';
import 'package:sms_forward_app/screens/widget/app_bar_widget.dart';
import 'package:sms_forward_app/themes/colors.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.orange,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const AppBarWidget(
              nameScreen: 'Messages',
              isLight: false,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: CubitListView<Messages, MessagesCubit>(
                  placeHolder: const Center(
                    child: Text(
                      'No messages available.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  itemBuilder: (context, message) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MessageThreadScreen.route(
                            id: message.id,
                            title: message.title,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: message.unreadMessagesCount > 0
                              ? AppColor.greyLight
                              : Colors.transparent,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: MessagesWidget(
                          imagePath: 'path_to_your_image.jpg',
                          title: message.title,
                          message: message.lastMessage,
                          time: message.lastMessageDate.formatDateTime(),
                          notificationCount: message.unreadMessagesCount == 0
                              ? null
                              : message.unreadMessagesCount,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
