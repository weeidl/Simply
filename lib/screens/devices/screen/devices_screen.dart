import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simply/screens/devices/cubit/device_cubit.dart';
import 'package:simply/screens/devices/widget/device_widget.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
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
                  width: 80,
                  height: 40,
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
                      color: AppColor.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<DeviceCubit, DeviceState>(
              builder: (context, state) {
                if (state.status == DeviceStatus.initial) {
                  context.read<DeviceCubit>().fetch();
                  return Center(
                    child: SpinKitFadingCube(
                      color: AppColor.orange.withOpacity(0.5),
                    ),
                  );
                }
                if (state.status == DeviceStatus.loading) {
                  return Center(
                    child: SpinKitFadingCube(
                      color: AppColor.orange.withOpacity(0.5),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: state.items.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => DeviceWidget(
                    device: state.items[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
