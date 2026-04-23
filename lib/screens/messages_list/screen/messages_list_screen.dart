import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/conversation.dart';
import 'package:simply/screens/messages_list/cubit/messages_list_cubit.dart';
import 'package:simply/screens/messages_list/widget/messages_list_widget.dart';
import 'package:simply/screens/widget/warm/warm_chip.dart';
import 'package:simply/screens/widget/warm/warm_header.dart';
import 'package:simply/screens/widget/warm/warm_search_field.dart';
import 'package:simply/themes/colors.dart';
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: WarmSearchField(
                hint: 'Поиск по сообщениям',
                trailingIcon: Icons.tune_rounded,
                onChanged: cubit.setQuery,
              ),
            ),
            _FilterChips(
              filter: state.filter,
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
    return RefreshIndicator(
      color: AppColor.accent,
      onRefresh: () => context.read<MessagesListCubit>().refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
        itemCount: filtered.length,
        itemBuilder: (context, index) =>
            MessagesListWidget(conversation: filtered[index]),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final MessagesFilter filter;
  final int total;
  final int unread;
  final ValueChanged<MessagesFilter> onSelect;

  const _FilterChips({
    required this.filter,
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
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
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
              decoration: BoxDecoration(
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
