import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/l10n/app_localizations.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/screens/messages_list/cubit/messages_list_cubit.dart';
import 'package:simply/screens/messages_list/widget/messages_list_widget.dart';
import 'package:simply/screens/widget/dialogs/confirmation_dialog.dart';
import 'package:simply/screens/widget/platform_tap_scale.dart';
import 'package:simply/screens/widget/warm/warm_chip.dart';
import 'package:simply/screens/widget/warm/warm_header.dart';
import 'package:simply/screens/widget/warm/warm_loader.dart';
import 'package:simply/screens/widget/warm/warm_search_field.dart';
import 'package:simply/screens/widget/warm/warm_toast.dart';
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
        final l10n = AppLocalizations.of(context)!;
        final filtered = state.filteredItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WarmHeader(
              eyebrow: _eyebrow(state, l10n),
              title: l10n.messages,
              trailing: const _ProfileBubble(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: WarmSearchField(
                hint: l10n.search,
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

  String _eyebrow(MessagesListState state, AppLocalizations l10n) {
    if (state.unreadCount == 0) {
      return state.totalCount == 0
          ? l10n.yourSms
          : l10n.messagesEyebrowArchive(state.totalCount);
    }
    return l10n.messagesEyebrowUnread(state.unreadCount);
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const navBarHeight = 68.0;
    return Stack(
      children: [
        RefreshIndicator(
          color: AppColor.accent,
          onRefresh: () => context.read<MessagesListCubit>().refresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              12,
              6,
              12,
              bottomInset + navBarHeight + (state.isSelectionMode ? 120 : 24),
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
          bottom: bottomInset + navBarHeight + 14,
          child: _SelectionActionBar(
            selectedCount: state.selectedConversationIds.length,
            onReadAll: () => _markSelectedRead(context),
            onDeleteAll: () => _confirmDeleteSelected(context),
            onClear: () => context.read<MessagesListCubit>().clearSelection(),
          ),
        ),
      ],
    );
  }

  Future<void> _markSelectedRead(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await context.read<MessagesListCubit>().markSelectedRead();
    if (!context.mounted) return;
    WarmToast.success(
      context,
      l10n.markedReadToast,
      icon: Icons.done_all_rounded,
    );
  }

  Future<void> _confirmDeleteSelected(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count =
        context.read<MessagesListCubit>().state.selectedConversationIds.length;
    return ConfirmationDialog.show<void>(
      context: context,
      title: l10n.deleteTitle,
      leadingIcon: Icons.delete_sweep_rounded,
      leadingIconColor: AppColor.danger,
      text: l10n.deleteConfirmation,
      subText: l10n.selectedDialogsDisappear(count),
      buttonTextOne: l10n.deleteButton,
      buttonTextTwo: l10n.keep,
      buttonTwoColor: AppColor.bgAlt,
      buttonTextStyleTwo: AppTextStyle.button(AppColor.inkSecondary),
      onTapButtonOne: () async {
        final navigator = Navigator.of(context);
        navigator.pop();
        try {
          await context.read<MessagesListCubit>().deleteSelectedConversations();
          if (!context.mounted) return;
          WarmToast.success(
            context,
            l10n.selectedConversationsDeleted,
            icon: Icons.delete_outline_rounded,
          );
        } catch (_) {
          if (!context.mounted) return;
          WarmToast.error(context, l10n.failedToDeleteMany);
        }
      },
      onTapButtonTwo: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _showConversationActions(
    BuildContext context,
    Conversation conversation,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.conversationActionsSheet,
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
              WarmToast.success(context, l10n.conversationSelectedToast);
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
    final l10n = AppLocalizations.of(context)!;
    return ConfirmationDialog.show<void>(
      context: context,
      title: l10n.deleteTitle,
      leadingIcon: Icons.delete_outline_rounded,
      leadingIconColor: AppColor.danger,
      text: l10n.deleteConfirmationSingle(conversation.title),
      subText: l10n.messagesWillDisappear,
      buttonTextOne: l10n.delete,
      buttonTextTwo: l10n.keep,
      buttonTwoColor: AppColor.bgAlt,
      buttonTextStyleTwo: AppTextStyle.button(AppColor.inkSecondary),
      onTapButtonOne: () async {
        final navigator = Navigator.of(context);
        navigator.pop();
        try {
          await context
              .read<MessagesListCubit>()
              .deleteConversation(conversation.id);
          if (!context.mounted) return;
          WarmToast.success(
            context,
            l10n.conversationDeleted,
            icon: Icons.delete_outline_rounded,
          );
        } catch (_) {
          if (!context.mounted) return;
          WarmToast.error(context, l10n.failedToDelete);
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
    final l10n = AppLocalizations.of(context)!;
    final entries = <_ChipSpec>[
      _ChipSpec(MessagesFilter.all, l10n.allFilter, total),
      _ChipSpec(MessagesFilter.unread, l10n.unread, unread),
      _ChipSpec(MessagesFilter.codes, l10n.codes, null),
      _ChipSpec(MessagesFilter.banks, l10n.banks, null),
      _ChipSpec(MessagesFilter.delivery, l10n.delivery, null),
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
    final l10n = AppLocalizations.of(context)!;
    final rows = [
      _FilterToggleSpec(
        filter: MessagesFilter.unread,
        icon: Icons.mark_chat_unread_rounded,
        title: l10n.unread,
      ),
      _FilterToggleSpec(
        filter: MessagesFilter.codes,
        icon: Icons.password_rounded,
        title: l10n.codes,
      ),
      _FilterToggleSpec(
        filter: MessagesFilter.banks,
        icon: Icons.account_balance_rounded,
        title: l10n.banks,
      ),
      _FilterToggleSpec(
        filter: MessagesFilter.delivery,
        icon: Icons.local_shipping_rounded,
        title: l10n.delivery,
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
            Text(l10n.filters, style: AppTextStyle.title(AppColor.ink)),
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
    final l10n = AppLocalizations.of(context)!;
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
                  label: l10n.select,
                  onTap: onSelect,
                ),
                _ConversationActionRow(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.delete,
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
  final VoidCallback onClear;

  const _SelectionActionBar({
    required this.selectedCount,
    required this.onReadAll,
    required this.onDeleteAll,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = selectedCount > 0;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, 1.4),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
                Row(
                  children: [
                    _ClearSelectionButton(onTap: onClear),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.selectedCount(selectedCount),
                        style: AppTextStyle.bodySmBold(AppColor.ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SelectionButton(
                        icon: Icons.done_all_rounded,
                        label: l10n.readAll,
                        onTap: onReadAll,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SelectionButton(
                        icon: Icons.delete_outline_rounded,
                        label: l10n.deleteAll,
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

class _ClearSelectionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ClearSelectionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PlatformTapScale(
      pressedScale: 0.94,
      child: Material(
        color: AppColor.bgAlt,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColor.inkSecondary,
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
    return const Center(child: WarmLoader(size: 28));
  }
}

class _EmptyView extends StatelessWidget {
  final MessagesFilter filter;
  final String query;
  const _EmptyView({required this.filter, required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (title, subtitle) = _copy(l10n);
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

  (String, String) _copy(AppLocalizations l10n) {
    if (query.isNotEmpty) {
      return (l10n.notFound, l10n.tryChangingQuery);
    }
    switch (filter) {
      case MessagesFilter.all:
        return (l10n.noMessagesYet, l10n.hereWhenSmsArrives);
      case MessagesFilter.unread:
        return (l10n.allRead, l10n.noNewMessages);
      case MessagesFilter.codes:
        return (l10n.noCodes, l10n.codesHint);
      case MessagesFilter.banks:
        return (l10n.noBanks, l10n.categoryAuto);
      case MessagesFilter.delivery:
        return (l10n.noDelivery, l10n.deliveryHint);
    }
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.failedToLoad, style: AppTextStyle.title(AppColor.ink)),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColor.accent),
            onPressed: onRetry,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
