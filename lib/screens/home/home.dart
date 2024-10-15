import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simply/screens/devices/add_new_device/check_device_cubit.dart';
import 'package:simply/screens/devices/settings/device_settings_modal.dart';
import 'package:simply/screens/devices/screen/devices_screen.dart';
import 'package:simply/screens/messages_list/screen/messages_list_screen.dart';
import 'package:simply/screens/settings/settings_screen.dart';
import 'package:simply/themes/colors.dart';

class HomePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => const HomePage(),
    );
  }

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  late final List<Widget> _tabs;

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.locationWhenInUse, // или location для фонового использования
    ].request();
    log('Проверяем статус разрешения');
    // Проверяем статус разрешения
    final smsPermission = statuses[Permission.sms];
    if (smsPermission != PermissionStatus.granted) {
      log('Разрешение на SMS не получено');
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _tabs = [
      const DevicesScreen(),
      const MessagesListScreen(),
      const SettingsScreen(),
    ];
  }

  Widget buildNavItem({
    required String icon,
    required String label,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$icon.svg',
              colorFilter: ColorFilter.mode(
                _selectedIndex == index ? AppColor.greyDark2 : AppColor.grey,
                BlendMode.srcIn,
              ),
            ),
            // Icon(
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index
                    ? AppColor.greyDark2
                    : AppColor.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CheckDeviceCubit, CheckDeviceState>(
          listener: (context, state) async {
            if (state.status == DeviceSettingStatus.showModal) {
              DeviceSettingsModal.show(context: context);
            }
          },
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor:
              _selectedIndex == 1 ? AppColor.orange : AppColor.white,
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColor.white,
              boxShadow: [
                BoxShadow(
                  color: AppColor.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 24,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildNavItem(icon: 'device', label: 'Devices', index: 0),
                buildNavItem(icon: 'messages', label: 'Message', index: 1),
                buildNavItem(icon: 'settings', label: 'Settings', index: 2),
              ],
            ),
          ),
          body: _tabs[_selectedIndex],
        ),
      ),
    );
  }
}
