import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/models/device.dart';
import 'package:simply/screens/devices/cubit/device_cubit.dart';
import 'package:simply/screens/devices/settings/device_settings_modal.dart';
import 'package:simply/screens/devices/widget/device_widget.dart';
import 'package:simply/screens/widget/dialogs/confirmation_dialog.dart';
import 'package:simply/screens/widget/warm/warm_header.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<DeviceCubit>();
      if (cubit.state.status == DeviceStatus.initial) {
        cubit.fetch();
      }
    });
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
        return const Center(
          child: CircularProgressIndicator(color: AppColor.accent),
        );
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
                  device: state.items[i],
                  isCurrentDevice:
                      state.items[i].deviceId == state.currentDeviceId,
                  canMoveUp: i > 0,
                  canMoveDown: i < state.items.length - 1,
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
    final todayMessages =
        devices.fold<int>(0, (sum, item) => sum + item.todayMessageCount);
    final onlineDevices = devices.where((device) => device.isOnline).length;
    final totalSims = devices
        .where((device) => !device.isReceiverOnly)
        .fold<int>(0, (sum, item) => sum + item.resolvedSimCount);
    final senderDevices =
        devices.where((device) => !device.isReceiverOnly).length;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColor.surface, AppColor.surfaceSoft],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadii.brR4,
          boxShadow: AppShadows.m,
          border: Border.all(color: AppColor.accent.withValues(alpha: 0.16)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(1.08, -0.92),
                      radius: 0.82,
                      colors: [
                        AppColor.accent.withValues(alpha: 0.22),
                        AppColor.accent.withValues(alpha: 0.08),
                        AppColor.accent.withValues(alpha: 0.0),
                      ],
                      stops: const [0, 0.42, 1],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'СЕГОДНЯ',
                  style: AppTextStyle.captionUpper(AppColor.inkTertiary),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$todayMessages',
                        style:
                            AppTextStyle.display(AppColor.accentDeep).copyWith(
                          fontSize: 56,
                          height: 0.92,
                        ),
                      ),
                      TextSpan(
                        text: ' сообщений',
                        style: AppTextStyle.title(AppColor.inkSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Синхронизировано со всех подключённых устройств',
                  style: AppTextStyle.bodySm(AppColor.inkSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _HeroMetric(
                        label: 'УСТРОЙСТВА',
                        value: '$onlineDevices/${devices.length}',
                        trailingDot: true,
                      ),
                    ),
                    Expanded(
                      child: _HeroMetric(
                        label: 'SIM',
                        value: '${totalSims > 0 ? totalSims : senderDevices}',
                      ),
                    ),
                    const Expanded(
                      child: _HeroMetric(
                        label: 'СИНХР.',
                        value: 'авто',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool trailingDot;

  const _HeroMetric({
    required this.label,
    required this.value,
    this.trailingDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColor.bgAlt.withValues(alpha: 0.72),
        borderRadius: AppRadii.brR2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.micro(AppColor.inkTertiary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (trailingDot) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColor.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.title(AppColor.ink),
                ),
              ),
            ],
          ),
        ],
      ),
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
