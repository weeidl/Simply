import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/screens/devices/cubit/device_cubit.dart';
import 'package:sms_forward_app/screens/devices/widget/device_widget.dart';
import 'package:sms_forward_app/themes/colors.dart';
import 'package:sms_forward_app/themes/text_style.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Devices',
                style: AppTextStyle.title2(
                  AppColor.greyDark,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 42,
                height: 42,
                child: ElevatedButton(
                  onPressed: () async {
                    // context.read<DeviceCubit>().updateInfoMainDevice();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.orange,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColor.greyDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        BlocBuilder<DeviceCubit, DeviceState>(
          builder: (context, state) {
            if (state.status == DeviceStatus.initial) {
              context.read<DeviceCubit>().fetch();
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == DeviceStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Expanded(
              child: ListView.builder(
                itemCount: state.items.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => DeviceWidget(
                  device: state.items[index],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
