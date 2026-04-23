import 'package:flutter/material.dart';
import 'package:simply/models/device.dart';
import 'package:simply/models/device_sim_card.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

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
    if (!device.supportsRuntimeDetails) {
      return _ReceiverOnlyBody(device: device, online: online);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _TodayStat(device: device)),
            const _StatDivider(),
            Expanded(
              child: _BatteryStat(
                level: device.batteryLevel,
                online: online,
              ),
            ),
            const _StatDivider(),
            Expanded(
              child: _SimStat(
                device: device,
                online: online,
              ),
            ),
          ],
        ),
        if (device.simCards.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColor.divider),
          const SizedBox(height: 14),
          for (var i = 0; i < device.simCards.length; i++) ...[
            _SimRow(
              card: device.simCards[i],
              online: online,
              networkType: device.networkType,
            ),
            if (i < device.simCards.length - 1) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColor.divider),
              const SizedBox(height: 10),
            ],
          ],
        ],
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
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 12),
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
        letterSpacing: 0.8,
      ),
    );
  }
}

class _TodayStat extends StatelessWidget {
  final Device device;

  const _TodayStat({required this.device});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatLabel('СЕГОДНЯ'),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${device.todayMessageCount}',
                style: AppTextStyle.h1(AppColor.accentDeep),
              ),
              TextSpan(
                text: ' SMS',
                style: AppTextStyle.bodySm(AppColor.inkTertiary).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Sparkline(values: device.normalizedSparkline),
      ],
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<int> values;

  const _Sparkline({required this.values});

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(0, (current, value) {
      return value > current ? value : current;
    });

    return SizedBox(
      height: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: maxValue == 0
                      ? 4
                      : 4 + ((values[i] / maxValue) * 18).roundToDouble(),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.accent.withValues(alpha: 0.35),
                        AppColor.accentDeep,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            if (i < values.length - 1) const SizedBox(width: 4),
          ],
        ],
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
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              value != null ? '$value%' : '—',
              style: AppTextStyle.h1(AppColor.ink),
            ),
            const SizedBox(width: 6),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: fill.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.bolt_rounded,
                size: 14,
                color: fill,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: AppColor.bg,
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 6,
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

class _SimStat extends StatelessWidget {
  final Device device;
  final bool online;

  const _SimStat({
    required this.device,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    final activeSlot = device.activeSimSlot;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatLabel('SIM'),
        const SizedBox(height: 8),
        Text(
          device.simLabel,
          style: AppTextStyle.h1(AppColor.ink),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _MiniPill(
              label: activeSlot != null ? 'SIM $activeSlot' : 'авто',
              active: online,
            ),
            if ((device.networkType?.trim().isNotEmpty ?? false))
              _MiniPill(
                label: device.networkType!.toUpperCase(),
                active: online,
              ),
          ],
        ),
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final bool active;

  const _MiniPill({
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? AppColor.accentSoft
            : AppColor.bgAlt.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyle.micro(
          active ? AppColor.accentDeep : AppColor.inkTertiary,
        ),
      ),
    );
  }
}

class _SimRow extends StatelessWidget {
  final DeviceSimCard card;
  final bool online;
  final String? networkType;

  const _SimRow({
    required this.card,
    required this.online,
    required this.networkType,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel =
        card.isActive ? (networkType?.toUpperCase() ?? 'АКТИВНА') : 'ГОТОВА';

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColor.bgAlt,
            borderRadius: AppRadii.brR1,
          ),
          alignment: Alignment.center,
          child: Text(
            '${card.slot}',
            style: AppTextStyle.bodySmBold(AppColor.inkSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  card.label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body(AppColor.ink),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: card.isActive
                      ? AppColor.success
                      : AppColor.inkPlaceholder,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 4; i++) ...[
              Container(
                width: 3,
                height: 5.0 + (i * 3),
                margin: EdgeInsets.only(right: i == 3 ? 6 : 2),
                decoration: BoxDecoration(
                  color: online && card.isActive && i >= 1
                      ? AppColor.success
                      : AppColor.bgAlt,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
            Text(
              statusLabel,
              style: AppTextStyle.micro(AppColor.inkTertiary),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReceiverOnlyBody extends StatelessWidget {
  final Device device;
  final bool online;

  const _ReceiverOnlyBody({
    required this.device,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.bgAlt.withValues(alpha: 0.72),
        borderRadius: AppRadii.brR2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Только получает сообщения',
            style: AppTextStyle.titleSm(AppColor.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Для iPhone показываем только имя, платформу и статус устройства.',
            style: AppTextStyle.bodySm(AppColor.inkTertiary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: device.platformLabel, active: false),
              _MiniPill(
                label: online ? 'в сети' : 'приём',
                active: online,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
