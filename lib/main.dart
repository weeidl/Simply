import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simply/screens/devices/add_new_device/check_device_cubit.dart';
import 'package:simply/screens/devices/cubit/device_cubit.dart';
import 'package:simply/screens/splash/cubit/splash_cubit.dart';
import 'package:simply/screens/splash/splash_screen.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/radii.dart';
import 'package:simply/themes/text_style.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackground(RemoteMessage message) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ru_RU');
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashCubit()),
        BlocProvider(create: (context) => DeviceCubit()),
        BlocProvider(create: (context) => CheckDeviceCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Manrope',
          primaryColor: AppColor.accent,
          scaffoldBackgroundColor: AppColor.bg,
          colorScheme: ColorScheme.light(
            primary: AppColor.accent,
            secondary: AppColor.accentDeep,
            surface: AppColor.surface,
            error: AppColor.danger,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColor.accent,
              foregroundColor: AppColor.white,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.brPill,
              ),
              maximumSize: const Size(double.infinity, 54),
              minimumSize: const Size(double.infinity, 54),
              textStyle: AppTextStyle.button(AppColor.white),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColor.surface,
            iconColor: AppColor.inkTertiary,
            prefixIconColor: AppColor.inkTertiary,
            hintStyle: AppTextStyle.bodyM(AppColor.inkPlaceholder),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: const OutlineInputBorder(
              borderRadius: AppRadii.brPill,
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadii.brPill,
              borderSide: BorderSide(color: AppColor.divider),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadii.brPill,
              borderSide: BorderSide(color: AppColor.accent, width: 1.5),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
