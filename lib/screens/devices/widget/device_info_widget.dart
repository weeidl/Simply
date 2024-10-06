import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sms_forward_app/models/device.dart';
import 'package:sms_forward_app/screens/devices/cubit/device_cubit.dart';
import 'package:sms_forward_app/screens/widget/custom_progress_indicator.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class DeviceInfoWidget extends StatelessWidget {
  final Device device;
  final bool isMessageScreen;

  const DeviceInfoWidget({
    super.key,
    required this.device,
    this.isMessageScreen = false,
  });

  Widget simInfo(String simName) {
    return Row(
      children: [
        const Icon(Icons.sim_card, color: AppColor.orange),
        Text(
          simName,
          style: AppTextStyle.captionS(
            AppColor.greyDark.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  String imageDevice() {
    if (device.deviceName == 'iPhone 15') {
      return 'iphone.png';
    } else {
      return 'android.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container(
        //   height: 80,
        //   width: 38,
        //   color: AppColor.grey,
        //   child: Image.asset('assets/image_devices/${imageDevice()}'),
        // ),
        Image.asset(
          'assets/image_devices/${imageDevice()}',
          width: 42,
          height: 70,
          fit: BoxFit.cover,
        ),
        // Expanded(
        //   child: Image.asset(
        //     'path_to_your_image_asset', // замените на путь к вашему изображению
        //     fit: BoxFit.contain,
        //   ),
        // ),
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
              simInfo('TurkSell'),
              simInfo(
                'MTC',
              ),
            ],
          ),
        ),
        CustomProgressIndicator(
          textProgress: '${device.batteryLevel ?? 0}%',
          title: 'Charge',
          progress: device.batteryLevel ?? 0,
        ),
        const Gap(8),
        CustomProgressIndicator(
          textProgress: device.networkType ?? 'LTE',
          title: 'Mobile data',
          progress: 80,
        ),
      ],
    );
  }
}
