import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/extensions.dart';
import 'package:simply/models/message.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/screens/message_details/cubit/message_details_cubit.dart';
import 'package:simply/screens/messages_list/widget/avatar_with_indicator.dart';
import 'package:simply/screens/widget/app_bar_widget.dart';
import 'package:simply/screens/widget/background_widget.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';
import 'package:simply/utils/code_extractor.dart';

class MessageDetailsScreen extends StatelessWidget {
  final String title;
  final String? sourcePlatform;

  const MessageDetailsScreen({
    super.key,
    required this.title,
    this.sourcePlatform,
  });

  static Route route({
    required String conversationId,
    required String title,
    String? sourcePlatform,
  }) {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => MessageDetailsCubit(
            messagesRepository: MessagesRepository(),
            conversationId: conversationId,
          ),
          child: MessageDetailsScreen(
            title: title,
            sourcePlatform: sourcePlatform,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: AppBarWidget(
        showBackButton: true,
        leading: AvatarWithIndicator(
          title: title,
          size: 40,
          devicePlatform: sourcePlatform,
        ),
        title: title,
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColor.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _platformLabel(),
                style: AppTextStyle.caption(AppColor.inkTertiary),
              ),
            ],
          ),
        ),
        trailing: _DotsButton(),
      ),
      child: BlocBuilder<MessageDetailsCubit, MessageDetailsState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.accent),
            );
          }
          if (state.hasError) {
            return _ErrorView(
              onRetry: () => context.read<MessageDetailsCubit>().refresh(),
            );
          }
          if (!state.isLoaded || state.items.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            color: AppColor.accent,
            onRefresh: () => context.read<MessageDetailsCubit>().refresh(),
            child: _MessagesList(messages: state.items),
          );
        },
      ),
    );
  }

  String _platformLabel() {
    final p = sourcePlatform?.toLowerCase();
    if (p == null) return 'SMS';
    if (p.contains('ios')) return 'SMS · с iPhone';
    if (p.contains('android')) return 'SMS · с Android';
    return 'SMS';
  }
}

class _MessagesList extends StatelessWidget {
  final List<Message> messages;

  const _MessagesList({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const _InfoBanner();
        final message = messages[index - 1];
        final prev = index > 1 ? messages[index - 2] : null;
        final showDivider = prev == null ||
            !_sameDay(prev.date, message.date);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDivider) _DateDivider(label: message.date.formatChatDivider()),
            const SizedBox(height: 6),
            _MessageBubble(message: message),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColor.accentSoft,
        borderRadius: AppRadii.brR3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColor.accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.sync_rounded,
                size: 15, color: AppColor.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Simply пересылает SMS с устройства и автоматически копирует найденные коды в буфер обмена.',
              style: AppTextStyle.bodySm(AppColor.accentInk),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final String label;
  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColor.divider, height: 1)),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyle.caption(AppColor.inkTertiary)),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColor.divider, height: 1)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final code = CodeExtractor.extract(message.text);
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
                boxShadow: AppShadows.s,
                border: Border.all(color: const Color(0x0A281910)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text, style: AppTextStyle.bodyM(AppColor.ink)),
                  if (code != null) ...[
                    const SizedBox(height: 12),
                    _CodeBlock(code: code),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 4),
              child: Text(
                message.date.formatTime(),
                style: AppTextStyle.caption(AppColor.inkTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String code;
  const _CodeBlock({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColor.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColor.accent.withValues(alpha: 0.4),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Найден код',
                    style: AppTextStyle.micro(AppColor.inkTertiary)),
                const SizedBox(height: 2),
                Text(_spaced(code),
                    style: AppTextStyle.codeMono(AppColor.ink)),
              ],
            ),
          ),
          _CopyButton(code: code),
        ],
      ),
    );
  }

  String _spaced(String code) {
    if (code.length <= 4) return code;
    final mid = (code.length / 2).ceil();
    return '${code.substring(0, mid)} ${code.substring(mid)}';
  }
}

class _CopyButton extends StatelessWidget {
  final String code;
  const _CopyButton({required this.code});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.accent,
      borderRadius: AppRadii.brPill,
      child: InkWell(
        borderRadius: AppRadii.brPill,
        onTap: () {
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColor.ink,
              content: Text('Код скопирован',
                  style: AppTextStyle.bodySm(AppColor.white)),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.copy_rounded, size: 13, color: AppColor.white),
              const SizedBox(width: 6),
              Text('Копировать',
                  style: AppTextStyle.button(AppColor.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColor.surface,
        shape: BoxShape.circle,
        boxShadow: AppShadows.s,
        border: Border.all(color: const Color(0x0A281910)),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.more_horiz_rounded,
          size: 18, color: AppColor.inkSecondary),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColor.accentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  color: AppColor.accentDeep, size: 38),
            ),
            const SizedBox(height: 16),
            Text('Сообщений нет',
                style: AppTextStyle.title(AppColor.ink)),
            const SizedBox(height: 6),
            Text(
              'Они появятся здесь, когда придут на устройство.',
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySm(AppColor.inkTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Не удалось загрузить',
              style: AppTextStyle.title(AppColor.ink)),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColor.accent),
            onPressed: onRetry,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
