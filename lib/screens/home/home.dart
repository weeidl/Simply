import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simply/repositories/messages_repository.dart';
import 'package:simply/screens/devices/add_new_device/check_device_cubit.dart';
import 'package:simply/screens/devices/screen/devices_screen.dart';
import 'package:simply/screens/devices/settings/device_settings_modal.dart';
import 'package:simply/screens/home/cubit/fcm_cubit.dart';
import 'package:simply/screens/messages_list/cubit/messages_list_cubit.dart';
import 'package:simply/screens/messages_list/screen/messages_list_screen.dart';
import 'package:simply/screens/settings/settings_screen.dart';
import 'package:simply/screens/widget/warm/pill_tab_bar.dart';
import 'package:simply/themes/colors.dart';

class HomePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => FcmCubit()..init()),
          BlocProvider(
            create: (_) => MessagesListCubit(
              messagesRepository: MessagesRepository(),
            ),
          ),
        ],
        child: const HomePage(),
      ),
    );
  }

  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  late final List<Widget> _tabs;
  bool _didRequestInitialDeviceCheck = false;

  static const _navTabs = <PillTab>[
    PillTab(icon: Icons.devices_other_rounded, label: 'Устройства'),
    PillTab(icon: Icons.chat_bubble_outline_rounded, label: 'Сообщения'),
    PillTab(icon: Icons.settings_outlined, label: 'Настройки'),
  ];

  Future<void> _requestPermissions() async {
    if (!Platform.isAndroid) return;
    final statuses = await [
      Permission.sms,
      Permission.notification,
    ].request();
    if (statuses[Permission.sms] != PermissionStatus.granted) {
      log('SMS permission not granted');
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _tabs = const [
      DevicesScreen(),
      MessagesListScreen(),
      SettingsScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didRequestInitialDeviceCheck) return;
      _didRequestInitialDeviceCheck = true;
      context.read<CheckDeviceCubit>().checkDevice();
    });
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
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColor.bg,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColor.bg,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _selectedIndex,
              children: _tabs,
            ),
          ),
          bottomNavigationBar: PillTabBar(
            tabs: _navTabs,
            activeIndex: _selectedIndex,
            onChanged: (i) => setState(() => _selectedIndex = i),
          ),
        ),
      ),
    );
  }
}
