import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/screens/devices/add_new_device/check_device_cubit.dart';
import 'package:sms_forward_app/screens/home/home.dart';
import 'package:sms_forward_app/screens/login/cubit/auth_cubit.dart';
import 'package:sms_forward_app/screens/login/screen/login_screen.dart';
import 'package:sms_forward_app/themes/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColor.white,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          context.read<CheckDeviceCubit>().checkDevice();
          await Navigator.pushReplacement(context, HomePage.route());
        } else if (state is AuthUnauthenticated) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return LoginScreenTest();
              },
            ),
          );
        }
      },
      child: const Scaffold(body: CircularProgressIndicator()),
    );
  }
}
