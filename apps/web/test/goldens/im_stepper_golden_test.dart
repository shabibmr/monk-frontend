import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monk_web/core/theme/app_theme.dart';
import 'package:monk_web/core/theme/tokens.dart';
import 'package:monk_web/core/widgets/im_stepper.dart';

void main() {
  testWidgets('ImStepper golden influencer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(primary: ImColors.coral600),
          extensions: const [
            PortalThemeExtension(
              portal: PortalTheme.influencer,
              primary: ImColors.coral600,
              primaryPressed: ImColors.coral500,
              sidebarBg: ImColors.cream100,
              sidebarFg: ImColors.ink900,
              sidebarActive: ImColors.coral600,
            ),
          ],
        ),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: ImStepper(
              labels: [
                'Account',
                'Platforms',
                'Social',
                'Categories',
                'Team',
                'Confirm',
              ],
              currentStep: 3,
              completedSteps: {1, 2},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('im_stepper_influencer.png'),
    );
  });
}
