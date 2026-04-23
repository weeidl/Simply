import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simply/screens/widget/warm/warm_search_field.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('WarmSearchField', () {
    testWidgets('renders a trailing action and invokes its tap handler',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrap(
          WarmSearchField(
            hint: 'Поиск по сообщениям',
            trailingIcon: Icons.tune_rounded,
            onTrailingTap: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('propagates text changes', (tester) async {
      String? latest;

      await tester.pumpWidget(
        wrap(
          WarmSearchField(
            hint: 'Поиск по сообщениям',
            onChanged: (value) => latest = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'otp');
      await tester.pump();

      expect(latest, 'otp');
    });

    testWidgets('supports read-only tap handling', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrap(
          WarmSearchField(
            hint: 'Поиск по сообщениям',
            readOnly: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
