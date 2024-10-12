import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_forward_app/extensions.dart';
import 'package:sms_forward_app/models/message.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class MessageDetailsWidget extends StatelessWidget {
  final MessageDetails message;

  const MessageDetailsWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final RegExp codeRegExp = RegExp(r'\b\d{6}\b');
    final Iterable<RegExpMatch> matches = codeRegExp.allMatches(message.text);

    if (matches.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text(
              message.date.formatFullDateTime(),
              style: AppTextStyle.captionS(AppColor.grey),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 44),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.greyLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IntrinsicWidth(
                child: Text(
                  message.text,
                  style: AppTextStyle.paragraph(AppColor.greyDark),
                ),
              ),
            ),
          ),
        ],
      );
    }

    List<TextSpan> textSpans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        textSpans.add(
          TextSpan(
            text: message.text.substring(lastIndex, match.start),
            style: AppTextStyle.paragraph(AppColor.greyDark),
          ),
        );
      }

      final String code = match.group(0) ?? '';
      textSpans.add(
        TextSpan(
          text: code,
          style: AppTextStyle.paragraph(AppColor.orange),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Code copied: $code',
                    style: AppTextStyle.captionS(AppColor.greyDark),
                  ),
                  backgroundColor: AppColor.greyLight,
                ),
              );
            },
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < message.text.length) {
      textSpans.add(
        TextSpan(
          text: message.text.substring(lastIndex),
          style: AppTextStyle.paragraph(AppColor.greyDark),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            message.date.formatFullDateTime(),
            style: AppTextStyle.captionS(AppColor.grey),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 44),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.greyLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IntrinsicWidth(
              child: RichText(
                text: TextSpan(children: textSpans),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
