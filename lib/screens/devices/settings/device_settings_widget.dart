import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sms_forward_app/models/device.dart';
import 'package:sms_forward_app/screens/devices/add_new_device/check_device_cubit.dart';
import 'package:sms_forward_app/screens/devices/cubit/device_cubit.dart';
import 'package:sms_forward_app/screens/devices/settings/build_switch_tile.dart';
import 'package:sms_forward_app/screens/widget/rounded_button.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class DeviceSettingsWidget extends StatefulWidget {
  final Device? device;
  const DeviceSettingsWidget({super.key, this.device});

  @override
  State<DeviceSettingsWidget> createState() => _DeviceSettingsWidgetState();
}

class _DeviceSettingsWidgetState extends State<DeviceSettingsWidget> {
  final bool useSafeArea = false;

  late bool isSMSEnabled;
  late bool isNetworkEnabled;
  late bool isChargingEnabled;

  @override
  void initState() {
    isSMSEnabled = widget.device?.isMainDevice ?? true;
    isNetworkEnabled =
        widget.device == null ? true : widget.device?.networkType != null;
    isChargingEnabled =
        widget.device == null ? true : widget.device?.batteryLevel != null;
    super.initState();
  }

  double heightModal(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height < 650 ? height * 0.95 : height * 0.85;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: heightModal(context),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: useSafeArea ? MediaQuery.of(context).viewPadding.bottom : 0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Setting Device",
                style: AppTextStyle.title2(AppColor.greyDark2),
              ),
              const Gap(4),
              Text(
                "Please select which data you want to display in the app. "
                "These settings will help you monitor the device "
                "status and manage messaging features.",
                textAlign: TextAlign.center,
                style: AppTextStyle.captionSM(AppColor.grey2),
              ),
              const Gap(30),
              BuildSwitchTile(
                context: context,
                title: "Sending SMS",
                subtitle: "Allow the app to send messages from this device",
                value: isSMSEnabled,
                onChanged: (value) {
                  setState(() {
                    isSMSEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              BuildSwitchTile(
                context: context,
                title: "Display network",
                subtitle: "The application will show the current "
                    "network status and signal quality",
                value: isNetworkEnabled,
                onChanged: (value) {
                  setState(() {
                    isNetworkEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              BuildSwitchTile(
                context: context,
                title: "Charging level",
                subtitle: "The app will display the current charge "
                    "level of your device in the 'Devices' tab",
                value: isChargingEnabled,
                onChanged: (value) {
                  setState(() {
                    isChargingEnabled = value;
                  });
                },
              ),
              const Spacer(),
              RoundedButton(
                height: 48,
                buttonColor: AppColor.green,
                textStyle: AppTextStyle.title5(AppColor.white),
                onPressed: () async {
                  await context.read<CheckDeviceCubit>().saveSettingDevice(
                        isSMSEnabled: isSMSEnabled,
                        isNetworkEnabled: isNetworkEnabled,
                        isChargingEnabled: isChargingEnabled,
                        deviceId: widget.device?.deviceId,
                      );
                  if (widget.device != null) {
                    await context.read<DeviceCubit>().updateDevice();
                  }
                  // Make logic so that you can delete the device
                  Navigator.pop(context);
                },
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                text: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
