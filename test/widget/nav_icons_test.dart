import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simply/screens/widget/warm/nav_icons.dart';

void main() {
  group('NavIcon', () {
    testWidgets('renders each nav kind from the matching svg asset',
        (tester) async {
      const cases = {
        NavIconKind.devices: 'assets/icons/device.svg',
        NavIconKind.messages: 'assets/icons/messages.svg',
        NavIconKind.settings: 'assets/icons/settings.svg',
      };

      for (final entry in cases.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: NavIcon(
                kind: entry.key,
                color: const Color(0xFF292941),
                size: 20,
              ),
            ),
          ),
        );

        final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));

        expect(icon.width, 20);
        expect(icon.height, 20);
        expect(icon.bytesLoader.toString(), 'SvgAssetLoader(${entry.value})');
        expect(icon.colorFilter, isNotNull);

        await tester.pumpAndSettle();
      }
    });
  });
}
