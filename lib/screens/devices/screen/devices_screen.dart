import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/extensions.dart';
import 'package:simply/models/device.dart';
import 'package:simply/screens/devices/cubit/device_cubit.dart';
import 'package:simply/screens/devices/settings/device_settings_modal.dart';
import 'package:simply/screens/devices/widget/device_widget.dart';
import 'package:simply/screens/widget/dialogs/confirmation_dialog.dart';
import 'package:simply/screens/widget/warm/warm_header.dart';
import 'package:simply/screens/widget/warm/warm_loader.dart';
import 'package:simply/services/ui_preferences_service.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class DevicesScreen extends StatefulWidget {
  final UiPreferencesService? uiPreferencesService;

  const DevicesScreen({super.key, this.uiPreferencesService});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late final UiPreferencesService _uiPrefs;
  Set<String> _pinnedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _uiPrefs = widget.uiPreferencesService ?? UiPreferencesService();
    _loadPinnedIds();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<DeviceCubit>();
      if (cubit.state.status == DeviceStatus.initial) {
        cubit.fetch();
      }
    });
  }

  Future<void> _loadPinnedIds() async {
    final ids = await _uiPrefs.readPinnedExpandedDeviceIds();
    if (!mounted) return;
    setState(() => _pinnedIds = ids);
  }

  void _togglePin(String deviceId) {
    setState(() {
      final next = {..._pinnedIds};
      if (next.contains(deviceId)) {
        next.remove(deviceId);
      } else {
        next.add(deviceId);
      }
      _pinnedIds = next;
    });
    _uiPrefs.writePinnedExpandedDeviceIds(_pinnedIds);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WarmHeader(
              eyebrow: _eyebrow(state),
              title: 'Устройства',
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              trailing: _AddButton(
                onTap: () => DeviceSettingsModal.show(context: context),
              ),
            ),
            Expanded(child: _content(context, state)),
          ],
        );
      },
    );
  }

  String _eyebrow(DeviceState state) {
    if (state.items.isEmpty) return 'Подключите свой первый телефон';
    final senders =
        state.items.where((device) => !device.isReceiverOnly).length;
    return '${state.items.length} устройств · $senders отправляют SMS';
  }

  Widget _content(BuildContext context, DeviceState state) {
    switch (state.status) {
      case DeviceStatus.initial:
      case DeviceStatus.loading:
        return const Center(child: WarmLoader(size: 28));
      case DeviceStatus.error:
        return _ErrorView(
          onRetry: () => context.read<DeviceCubit>().fetch(),
        );
      case DeviceStatus.empty:
        return const _EmptyView();
      case DeviceStatus.loaded:
        if (state.items.isEmpty) return const _EmptyView();
        return RefreshIndicator(
          color: AppColor.accent,
          onRefresh: () => context.read<DeviceCubit>().updateDevice(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 104),
            children: [
              _FleetSummaryCard(devices: state.items),
              const SizedBox(height: 20),
              _SectionHeader(count: state.items.length),
              const SizedBox(height: 12),
              for (var i = 0; i < state.items.length; i++) ...[
                DeviceWidget(
                  key: ValueKey(state.items[i].deviceId),
                  device: state.items[i],
                  isCurrentDevice:
                      state.items[i].deviceId == state.currentDeviceId,
                  canMoveUp: i > 0,
                  canMoveDown: i < state.items.length - 1,
                  isPinned: _pinnedIds.contains(state.items[i].deviceId),
                  onTogglePin: () => _togglePin(state.items[i].deviceId),
                  onReconnect: () => DeviceSettingsModal.show(
                    context: context,
                    device: state.items[i],
                  ),
                  onMoveUp: () => context
                      .read<DeviceCubit>()
                      .moveUp(state.items[i].deviceId),
                  onMoveDown: () => context
                      .read<DeviceCubit>()
                      .moveDown(state.items[i].deviceId),
                  onDelete: () => _confirmDelete(context, state.items[i]),
                  animationIndex: i,
                ),
                if (i < state.items.length - 1) const SizedBox(height: 14),
              ],
            ],
          ),
        );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Device device) {
    return ConfirmationDialog.show<void>(
      context: context,
      title: 'Устройство',
      leadingIcon: Icons.delete_outline_rounded,
      leadingIconColor: AppColor.danger,
      text: 'Удалить ${device.deviceName} из списка устройств?',
      subText:
          'Устройство исчезнет из списка, но его можно будет подключить снова.',
      buttonTextOne: 'Удалить',
      onTapButtonOne: () async {
        Navigator.of(context).pop();
        await context.read<DeviceCubit>().deleteDevice(device.deviceId);
      },
      buttonTextTwo: 'Отмена',
      onTapButtonTwo: () => Navigator.of(context).pop(),
      buttonTwoColor: AppColor.bgAlt,
      buttonTextStyleTwo: AppTextStyle.button(AppColor.accentDeep),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final int count;

  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'ВСЕ УСТРОЙСТВА',
          style: AppTextStyle.captionUpper(AppColor.inkTertiary),
        ),
        const Spacer(),
        Text(
          '$count',
          style: AppTextStyle.bodySmBold(AppColor.inkTertiary),
        ),
      ],
    );
  }
}

