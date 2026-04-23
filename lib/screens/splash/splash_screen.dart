import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simply/screens/auth/screen/auth_screen.dart';
import 'package:simply/screens/home/home.dart';
import 'package:simply/screens/splash/cubit/splash_cubit.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/shadows.dart';
import 'package:simply/themes/text_style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColor.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          await Navigator.pushReplacement(context, HomePage.route());
        } else if (state is AuthUnauthenticated) {
          await Navigator.pushReplacement(context, AuthScreen.route());
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColor.accent, AppColor.accentDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppShadows.accent,
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/flash.png',
                  width: 44,
                  color: AppColor.white,
                ),
              ),
              const SizedBox(height: 20),
              Text('Simply', style: AppTextStyle.h1(AppColor.ink)),
              const SizedBox(height: 6),
              Text(
                'SMS-пересылка между устройствами',
                style: AppTextStyle.bodySm(AppColor.inkTertiary),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColor.accent,
                  strokeWidth: 2.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
