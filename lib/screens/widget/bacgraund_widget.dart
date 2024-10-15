import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final Widget appBar;
  final Widget? childAppBar;

  const BackgroundWidget({
    super.key,
    required this.child,
    required this.appBar,
    this.childAppBar,
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
            if (childAppBar != null) childAppBar!,
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
