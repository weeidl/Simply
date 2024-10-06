import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_forward_app/screens/devices/cubit/device_cubit.dart';
import 'package:sms_forward_app/screens/devices/screen/devices_screen.dart';
import 'package:sms_forward_app/screens/messages_list/screen/messages_list_screen.dart';
import 'package:sms_forward_app/screens/settings/settings_screen.dart';
import 'package:sms_forward_app/themes/colors.dart';

class HomePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => const HomePage(),
    );
  }

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Widget buildNavItem(IconData icon, String label, int index) {
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
            Icon(
              icon,
              color: _selectedIndex == index ? AppColor.orange : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index ? AppColor.orange : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _selectedIndex == 1 ? AppColor.orange : AppColor.white,
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
              buildNavItem(Icons.devices, 'Devices', 0),
              buildNavItem(Icons.message, 'Message', 1),
              buildNavItem(Icons.settings, 'Settings', 2),
            ],
          ),
        ),
        body: SafeArea(child: _tabs[_selectedIndex]),
      ),
    );
  }
}
