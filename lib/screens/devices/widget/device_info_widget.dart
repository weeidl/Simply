import 'package:flutter/material.dart';
import 'package:simply/models/device.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

/// Three-column live stats footer: battery, signal, sync count.
class DeviceInfoWidget extends StatelessWidget {
  final Device device;
  final bool online;

  const DeviceInfoWidget({
    super.key,
    required this.device,
    this.online = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _BatteryStat(
            level: device.batteryLevel,
            online: online,
          ),
        ),
        const _StatDivider(),
        Expanded(
          child: _SignalStat(
            type: device.networkType,
            online: online,
          ),
        ),
        const _StatDivider(),
        const Expanded(child: _SyncStat()),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColor.divider,
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String label;
  const _StatLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyle.micro(AppColor.inkTertiary).copyWith(
        letterSpacing: 0.4,
      ),
    );
  }
}

class _BatteryStat extends StatelessWidget {
  final int? level;
  final bool online;

  const _BatteryStat({required this.level, required this.online});

  @override
  Widget build(BuildContext context) {
    final value = level?.clamp(0, 100);
    final ratio = value == null ? 0.0 : value / 100.0;
    final fill = !online
        ? AppColor.inkPlaceholder
        : (value != null && value <= 20
            ? AppColor.danger
            : (value != null && value <= 40
                ? AppColor.amber
                : AppColor.success));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatLabel('БАТАРЕЯ'),
        const SizedBox(height: 6),
        Text(
          value != null ? '$value%' : '—',
          style: AppTextStyle.titleSm(AppColor.ink),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(
                height: 4,
                color: AppColor.bg,
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 4,
                  color: fill,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignalStat extends StatelessWidget {
  final String? type;
  final bool online;

  const _SignalStat({required this.type, required this.online});

  @override
  Widget build(BuildContext context) {
    final bars = _bars(type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatLabel('СЕТЬ'),
        const SizedBox(height: 6),
        Text(
          (type == null || type!.isEmpty) ? '—' : type!.toUpperCase(),
          style: AppTextStyle.titleSm(AppColor.ink),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (i) {
            final active = online && i < bars;
            return Padding(
              padding: EdgeInsets.only(right: i == 3 ? 0 : 3),
              child: Container(
                width: 4,
                height: 4.0 + i * 3,
                decoration: BoxDecoration(
                  color: active ? AppColor.accent : AppColor.bg,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  int _bars(String? type) {
    if (type == null || type.isEmpty) return 0;
    final t = type.toLowerCase();
    if (t.contains('5g')) return 4;
    if (t.contains('lte') || t.contains('4g')) return 3;
    if (t.contains('3g')) return 2;
    if (t.contains('wifi') || t.contains('wi-fi')) return 4;
    return 1;
  }
}

class _SyncStat extends StatelessWidget {
  const _SyncStat();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatLabel('СИНХР.'),
        const SizedBox(height: 6),
        Text(
          'В реал-тайм',
          style: AppTextStyle.titleSm(AppColor.ink),
        ),
        const SizedBox(height: 8),
        Row(
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
            Flexible(
              child: Text(
                'активна',
                style: AppTextStyle.micro(AppColor.inkTertiary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
