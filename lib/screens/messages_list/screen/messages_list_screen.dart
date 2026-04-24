import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/screens/messages_list/cubit/messages_list_cubit.dart';
import 'package:simply/screens/messages_list/widget/messages_list_widget.dart';
import 'package:simply/screens/widget/dialogs/confirmation_dialog.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/screens/widget/warm/warm_chip.dart';
import 'package:simply/screens/widget/warm/warm_header.dart';
import 'package:simply/screens/widget/warm/warm_search_field.dart';
import 'package:simply/screens/widget/warm/warm_snack_bar.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesListCubit, MessagesListState>(
      builder: (context, state) {
        final cubit = context.read<MessagesListCubit>();
        final filtered = state.filteredItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WarmHeader(
              eyebrow: _eyebrow(state),
              title: 'Сообщения',
              trailing: const _ProfileBubble(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: WarmSearchField(
                hint: 'Поиск по сообщениям',
                trailingIcon: Icons.tune_rounded,
                onTrailingTap: () => _showFilterSettings(context),
                onChanged: cubit.setQuery,
              ),
            ),
            _FilterChips(
              filter: state.filter,
              enabledFilters: state.enabledFilters,
              total: state.totalCount,
              unread: state.unreadCount,
              onSelect: cubit.setFilter,
            ),
            const SizedBox(height: 14),
            Expanded(child: _list(context, state, filtered)),
          ],
        );
      },
    );
  }

  Future<void> _showFilterSettings(BuildContext context) {
    final cubit = context.read<MessagesListCubit>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColor.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<MessagesListCubit, MessagesListState>(
            builder: (context, state) {
              return _FilterSettingsSheet(
                enabledFilters: state.enabledFilters,
                onChanged: cubit.setFilterEnabled,
              );
            },
          ),
        );
      },
    );
  }

  String _eyebrow(MessagesListState state) {
    if (state.unreadCount == 0) {
      return state.totalCount == 0
          ? 'Здесь будут ваши SMS'
          : '${state.totalCount} в архиве';
    }
    return '${state.unreadCount} новых · сегодня';
  }

  Widget _list(
    BuildContext context,
    MessagesListState state,
    List<Conversation> filtered,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const _LoadingView();
    }
    if (state.hasError) {
      return _ErrorView(
          onRetry: () => context.read<MessagesListCubit>().refresh());
    }
    if (filtered.isEmpty) {
      return _EmptyView(filter: state.filter, query: state.query);
    }
    return Stack(
      children: [
        RefreshIndicator(
          color: AppColor.accent,
          onRefresh: () => context.read<MessagesListCubit>().refresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              12,
              0,
              12,
              state.isSelectionMode ? 154 : 100,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final conversation = filtered[index];
              final selected =
                  state.selectedConversationIds.contains(conversation.id);
              return MessagesListWidget(
                conversation: conversation,
                selected: selected,
                onTap: state.isSelectionMode
                    ? () => context
                        .read<MessagesListCubit>()
                        .toggleConversationSelection(conversation.id)
                    : null,
                onLongPress: () =>
                    _showConversationActions(context, conversation),
              );
            },
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14,
          child: _SelectionActionBar(
            selectedCount: state.selectedConversationIds.length,
            onReadAll: () => _markSelectedRead(context),
            onDeleteAll: () => _confirmDeleteSelected(context),
          ),
        ),
      ],
    );
  }

  Future<void> _markSelectedRead(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<MessagesListCubit>().markSelectedRead();
    messenger.clearSnackBars();
    messenger.showSnackBar(
      buildWarmSnackBar(
        message: 'Выбранные диалоги прочитаны',
        icon: Icons.done_all_rounded,
      ),
    );
  }

  Future<void> _confirmDeleteSelected(BuildContext context) {
    final count =
        context.read<MessagesListCubit>().state.selectedConversationIds.length;
    return ConfirmationDialog.show<void>(
      context: context,
      title: 'Удаление',
      text: 'Удалить выбранные диалоги?',
      subText: '$count ${_pluralDialogs(count)} исчезнут из списка.',
      buttonTextOne: 'Удалить все',
      buttonTextTwo: 'Оставить',
      buttonTwoColor: AppColor.bgAlt,
      buttonTextStyleTwo: AppTextStyle.button(AppColor.inkSecondary),
      onTapButtonOne: () async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        navigator.pop();
        try {
          await context.read<MessagesListCubit>().deleteSelectedConversations();
          messenger.clearSnackBars();
          messenger.showSnackBar(
            buildWarmSnackBar(
              message: 'Выбранные диалоги удалены',
              icon: Icons.delete_outline_rounded,
            ),
          );
        } catch (_) {
          messenger.clearSnackBars();
          messenger.showSnackBar(
            buildWarmSnackBar(
              message: 'Не удалось удалить диалоги',
              icon: Icons.error_outline_rounded,
            ),
          );
        }
      },
      onTapButtonTwo: () => Navigator.of(context).pop(),
    );
  }

  String _pluralDialogs(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return 'диалог';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'диалога';
    }
    return 'диалогов';
  }

  Future<void> _showConversationActions(
    BuildContext context,
    Conversation conversation,
  ) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Действия с сообщением',
      barrierColor: AppColor.black.withValues(alpha: 0.16),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: _ConversationActionsSheet(
            conversation: conversation,
            onSelect: () {
              Navigator.of(dialogContext).pop();
              final cubit = context.read<MessagesListCubit>();
              cubit.selectConversation(conversation.id);
              showWarmSnackBar(
                context,
                message: 'Диалог выбран',
                icon: Icons.check_rounded,
              );
            },
            onDelete: () {
              Navigator.of(dialogContext).pop();
              _confirmDeleteConversation(context, conversation);
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteConversation(
    BuildContext context,
    Conversation conversation,
  ) {
    return ConfirmationDialog.show<void>(
      context: context,
      title: 'Удаление',
      text: 'Удалить диалог ${conversation.title}?',
      subText: 'Сообщения исчезнут из этого списка.',
      buttonTextOne: 'Удалить',
      buttonTextTwo: 'Оставить',
      buttonTwoColor: AppColor.bgAlt,
      buttonTextStyleTwo: AppTextStyle.button(AppColor.inkSecondary),
      onTapButtonOne: () async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        navigator.pop();
        try {
          await context
              .read<MessagesListCubit>()
              .deleteConversation(conversation.id);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            buildWarmSnackBar(
              message: 'Диалог удалён',
              icon: Icons.delete_outline_rounded,
            ),
          );
        } catch (_) {
          messenger.clearSnackBars();
          messenger.showSnackBar(
            buildWarmSnackBar(
              message: 'Не удалось удалить диалог',
              icon: Icons.error_outline_rounded,
            ),
          );
        }
      },
      onTapButtonTwo: () => Navigator.of(context).pop(),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final MessagesFilter filter;
  final Set<MessagesFilter> enabledFilters;
  final int total;
  final int unread;
  final ValueChanged<MessagesFilter> onSelect;

  const _FilterChips({
    required this.filter,
    required this.enabledFilters,
    required this.total,
    required this.unread,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <_ChipSpec>[
      _ChipSpec(MessagesFilter.all, 'Все', total),
      _ChipSpec(MessagesFilter.unread, 'Непрочитанные', unread),
      _ChipSpec(MessagesFilter.codes, 'Коды', null),
      _ChipSpec(MessagesFilter.banks, 'Банки', null),
      _ChipSpec(MessagesFilter.delivery, 'Доставка', null),
    ].where((entry) => enabledFilters.contains(entry.filter)).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            WarmChip(
              label: entries[i].label,
              count: entries[i].count,
              active: entries[i].filter == filter,
              onTap: () => onSelect(entries[i].filter),
            ),
            if (i < entries.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterSettingsSheet extends StatelessWidget {
  final Set<MessagesFilter> enabledFilters;
  final void Function(MessagesFilter filter, bool enabled) onChanged;

  const _FilterSettingsSheet({
    required this.enabledFilters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const rows = [
      _FilterToggleSpec(
        filter: MessagesFilter.unread,
        icon: Icons.mark_chat_unread_rounded,
        title: 'Непрочитанные',
      ),
      _FilterToggleSpec(
        filter: MessagesFilter.codes,
        icon: Icons.password_rounded,
        title: 'Коды',
      ),
      _FilterToggleSpec(
        filter: MessagesFilter.banks,
        icon: Icons.account_balance_rounded,
        title: 'Банки',
      ),
      _FilterToggleSpec(
        filter: MessagesFilter.delivery,
        icon: Icons.local_shipping_rounded,
        title: 'Доставка',
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Фильтры', style: AppTextStyle.title(AppColor.ink)),
            const SizedBox(height: 14),
            Container(
              decoration: const BoxDecoration(
                color: AppColor.surfaceSoft,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    _FilterToggleRow(
                      spec: rows[i],
                      enabled: enabledFilters.contains(rows[i].filter),
                      onChanged: (enabled) =>
                          onChanged(rows[i].filter, enabled),
                    ),
                    if (i < rows.length - 1)
                      const Divider(
                        height: 1,
                        indent: 58,
                        color: AppColor.divider,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterToggleSpec {
  final MessagesFilter filter;
  final IconData icon;
  final String title;

  const _FilterToggleSpec({
    required this.filter,
    required this.icon,
    required this.title,
  });
}

class _FilterToggleRow extends StatelessWidget {
  final _FilterToggleSpec spec;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _FilterToggleRow({
    required this.spec,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onChanged(!enabled),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: enabled ? AppColor.accentSoft : AppColor.bgAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                spec.icon,
                size: 17,
                color: enabled ? AppColor.accentDeep : AppColor.inkTertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                spec.title,
                style: AppTextStyle.body(AppColor.ink),
              ),
            ),
            Switch.adaptive(
              value: enabled,
              activeThumbColor: AppColor.accent,
              activeTrackColor: AppColor.accentSoft,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationActionsSheet extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const _ConversationActionsSheet({
    required this.conversation,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 14 + bottomInset),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.l,
              border: Border.all(color: AppColor.divider),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColor.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sms_rounded,
                        size: 18,
                        color: AppColor.accentDeep,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.body(AppColor.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            conversation.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.caption(AppColor.inkTertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ConversationActionRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Выбрать',
                  onTap: onSelect,
                ),
                _ConversationActionRow(
                  icon: Icons.delete_outline_rounded,
                  label: 'Удалить',
                  color: AppColor.danger,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onReadAll;
  final VoidCallback onDeleteAll;

  const _SelectionActionBar({
    required this.selectedCount,
    required this.onReadAll,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      offset: selectedCount > 0 ? Offset.zero : const Offset(0, 1.25),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: selectedCount > 0 ? 1 : 0,
        child: IgnorePointer(
          ignoring: selectedCount == 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColor.divider),
              boxShadow: AppShadows.l,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '$selectedCount выбрано',
                    style: AppTextStyle.captionUpper(AppColor.inkTertiary),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SelectionButton(
                        icon: Icons.done_all_rounded,
                        label: 'Прочитать все',
                        onTap: onReadAll,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SelectionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Удалить все',
                        color: AppColor.danger,
                        onTap: onDeleteAll,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SelectionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppColor.accentDeep;
    return PlatformTapScale(
      pressedScale: 0.98,
      child: Material(
        color: resolvedColor.withValues(alpha: 0.1),
        borderRadius: AppRadii.brPill,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brPill,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: resolvedColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmBold(resolvedColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ConversationActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppColor.ink;
    return PlatformTapScale(
      pressedScale: 0.98,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.brR2,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brR2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 20, color: resolvedColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyle.body(resolvedColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipSpec {
  final MessagesFilter filter;
  final String label;
  final int? count;
  _ChipSpec(this.filter, this.label, this.count);
}

class _ProfileBubble extends StatelessWidget {
  const _ProfileBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.accent, AppColor.accentDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person_outline_rounded,
          color: AppColor.white, size: 22),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColor.accent),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final MessagesFilter filter;
  final String query;
  const _EmptyView({required this.filter, required this.query});

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _copy();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColor.accentDeep, size: 38),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: AppTextStyle.title(AppColor.ink)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodySm(AppColor.inkTertiary)),
          ],
        ),
      ),
    );
  }

  (String, String) _copy() {
    if (query.isNotEmpty) {
      return (
        'Ничего не найдено',
        'Попробуйте изменить запрос или сбросить фильтр.',
      );
    }
    switch (filter) {
      case MessagesFilter.all:
        return (
          'Сообщений пока нет',
          'Они появятся здесь, как только устройство получит SMS.',
        );
      case MessagesFilter.unread:
        return ('Всё прочитано', 'Новых сообщений нет.');
      case MessagesFilter.codes:
        return (
          'Кодов не найдено',
          'Сообщения с одноразовыми кодами появятся в этом списке.',
        );
      case MessagesFilter.banks:
        return (
          'Нет сообщений от банков',
          'Категория автоматически определится из текста.',
        );
      case MessagesFilter.delivery:
        return (
          'Нет сообщений о доставке',
          'Они подтянутся, когда придут уведомления курьеров.',
        );
    }
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
