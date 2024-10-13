import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_forward_app/models/device.dart';
import 'package:sms_forward_app/screens/devices/settings/device_settings_widget.dart';

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      builder: (_) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
        ),
        child: DeviceSettingsWidget(device: device),
      ),
    );
  }
}
