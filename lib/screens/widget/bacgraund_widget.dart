import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sms_forward_app/themes/colors.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final Widget appBar;

  const BackgroundWidget({
    super.key,
    required this.child,
    required this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.orange,
      body: SafeArea(
        bottom: !Platform.isIOS,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            appBar,
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
