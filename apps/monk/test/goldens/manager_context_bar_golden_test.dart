import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monk_web/core/router/shells/portal_shell.dart';
import 'package:monk_web/core/theme/tokens.dart';

void main() {
  testWidgets('Manager context bar golden', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ManagerContextBar(profileName: 'Asha Creator'),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Acting as manager'), findsOneWidget);
    expect(find.textContaining('Asha Creator'), findsOneWidget);
    // Visual regression: coral100 bar
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(ManagerContextBar),
        matching: find.byType(Material),
      ).first,
    );
    expect(material.color, ImColors.coral100);
    await expectLater(
      find.byType(ManagerContextBar),
      matchesGoldenFile('manager_context_bar.png'),
    );
  });
}
