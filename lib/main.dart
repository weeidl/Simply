import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simply/bloc/locale/locale_cubit.dart';
import 'package:simply/bloc/locale/locale_state.dart';
import 'package:simply/l10n/app_localizations.dart';
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
  await initializeDateFormatting('en');
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);

  final localeCubit = LocaleCubit();
  await localeCubit.init();

  runApp(MyApp(localeCubit: localeCubit));
}

class MyApp extends StatelessWidget {
  final LocaleCubit localeCubit;

  const MyApp({super.key, required this.localeCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: localeCubit),
        BlocProvider(create: (context) => SplashCubit()),
        BlocProvider(create: (context) => DeviceCubit()),
        BlocProvider(create: (context) => CheckDeviceCubit()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        bloc: localeCubit,
        builder: (context, localeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: localeState.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ru'),
            ],
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
          );
        },
      ),
    );
  }
}
