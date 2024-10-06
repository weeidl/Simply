import 'package:flutter/material.dart';
import 'package:sms_forward_app/themes/colors.dart';

const Color sentMessageColor = Colors.blue;
const Color receivedMessageColor = Colors.white;
const Color timestampColor = Colors.grey;

class MessageThreadWidget extends StatelessWidget {
  final String message;
  final bool isSent;

  const MessageThreadWidget({
    super.key,
    required this.message,
    this.isSent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 38),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSent ? sentMessageColor : AppColor.greyLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IntrinsicWidth(
            child: Text(
              message,
              style: TextStyle(
                color: isSent ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
