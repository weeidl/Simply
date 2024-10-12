import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/repositories/messages_repository.dart';
import 'package:sms_forward_app/screens/auth/cubit/auth_cubit.dart';
import 'package:sms_forward_app/screens/devices/add_new_device/check_device_cubit.dart';
import 'package:sms_forward_app/screens/devices/cubit/device_cubit.dart';
import 'package:sms_forward_app/screens/home/cubit/fcm_cubit.dart';
import 'package:sms_forward_app/screens/message_thread/cubit/message_thread_cubit.dart';
import 'package:sms_forward_app/screens/messages_list/cubit/messages_cubit.dart';
import 'package:sms_forward_app/screens/splash/cubit/splash_cubit.dart';
import 'package:sms_forward_app/screens/splash/splash_screen.dart';
import 'package:sms_forward_app/themes/colors.dart';

Future<void> _firebaseMessagingBackground(RemoteMessage message) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        BlocProvider(
          create: (context) => SplashCubit(),
        ),
        BlocProvider(
          create: (context) => FcmCubit()..init(),
        ),
        BlocProvider(
          create: (context) => MessagesCubit(
            messagesRepository: MessagesRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => DeviceCubit(),
          // child: const DevicesScreen(),
        ),
        BlocProvider(
          create: (context) => CheckDeviceCubit(),
        ),
      ],
      child: BlocBuilder<FcmCubit, FcmState>(
        builder: (context, state) {
          return MaterialApp(
            theme: ThemeData(
              primaryColor: AppColor.orange,
              scaffoldBackgroundColor: AppColor.greyLight,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColor.orange,
                  shape: const StadiumBorder(),
                  maximumSize: const Size(double.infinity, 56),
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: AppColor.greyLight,
                iconColor: AppColor.orange,
                prefixIconColor: AppColor.orange,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
