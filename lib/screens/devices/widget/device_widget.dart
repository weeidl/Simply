import 'package:flutter/material.dart';
import 'package:simply/extensions.dart';
import 'package:simply/models/device.dart';
import 'package:simply/screens/devices/settings/device_settings_modal.dart';
import 'package:simply/screens/devices/widget/device_info_widget.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

/// Top-level device card. The header (avatar + name + status) lives directly
/// inside; the live-stats grid sits in a tinted footer below.
class DeviceWidget extends StatelessWidget {
  final Device device;

  const DeviceWidget({super.key, required this.device});

  bool get _online => device.dateUpdateInfo != null &&
      DateTime.now()
              .difference(device.dateUpdateInfo!.toDate())
              .inMinutes <
          15;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      borderRadius: AppRadii.brR4,
      child: InkWell(
        borderRadius: AppRadii.brR4,
        onTap: () =>
            DeviceSettingsModal.show(context: context, device: device),
        child: Opacity(
          opacity: _online ? 1 : 0.78,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.brR4,
              boxShadow: AppShadows.s,
              border: Border.all(color: const Color(0x0A281910)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PhoneThumbnail(online: _online),
                      const SizedBox(width: 14),
                      Expanded(child: _header(context)),
                      const Icon(Icons.more_horiz_rounded,
                          color: AppColor.inkPlaceholder, size: 18),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                  decoration: BoxDecoration(
                    color: AppColor.bgAlt,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadii.r4),
                      bottomRight: Radius.circular(AppRadii.r4),
                    ),
                    border: const Border(
                      top: BorderSide(color: AppColor.divider, width: 1),
                    ),
                  ),
                  child: DeviceInfoWidget(device: device, online: _online),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                device.deviceName,
                style: AppTextStyle.titleSm(AppColor.ink),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (device.isMainDevice) ...[
              const SizedBox(width: 8),
              const _MainBadge(),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(_osLabel(),
            style: AppTextStyle.caption(AppColor.inkTertiary)),
        const SizedBox(height: 8),
        _StatusPill(online: _online, lastSeen: device.dateUpdateInfo?.toDate()),
      ],
    );
  }

  String _osLabel() {
    final p = device.platform?.toLowerCase();
    if (p == null || p.isEmpty) return 'Устройство';
    if (p.contains('ios')) return 'iOS';
    if (p.contains('android')) return 'Android';
    return p;
  }
}

class _MainBadge extends StatelessWidget {
  const _MainBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColor.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('ГЛАВНОЕ',
          style: AppTextStyle.micro(AppColor.accentDeep)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool online;
  final DateTime? lastSeen;

  const _StatusPill({required this.online, this.lastSeen});

  @override
  Widget build(BuildContext context) {
    final bg = online ? AppColor.successSoft : AppColor.bgAlt;
    final dot = online ? AppColor.success : AppColor.inkPlaceholder;
    final fg = online ? const Color(0xFF1A7F4B) : AppColor.inkTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: online
                  ? [
                      BoxShadow(
                        color: AppColor.success.withValues(alpha: 0.13),
                        blurRadius: 0,
                        spreadRadius: 3,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            online
                ? 'В сети'
                : (lastSeen != null
                    ? 'Был ${lastSeen!.formatRelativeShort()}'
                    : 'Не в сети'),
            style: AppTextStyle.micro(fg).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneThumbnail extends StatelessWidget {
  final bool online;
  const _PhoneThumbnail({required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 72,
      decoration: BoxDecoration(
        color: AppColor.accentSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0A281910)),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 30,
        height: 54,
        decoration: BoxDecoration(
          color: AppColor.black,
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 22,
          height: 38,
          decoration: BoxDecoration(
            gradient: online
                ? LinearGradient(
                    colors: [AppColor.accent, AppColor.accentDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: online ? null : AppColor.inkSecondary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
