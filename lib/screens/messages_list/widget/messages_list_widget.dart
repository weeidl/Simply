import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/extensions.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/screens/message_details/screen/message_details_screen.dart';
import 'package:simply/screens/messages_list/cubit/messages_list_cubit.dart';
import 'package:simply/screens/messages_list/widget/avatar_with_indicator.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';
import 'package:simply/utils/code_extractor.dart';

class MessagesListWidget extends StatelessWidget {
  final Conversation conversation;

  const MessagesListWidget({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadMessagesCount > 0;
    final code = CodeExtractor.extract(conversation.lastMessage);

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.brR3,
      child: InkWell(
        borderRadius: AppRadii.brR3,
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          decoration: BoxDecoration(
            color: unread
                ? AppColor.accent.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: AppRadii.brR3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarWithIndicator(
                title: conversation.title,
                devicePlatform: conversation.sourcePlatform,
              ),
              const SizedBox(width: 12),
              Expanded(child: _content(context, unread, code)),
              if (unread) const SizedBox(width: 8),
              if (unread)
                Container(
                  margin: const EdgeInsets.only(top: 18),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColor.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.accent.withValues(alpha: 0.35),
                        blurRadius: 0,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, bool unread, String? code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      conversation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight:
                            unread ? FontWeight.w700 : FontWeight.w600,
                        color: AppColor.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (conversation.category != null) ...[
                    const SizedBox(width: 6),
                    _CategoryTag(label: conversation.category!),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              conversation.lastMessageDate.formatRelativeShort(),
              style: AppTextStyle.caption(AppColor.inkTertiary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          conversation.lastMessage,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.bodySm(
              unread ? AppColor.inkSecondary : AppColor.inkTertiary),
        ),
        if (code != null) ...[
          const SizedBox(height: 8),
          _CodeChip(code: code),
        ],
      ],
    );
  }

  Future<void> _open(BuildContext context) async {
    await context
        .read<MessagesListCubit>()
        .markConversationRead(conversation.id);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MessageDetailsScreen.route(
        conversationId: conversation.id,
        title: conversation.title,
        sourcePlatform: conversation.sourcePlatform,
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String label;
  const _CategoryTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: AppColor.bgAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColor.inkTertiary,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  final String code;
  const _CodeChip({required this.code});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _copy(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x0F281910)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Код',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColor.inkTertiary,
                )),
            const SizedBox(width: 8),
            Text(
              code,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColor.ink,
                letterSpacing: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.copy_rounded, size: 13, color: AppColor.accent),
          ],
        ),
      ),
    );
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColor.ink,
        content: Text('Код $code скопирован',
            style: AppTextStyle.bodySm(AppColor.white)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
