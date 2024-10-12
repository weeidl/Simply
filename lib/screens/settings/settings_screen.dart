import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sms_forward_app/screens/widget/app_bar_widget.dart';
import 'package:sms_forward_app/screens/widget/bacgraund_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: const AppBarWidget(
        nameScreen: 'Setting',
        isLight: false,
      ),
      child: Column(
        children: [
          const Gap(20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final FirebaseAuth auth = FirebaseAuth.instance;
                await auth.signOut();
              },
              child: const Text(
                'Log Out',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
