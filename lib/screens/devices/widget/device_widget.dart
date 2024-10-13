import 'package:flutter/material.dart';
import 'package:simply/models/device.dart';
import 'package:simply/screens/devices/settings/device_settings_modal.dart';
import 'package:simply/screens/devices/widget/device_info_widget.dart';
import 'package:simply/themes/colors.dart';

class DeviceWidget extends StatelessWidget {
  final Device device;

  const DeviceWidget({super.key, required this.device});

  String imageDevice() {
    if (device.deviceName == 'iPhone 15') {
      return 'iphone.png';
    } else {
      return 'android.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        DeviceSettingsModal.show(
          context: context,
          device: device,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColor.greyMedium,
          borderRadius: BorderRadius.circular(15),
        ),
        child: DeviceInfoWidget(
          device: device,
        ),
      ),
    );
  }
}
