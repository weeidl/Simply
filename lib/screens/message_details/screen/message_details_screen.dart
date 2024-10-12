import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:sms_forward_app/screens/common/cubit_list_view.dart';
import 'package:sms_forward_app/screens/message_details/cubit/message_details_cubit.dart';
import 'package:sms_forward_app/screens/message_details/widget/message_details_widget.dart';
import 'package:sms_forward_app/screens/widget/app_bar_widget.dart';
import 'package:sms_forward_app/screens/widget/bacgraund_widget.dart';
import 'package:sms_forward_app/screens/widget/place_holder/no_messages_available.dart';

class MessageDetailsScreen extends StatelessWidget {
  final String title;

  const MessageDetailsScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  static Route route({required String id, required String title}) {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => MessageDetailsCubit(
            messagesRepository: MessagesRepository(),
            id: id,
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
      child: CubitListView<MessageDetails, MessageDetailsCubit>(
        // Replace with a suitable one Place Holder
        placeHolder: const NoMessagesAvailable(),
        itemBuilder: (context, message) {
          return MessageDetailsWidget(message: message);
        },
        // reverse: true,
      ),
    );
  }
}
