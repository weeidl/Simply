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
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/screens/widget/warm/warm_snack_bar.dart';
import 'package:simply/services/ui_preferences_service.dart';
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
    return platformPageRoute(
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
                decoration: const BoxDecoration(
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
        trailing: Builder(
          builder: (context) => _DotsButton(
            onTap: () => _showMoreActions(context),
          ),
        ),
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

  Future<void> _showMoreActions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColor.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _MoreActionsSheet(
          conversationTitle: title,
          sourcePlatformLabel: _platformLabel(),
        );
      },
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
    final chronological = messages.reversed.toList(growable: false);
    final shortThread = chronological.length <= 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          reverse: !shortThread,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  constraints.maxHeight > 28 ? constraints.maxHeight - 28 : 0,
            ),
            child: Column(
              mainAxisAlignment:
                  shortThread ? MainAxisAlignment.start : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _InfoBanner(),
                for (var i = 0; i < chronological.length; i++)
                  _MessageListEntry(
                    message: chronological[i],
                    previous: i > 0 ? chronological[i - 1] : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessageListEntry extends StatelessWidget {
  final Message message;
  final Message? previous;

  const _MessageListEntry({
    required this.message,
    required this.previous,
  });

  @override
  Widget build(BuildContext context) {
    final showDivider =
        previous == null || !_sameDay(previous!.date, message.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider) _DateDivider(label: message.date.formatChatDivider()),
        const SizedBox(height: 6),
        _MessageBubble(message: message),
        const SizedBox(height: 8),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Dismissible info card shown above the message list.
///
/// Once dismissed it is never shown again on this device (persisted via
/// [UiPreferencesService]); the full copy is still reachable through the
/// ⋯ menu → "Как работает Simply".
class _InfoBanner extends StatefulWidget {
  const _InfoBanner();

  @override
  State<_InfoBanner> createState() => _InfoBannerState();
}

class _InfoBannerState extends State<_InfoBanner> {
  final UiPreferencesService _preferences = UiPreferencesService();

  /// `null` → still loading the persisted flag. Avoids flashing the banner
  /// on repeat users who previously dismissed it.
  bool? _dismissed;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final dismissed = await _preferences.isMessagesInfoBannerDismissed();
    if (!mounted) return;
    setState(() => _dismissed = dismissed);
  }

  Future<void> _dismiss() async {
    setState(() => _dismissed = true);
    await _preferences.setMessagesInfoBannerDismissed(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed == null || _dismissed == true) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          decoration: const BoxDecoration(
            color: AppColor.accentSoft,
            borderRadius: AppRadii.brR3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColor.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.sync_rounded,
                    size: 15, color: AppColor.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, right: 4),
                  child: Text(
                    'Simply пересылает SMS с устройства и автоматически копирует найденные коды в буфер обмена.',
                    style: AppTextStyle.bodySm(AppColor.accentInk),
                  ),
                ),
              ),
              PlatformTapScale(
                child: Semantics(
                  button: true,
                  label: 'Скрыть подсказку',
                  child: InkResponse(
                    onTap: _dismiss,
                    radius: 20,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColor.accentInk,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet behind the ⋯ button. Keeps the primary chat area uncluttered
/// while still surfacing "how it works" + a few useful extras.
class _MoreActionsSheet extends StatelessWidget {
  final String conversationTitle;
  final String sourcePlatformLabel;

  const _MoreActionsSheet({
    required this.conversationTitle,
    required this.sourcePlatformLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColor.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _HowItWorksCard(),
            const SizedBox(height: 8),
            _ActionRow(
              icon: Icons.content_copy_rounded,
              label: 'Скопировать адрес отправителя',
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(
                  ClipboardData(text: conversationTitle),
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
                messenger.clearSnackBars();
                messenger.showSnackBar(
                  buildWarmSnackBar(
                    message: 'Готово, отправитель уже в буфере',
                    icon: Icons.copy_rounded,
                  ),
                );
              },
            ),
            _ActionRow(
              icon: Icons.devices_rounded,
              label: 'Источник: $sourcePlatformLabel',
              onTap: null,
              subtle: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: const BoxDecoration(
        color: AppColor.accentSoft,
        borderRadius: AppRadii.brR3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColor.accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child:
                const Icon(Icons.sync_rounded, size: 16, color: AppColor.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Как работает Simply',
                    style: AppTextStyle.titleSm(AppColor.accentInk)),
                const SizedBox(height: 4),
                Text(
                  'Simply пересылает SMS с устройства и автоматически копирует найденные коды в буфер обмена.',
                  style: AppTextStyle.bodySm(AppColor.accentInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool subtle;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtle = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = subtle ? AppColor.inkTertiary : AppColor.ink;
    return PlatformTapScale(
      pressedScale: 0.98,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyle.body(color),
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColor.inkPlaceholder,
                ),
            ],
          ),
        ),
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
    final timeLabel = message.date.formatTime();

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.text,
                  style: AppTextStyle.bodyM(AppColor.ink),
                ),
              ),
              if (code != null) ...[
                const SizedBox(height: 12),
                _CodeBlock(code: code),
                // After the code block we put the timestamp on its own line so
                // it doesn't visually compete with the "Copy" action.
                const SizedBox(height: 8),
                _TimeLabel(label: timeLabel),
              ] else ...[
                // Without the code block the timestamp hugs the bottom-right of
                // the same bubble — classic chat affordance, no extra height.
                const SizedBox(height: 4),
                _TimeLabel(label: timeLabel),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  const _TimeLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyle.caption(AppColor.inkTertiary),
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
        color: AppColor.bgAlt.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Код из сообщения',
                    style: AppTextStyle.micro(AppColor.inkTertiary)),
                const SizedBox(height: 2),
                Text(_spaced(code), style: AppTextStyle.codeMono(AppColor.ink)),
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
    return PlatformTapScale(
      child: Material(
        color: AppColor.accent,
        borderRadius: AppRadii.brPill,
        child: InkWell(
          borderRadius: AppRadii.brPill,
          onTap: () {
            Clipboard.setData(ClipboardData(text: code));
            showWarmSnackBar(
              context,
              message: 'Готово, код уже в буфере',
              icon: Icons.copy_rounded,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.copy_rounded,
                  size: 13,
                  color: AppColor.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Копировать',
                  style: AppTextStyle.button(AppColor.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _DotsButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return PlatformTapScale(
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.brPill,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brPill,
          child: Container(
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
          ),
        ),
      ),
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
              decoration: const BoxDecoration(
                color: AppColor.accentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  color: AppColor.accentDeep, size: 38),
            ),
            const SizedBox(height: 16),
            Text('Сообщений нет', style: AppTextStyle.title(AppColor.ink)),
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
          Text('Не удалось загрузить', style: AppTextStyle.title(AppColor.ink)),
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
