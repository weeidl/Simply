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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/image_devices/${imageDevice()}',
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
                  style: AppTextStyle.captionS(
                    AppColor.grey,
                  ),
                ),
              if (device.dateUpdateInfo != null)
                Text(
                  "Last seen: ${device.dateUpdateInfo!.toDate().formatDateTime()}",
                  style: AppTextStyle.captionS(
                    AppColor.grey,
                  ),
                ),
            ],
          ),
        ),
        const Gap(12),
        if (device.batteryLevel != null)
          CustomProgressIndicator(
            textProgress: '${device.batteryLevel}%',
            title: 'Charge',
            progress: device.batteryLevel ?? 0,
          ),
        const Gap(8),
        if (device.networkType != null)
          CustomProgressIndicator(
            textProgress: device.networkType!,
            title: 'Mobile data',
            progress: 80,
          ),
        if (device.networkType == null && device.batteryLevel == null)
          const Icon(
            Icons.touch_app,
            size: 28,
            color: AppColor.orange,
          ),
      ],
    );
  }

// Widget simInfo(String simName) {
//   return Row(
//     children: [
//       const Icon(Icons.sim_card, color: AppColor.orange),
//       Text(
//         simName,
//         style: AppTextStyle.captionS(
//           AppColor.greyDark.withOpacity(0.6),
//         ),
//       ),
//       const SizedBox(height: 4),
//     ],
//   );
// }
}
