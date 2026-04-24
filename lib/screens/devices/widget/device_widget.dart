import 'package:flutter/material.dart';
import 'package:simply/extensions.dart';
import 'package:simply/models/device.dart';
import 'package:simply/screens/devices/widget/device_card_actions.dart';
import 'package:simply/screens/devices/widget/device_info_widget.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class DeviceWidget extends StatefulWidget {
  final Device device;
  final int animationIndex;
  final bool isCurrentDevice;
  final bool canMoveUp;
  final bool canMoveDown;
  final bool isPinned;
  final VoidCallback onTogglePin;
  final VoidCallback onReconnect;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  const DeviceWidget({
    super.key,
    required this.device,
    this.animationIndex = 0,
    required this.isCurrentDevice,
    required this.canMoveUp,
    required this.canMoveDown,
    this.isPinned = false,
    required this.onTogglePin,
    required this.onReconnect,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  @override
  State<DeviceWidget> createState() => _DeviceWidgetState();
}

class _DeviceWidgetState extends State<DeviceWidget> {
  late bool _expanded = widget.isPinned;

  bool get _online => widget.device.isOnline;

  @override
  void didUpdateWidget(covariant DeviceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPinned && !oldWidget.isPinned) {
      setState(() => _expanded = true);
    }
  }

  void _toggle() {
    if (widget.isPinned) return;
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (widget.animationIndex * 45)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadii.brR4,
          boxShadow: AppShadows.s,
          border: Border.all(
            color: widget.device.isMainDevice
                ? AppColor.accent.withValues(alpha: 0.28)
                : const Color(0x12281910),
          ),
        ),
        child: Material(
          color: AppColor.surface,
          borderRadius: AppRadii.brR4,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _toggle,
            splashColor: AppColor.accentSoft.withValues(alpha: 0.35),
            highlightColor: AppColor.accentSoft.withValues(alpha: 0.18),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                _expanded ? 16 : 12,
                14,
                _expanded ? 16 : 12,
              ),
              child: _expanded ? _buildExpanded() : _buildCollapsed(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsed() {
    final device = widget.device;
    return Row(
      key: const ValueKey('collapsed'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _PhoneThumbnail(device: device, online: _online, compact: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      device.deviceName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.titleSm(AppColor.ink),
                    ),
                  ),
                  if (device.isMainDevice) ...[
                    const SizedBox(width: 6),
                    const _MainDot(),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              DefaultTextStyle(
                style: AppTextStyle.caption(AppColor.inkTertiary),
                child: Row(
                  children: [
                    _CollapsedStatusDot(online: _online),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _collapsedSubtitle(device),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 22,
          color: AppColor.inkPlaceholder,
        ),
      ],
    );
  }

  Widget _buildExpanded() {
    final device = widget.device;
    return Column(
      key: const ValueKey('expanded'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          device: device,
          online: _online,
          isCurrentDevice: widget.isCurrentDevice,
          canMoveUp: widget.canMoveUp,
          canMoveDown: widget.canMoveDown,
          isPinned: widget.isPinned,
          onTogglePin: widget.onTogglePin,
          onReconnect: widget.onReconnect,
          onMoveUp: widget.onMoveUp,
          onMoveDown: widget.onMoveDown,
          onDelete: widget.onDelete,
        ),
        const SizedBox(height: 16),
        DeviceInfoWidget(
          device: device,
          online: _online,
        ),
      ],
    );
  }

  String _collapsedSubtitle(Device device) {
    final parts = <String>[
      device.platformLabel,
      if (_online)
        'в сети'
      else if (device.dateUpdateInfo != null)
        'был ${device.dateUpdateInfo!.toDate().formatRelativeShort()}'
      else
        'не в сети',
      if (!device.isReceiverOnly && device.todayMessageCount > 0)
        '${device.todayMessageCount} SMS',
      if (!device.isReceiverOnly && device.batteryLevel != null)
        '${device.batteryLevel}%',
    ];
    return parts.join(' · ');
  }
}

class _CollapsedStatusDot extends StatelessWidget {
  final bool online;
  const _CollapsedStatusDot({required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: online ? AppColor.success : AppColor.inkPlaceholder,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MainDot extends StatelessWidget {
  const _MainDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColor.accent,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Device device;
  final bool online;
  final bool isCurrentDevice;
  final bool canMoveUp;
  final bool canMoveDown;
  final bool isPinned;
  final VoidCallback onTogglePin;
  final VoidCallback onReconnect;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  const _Header({
    required this.device,
    required this.online,
    required this.isCurrentDevice,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.isPinned,
    required this.onTogglePin,
    required this.onReconnect,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PhoneThumbnail(device: device, online: online),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      device.deviceName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.title(AppColor.ink),
                    ),
                  ),
                  if (device.isMainDevice) ...[
                    const SizedBox(width: 8),
                    const _MainBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    device.platformLabel,
                    style: AppTextStyle.bodySm(AppColor.inkTertiary),
                  ),
                  _StatusLine(
                    online: online,
                    lastSeen: device.dateUpdateInfo?.toDate(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        _PinButton(pinned: isPinned, onTap: onTogglePin),
        const SizedBox(width: 4),
        _ActionMenu(
          isCurrentDevice: isCurrentDevice,
          canMoveUp: canMoveUp,
          canMoveDown: canMoveDown,
          onReconnect: onReconnect,
          onMoveUp: onMoveUp,
          onMoveDown: onMoveDown,
          onDelete: onDelete,
        ),
      ],
    );
  }
}

class _PinButton extends StatelessWidget {
  final bool pinned;
  final VoidCallback onTap;

  const _PinButton({required this.pinned, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = pinned ? AppColor.accentSoft : AppColor.bgAlt.withValues(alpha: 0.7);
    final color = pinned ? AppColor.accentDeep : AppColor.inkPlaceholder;
    return Semantics(
      button: true,
      toggled: pinned,
      label: pinned
          ? 'Открепить развёрнутый вид'
          : 'Закрепить развёрнутый вид',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              pinned
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined,
              color: color,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final bool isCurrentDevice;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onReconnect;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  const _ActionMenu({
    required this.isCurrentDevice,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onReconnect,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final actions = buildDeviceCardActions(
      isCurrentDevice: isCurrentDevice,
      canMoveUp: canMoveUp,
      canMoveDown: canMoveDown,
    );

    return PopupMenuButton<DeviceCardAction>(
      tooltip: 'Действия устройства',
      onSelected: (action) {
        switch (action) {
          case DeviceCardAction.reconnect:
            onReconnect();
            break;
          case DeviceCardAction.moveUp:
            onMoveUp();
            break;
          case DeviceCardAction.moveDown:
            onMoveDown();
            break;
          case DeviceCardAction.delete:
            onDelete();
            break;
        }
      },
      color: AppColor.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.brR2,
        side: BorderSide(color: Color(0x12281910)),
      ),
      itemBuilder: (context) => [
        for (final action in actions)
          PopupMenuItem<DeviceCardAction>(
            value: action,
            child: Row(
              children: [
                Icon(
                  _iconFor(action),
                  size: 18,
                  color: _iconColorFor(action),
                ),
                const SizedBox(width: 10),
                Text(
                  _labelFor(action),
                  style: AppTextStyle.bodySm(
                    action == DeviceCardAction.delete
                        ? AppColor.danger
                        : AppColor.ink,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.bgAlt.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          color: AppColor.inkPlaceholder,
          size: 18,
        ),
      ),
    );
  }

  String _labelFor(DeviceCardAction action) {
    switch (action) {
      case DeviceCardAction.reconnect:
        return 'Переподключить';
      case DeviceCardAction.moveUp:
        return 'Поднять выше';
      case DeviceCardAction.moveDown:
        return 'Опустить ниже';
      case DeviceCardAction.delete:
        return 'Удалить';
    }
  }

  IconData _iconFor(DeviceCardAction action) {
    switch (action) {
      case DeviceCardAction.reconnect:
        return Icons.sync_rounded;
      case DeviceCardAction.moveUp:
        return Icons.keyboard_arrow_up_rounded;
      case DeviceCardAction.moveDown:
        return Icons.keyboard_arrow_down_rounded;
      case DeviceCardAction.delete:
        return Icons.delete_outline_rounded;
    }
  }

  Color _iconColorFor(DeviceCardAction action) {
    if (action == DeviceCardAction.delete) return AppColor.danger;
    return AppColor.inkSecondary;
  }
}

class _StatusLine extends StatelessWidget {
  final bool online;
  final DateTime? lastSeen;

  const _StatusLine({
    required this.online,
    required this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: online ? AppColor.success : AppColor.inkPlaceholder,
            shape: BoxShape.circle,
            boxShadow: online
                ? [
                    BoxShadow(
                      color: AppColor.success.withValues(alpha: 0.24),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          online
              ? 'в сети'
              : (lastSeen != null
                  ? 'был ${lastSeen!.formatRelativeShort()}'
                  : 'не в сети'),
          style: AppTextStyle.bodySm(
            online ? AppColor.success : AppColor.inkTertiary,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _MainBadge extends StatelessWidget {
  const _MainBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColor.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'ГЛАВНОЕ',
        style: AppTextStyle.micro(AppColor.accentDeep),
      ),
    );
  }
}

class _PhoneThumbnail extends StatelessWidget {
  final Device device;
  final bool online;
  final bool compact;

  const _PhoneThumbnail({
    required this.device,
    required this.online,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = device.isReceiverOnly
        ? [const Color(0xFFF3ECE6), const Color(0xFFE9DDD2)]
        : [AppColor.accent, AppColor.accentDeep];
    final size = compact ? 44.0 : 58.0;
    final iconSize = compact ? 22.0 : 26.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.brR2,
        boxShadow: online && !device.isReceiverOnly ? AppShadows.accent : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        device.isReceiverOnly
            ? Icons.phone_iphone_rounded
            : Icons.phone_android_rounded,
        size: iconSize,
        color: device.isReceiverOnly ? AppColor.inkTertiary : AppColor.white,
      ),
    );
  }
}
