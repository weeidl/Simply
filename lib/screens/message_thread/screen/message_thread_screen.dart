// message_thread_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/extensions.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:sms_forward_app/screens/message_thread/cubit/message_thread_cubit.dart';
import 'package:sms_forward_app/screens/message_thread/widget/message_thread_widget.dart';
import 'package:sms_forward_app/screens/common/cubit_list_view.dart';
import 'package:sms_forward_app/screens/widget/app_bar_back_widget.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class MessageThreadScreen extends StatelessWidget {
  final String title;

  const MessageThreadScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  static Route route({required String id, required String title}) {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => MessageThreadCubit(
            messagesRepository: MessagesRepository(),
            id: id,
          ),
          child: MessageThreadScreen(title: title),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.orange,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            AppBarBackWidget(
              nameScreen: title,
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
                child: CubitListView<MessageThread, MessageThreadCubit>(
                  // reverse: true,
                  placeHolder: const Center(
                    child: Text(
                      'No messages found.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  itemBuilder: (context, message) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // if (showTime)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 24,
                            bottom: 8,
                          ),
                          child: Text(
                            message.date.formatDateTime(),
                            style: AppTextStyle.captionS(AppColor.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        MessageThreadWidget(message: message.text),
                      ],
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
