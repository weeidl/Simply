import 'package:flutter/material.dart';
import 'package:sms_forward_app/models/messages.dart';
import 'package:sms_forward_app/screens/messages_list/cubit/messages_list_cubit.dart';
import 'package:sms_forward_app/screens/common/cubit_list_view.dart';
import 'package:sms_forward_app/screens/messages_list/widget/messages_list_widget.dart';
import 'package:sms_forward_app/screens/widget/app_bar_widget.dart';
import 'package:sms_forward_app/screens/widget/bacgraund_widget.dart';
import 'package:sms_forward_app/screens/widget/place_holder/no_messages_available.dart';

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
      child: CubitListView<Messages, MessagesListCubit>(
        placeHolder: const NoMessagesAvailable(),
        itemBuilder: (context, message) {
          return MessagesListWidget(
            message: message,
          );
        },
      ),
    );
  }
}
