import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:sms_forward_app/models/device.dart';
import 'package:sms_forward_app/screens/devices/add_new_device/check_device_cubit.dart';
import 'package:sms_forward_app/screens/devices/cubit/device_cubit.dart';
import 'package:sms_forward_app/screens/devices/widget/device_info_widget.dart';
import 'package:sms_forward_app/screens/widget/custom_progress_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:sms_forward_app/themes/colors.dart';
import 'dart:convert';

import 'package:sms_forward_app/themes/text_style.dart';

class DeviceWidget extends StatelessWidget {
  final Device device;

  const DeviceWidget({
    super.key,
    required this.device,
  });

  Widget buttonInfo({required BuildContext context, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () async {
            context.read<CheckDeviceCubit>().saveMainDevice();
          },
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 4,
            ),
            child: Text(
              'Manager',
              style: AppTextStyle.captionM(
                AppColor.orange,
              ),
            ),
          ),
        ),
        // ElevatedButton(
        //   onPressed: () async {
        //     context.read<DeviceCubit>().networkTypeStatus();
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: AppColor.orange,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(16),
        //     ),
        //   ),
        //   child: const Padding(
        //     padding: EdgeInsets.symmetric(
        //       horizontal: 24,
        //       vertical: 4,
        //     ),
        //     child: Text('Manager'),
        //   ),
        // ),
        const Spacer(),
        Column(
          children: [
            Text(
              'time update ${device.dateUpdateInfo?.seconds}',
              style: AppTextStyle.captionS(
                AppColor.grey,
              ),
            ),
            Text(
              text,
              style: AppTextStyle.captionS(
                AppColor.grey,
              ),
            ),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.greyMedium,
        borderRadius: BorderRadius.circular(15),
      ),
      child: device.isMainDevice == true
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DeviceInfoWidget(
                  device: device,
                ),
                const SizedBox(height: 16),
                buttonInfo(context: context, text: 'Main device'),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 4),
                      Text(
                        device.deviceName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.title4(AppColor.greyDark),
                      ),
                      const SizedBox(height: 4),
                      buttonInfo(context: context, text: 'Online last minute'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