class _FleetSummaryCard extends StatelessWidget {
  final List<Device> devices;

  const _FleetSummaryCard({required this.devices});

  @override
  Widget build(BuildContext context) {
    final senders = devices.where((d) => !d.isReceiverOnly).toList();
    final todayMessages =
        devices.fold<int>(0, (sum, item) => sum + item.todayMessageCount);
    final onlineDevices = devices.where((device) => device.isOnline).length;
    final offlineDevices = devices.length - onlineDevices;
    final lowBatteryDevices = senders
        .where((d) => d.batteryLevel != null && d.batteryLevel! <= 20)
        .length;
    final fleetSparkline = _aggregatedSparkline(devices);
    final hasAnyActivity = fleetSparkline.any((value) => value > 0);
    final leader = _leader(senders);
    final lastActivity = _lastActivity(devices);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColor.surface, AppColor.surfaceSoft],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadii.brR4,
          boxShadow: AppShadows.s,
          border: Border.all(color: AppColor.accent.withValues(alpha: 0.14)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'СЕГОДНЯ',
                        style: AppTextStyle.micro(AppColor.inkTertiary),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$todayMessages',
                              style: AppTextStyle.display(AppColor.accentDeep)
                                  .copyWith(fontSize: 30, height: 1),
                            ),
                            TextSpan(
                              text: ' SMS',
                              style:
                                  AppTextStyle.bodySmBold(AppColor.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasAnyActivity) ...[
                  SizedBox(
                    width: 72,
                    height: 32,
                    child: _FleetSparkline(values: fleetSparkline),
                  ),
                  const SizedBox(width: 14),
                ],
                _OnlineBadge(
                  online: onlineDevices,
                  total: devices.length,
                  offline: offlineDevices,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColor.divider),
            const SizedBox(height: 10),
            _FleetInsights(
              leader: leader,
              lastActivity: lastActivity,
              lowBatteryCount: lowBatteryDevices,
              totalMessages: todayMessages,
              senderCount: senders.length,
            ),
          ],
        ),
      ),
    );
  }

  static List<int> _aggregatedSparkline(List<Device> devices) {
    const slots = 6;
    final result = List<int>.filled(slots, 0);
    for (final device in devices) {
      final spark = device.normalizedSparkline;
      for (var i = 0; i < slots && i < spark.length; i++) {
        result[i] += spark[i];
      }
    }
    return result;
  }

  static Device? _leader(List<Device> senders) {
    if (senders.isEmpty) return null;
    Device? best;
    for (final device in senders) {
      if (device.todayMessageCount <= 0) continue;
      if (best == null || device.todayMessageCount > best.todayMessageCount) {
        best = device;
      }
    }
    return best;
  }

  static DateTime? _lastActivity(List<Device> devices) {
    DateTime? best;
    for (final device in devices) {
      final ts = device.lastMessageAt?.toDate();
      if (ts == null) continue;
      if (best == null || ts.isAfter(best)) best = ts;
    }
    return best;
  }
}

