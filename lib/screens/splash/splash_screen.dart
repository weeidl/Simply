import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/screens/auth/screen/auth_screen.dart';
import 'package:simply/screens/devices/add_new_device/check_device_cubit.dart';
import 'package:simply/screens/home/home.dart';
import 'package:simply/screens/splash/cubit/splash_cubit.dart';
import 'package:simply/themes/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColor.white,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          context.read<CheckDeviceCubit>().checkDevice();
          await Navigator.pushReplacement(context, HomePage.route());
        } else if (state is AuthUnauthenticated) {
          await Navigator.push(context, AuthScreen.route());
        }
      },
      child: const Scaffold(body: CircularProgressIndicator()),
    );
  }
}
