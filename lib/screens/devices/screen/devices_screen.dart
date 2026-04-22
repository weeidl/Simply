import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simply/screens/devices/cubit/device_cubit.dart';
import 'package:simply/screens/devices/settings/device_settings_modal.dart';
import 'package:simply/screens/devices/widget/device_widget.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<DeviceCubit>();
      if (cubit.state.status == DeviceStatus.initial) {
        cubit.fetch();
      }
    });
  }

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
                  style: AppTextStyle.title2(AppColor.greyDark),
                ),
                const Spacer(),
                SizedBox(
                  width: 80,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () =>
                        DeviceSettingsModal.show(context: context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.orange,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.add, color: AppColor.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<DeviceCubit, DeviceState>(
              builder: (context, state) {
                switch (state.status) {
                  case DeviceStatus.initial:
                  case DeviceStatus.loading:
                    return Center(
                      child: SpinKitFadingCube(
                        color: AppColor.orange.withValues(alpha: 0.5),
                      ),
                    );
                  case DeviceStatus.error:
                    return _ErrorView(
                      onRetry: () => context.read<DeviceCubit>().fetch(),
                    );
                  case DeviceStatus.empty:
                    return const _EmptyDevicesView();
                  case DeviceStatus.loaded:
                    if (state.items.isEmpty) return const _EmptyDevicesView();
                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<DeviceCubit>().updateDevice(),
                      child: ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) =>
                            DeviceWidget(device: state.items[index]),
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDevicesView extends StatelessWidget {
  const _EmptyDevicesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.devices_other,
                size: 64, color: AppColor.grey.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(
              'No devices yet',
              style: AppTextStyle.title5(AppColor.greyDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in on another phone to see it here.',
              style: AppTextStyle.captionSM(AppColor.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Something went wrong',
            style: AppTextStyle.title5(AppColor.greyDark),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