class _FleetInsights extends StatelessWidget {
  final Device? leader;
  final DateTime? lastActivity;
  final int lowBatteryCount;
  final int totalMessages;
  final int senderCount;

  const _FleetInsights({
    required this.leader,
    required this.lastActivity,
    required this.lowBatteryCount,
    required this.totalMessages,
    required this.senderCount,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (lowBatteryCount > 0) {
      chips.add(_InsightChip(
        icon: Icons.battery_alert_rounded,
        label: 'Низкий заряд · $lowBatteryCount',
        tone: _ChipTone.danger,
      ));
    }

    if (leader != null) {
      chips.add(_InsightChip(
        icon: Icons.workspace_premium_rounded,
        label: '${leader!.deviceName} · ${leader!.todayMessageCount}',
        tone: _ChipTone.accent,
      ));
    }

    if (lastActivity != null) {
      chips.add(_InsightChip(
        icon: Icons.schedule_rounded,
        label: 'Посл. ${lastActivity!.formatRelativeShort()}',
        tone: _ChipTone.neutral,
      ));
    } else if (senderCount > 0 && totalMessages == 0) {
      chips.add(const _InsightChip(
        icon: Icons.hourglass_empty_rounded,
        label: 'Ждём первое SMS',
        tone: _ChipTone.neutral,
      ));
    }

    if (chips.isEmpty) {
      chips.add(const _InsightChip(
        icon: Icons.devices_rounded,
        label: 'Подключите отправителя',
        tone: _ChipTone.neutral,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}

enum _ChipTone { neutral, accent, danger }

class _InsightChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final _ChipTone tone;

  const _InsightChip({
    required this.icon,
    required this.label,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (tone) {
      case _ChipTone.danger:
        bg = AppColor.danger.withValues(alpha: 0.1);
        fg = AppColor.danger;
        break;
      case _ChipTone.accent:
        bg = AppColor.accentSoft;
        fg = AppColor.accentDeep;
        break;
      case _ChipTone.neutral:
        bg = AppColor.bgAlt.withValues(alpha: 0.7);
        fg = AppColor.inkSecondary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.caption(fg).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FleetSparkline extends StatelessWidget {
  final List<int> values;

  const _FleetSparkline({required this.values});

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(0, (m, v) => v > m ? v : m);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: maxValue == 0
                    ? 4
                    : 4 + ((values[i] / maxValue) * 26).roundToDouble(),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColor.accentGlow, AppColor.accentDeep],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          if (i < values.length - 1) const SizedBox(width: 3),
        ],
      ],
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  final int online;
  final int total;
  final int offline;

  const _OnlineBadge({
    required this.online,
    required this.total,
    required this.offline,
  });

  @override
  Widget build(BuildContext context) {
    final allOnline = online == total && total > 0;
    final dotColor = total == 0
        ? AppColor.inkPlaceholder
        : (allOnline ? AppColor.success : AppColor.amber);
    final subtitleColor =
        offline > 0 ? AppColor.amber : AppColor.inkTertiary;
    final subtitle = offline > 0 ? '$offline оффлайн' : 'в сети';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: allOnline
                    ? [
                        BoxShadow(
                          color: AppColor.success.withValues(alpha: 0.28),
                          blurRadius: 0,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$online/$total',
              style: AppTextStyle.bodySmBold(AppColor.ink),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyle.micro(subtitleColor),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.accent,
      borderRadius: AppRadii.brPill,
      child: InkWell(
        borderRadius: AppRadii.brPill,
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brPill,
            boxShadow: AppShadows.accent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: AppColor.white),
              const SizedBox(width: 4),
              Text('Добавить', style: AppTextStyle.button(AppColor.white)),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColor.accent, AppColor.accentDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadii.brR3,
                boxShadow: AppShadows.accent,
              ),
              child: const Icon(
                Icons.devices_other_rounded,
                color: AppColor.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Пока нет устройств',
              style: AppTextStyle.title(AppColor.ink),
            ),
            const SizedBox(height: 6),
            Text(
              'Подключите Android как отправитель или iPhone как устройство только для приёма.',
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
