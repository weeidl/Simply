import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simply/models/device.dart';
import 'package:simply/screens/devices/settings/device_settings_widget.dart';
import 'package:simply/themes/colors.dart';

class DeviceSettingsModal {
  static Future<void> show({
    required BuildContext context,
    bool useSafeArea = false,
    Device? device,
  }) {
    return showModalBottomSheet(
      elevation: 0,
      context: context,
      useSafeArea: useSafeArea,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: AppColor.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColor.bg,
        ),
        child: DeviceSettingsWidget(device: device),
      ),
    );
  }
}
