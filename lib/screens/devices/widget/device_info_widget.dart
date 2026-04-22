import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:simply/extensions.dart';
import 'package:simply/models/device.dart';
import 'package:simply/screens/widget/custom_progress_indicator.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class DeviceInfoWidget extends StatelessWidget {
  final Device device;
  final bool isMessageScreen;

  const DeviceInfoWidget({
    super.key,
    required this.device,
    this.isMessageScreen = false,
  });

  String get _imageAsset =>
      device.platform == 'ios' ? 'iphone.png' : 'android.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/image_devices/$_imageAsset',
          width: 42,
          height: 70,
          fit: BoxFit.cover,
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(4),
              Text(
                device.deviceName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.title4(AppColor.greyDark),
              ),
              const Gap(4),
              if (device.isMainDevice)
                Text(
                  'SMS is being sent',
                  style: AppTextStyle.captionS(AppColor.grey),
                ),
              if (device.dateUpdateInfo != null)
                Text(
                  'Last seen: ${device.dateUpdateInfo!.toDate().formatDateTime()}',
                  style: AppTextStyle.captionS(AppColor.grey),
                ),
            ],
          ),
        ),
        const Gap(12),
        if (device.batteryLevel != null)
          CustomProgressIndicator(
            textProgress: '${device.batteryLevel}%',
            title: 'Charge',
            progress: device.batteryLevel!.clamp(0, 100),
          ),
        const Gap(8),
        if (device.networkType != null) _NetworkBadge(type: device.networkType!),
        if (device.networkType == null && device.batteryLevel == null)
          const Icon(
            Icons.touch_app,
            size: 28,
            color: AppColor.orange,
          ),
      ],
    );
  }
}

class _NetworkBadge extends StatelessWidget {
  final String type;
  const _NetworkBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColor.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.signal_cellular_alt,
                  size: 14, color: AppColor.orange),
              const SizedBox(width: 4),
              Text(
                type.toUpperCase(),
                style: AppTextStyle.captionSM(AppColor.orange),
              ),
            ],
          ),
        ),
        const Gap(4),
        Text(
          'Network',
          style: AppTextStyle.captionSC4(AppColor.greyDark2),
        ),
      ],
    );
  }
}
