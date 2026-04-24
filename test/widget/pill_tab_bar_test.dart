import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simply/screens/widget/warm/nav_icons.dart';
import 'package:simply/screens/widget/warm/pill_tab_bar.dart';

void main() {
  testWidgets('PillTabBar keeps active labels inside narrow tabs',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 220,
            child: Scaffold(
              bottomNavigationBar: PillTabBar(
                activeIndex: 1,
                onChanged: (_) {},
                tabs: const [
                  PillTab(kind: NavIconKind.devices, label: 'Устройства'),
                  PillTab(kind: NavIconKind.messages, label: 'Сообщения'),
                  PillTab(kind: NavIconKind.settings, label: 'Настройки'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
