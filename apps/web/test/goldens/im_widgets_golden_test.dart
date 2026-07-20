import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monk_shared/monk_shared.dart';
import 'package:monk_web/core/theme/app_theme.dart';
import 'package:monk_web/core/theme/tokens.dart';
import 'package:monk_web/core/widgets/widgets.dart';

/// Offline golden themes: portal colors only, no google_fonts network/assets.
ThemeData goldenTheme(PortalTheme portal) {
  final Color primary;
  final Color sidebarBg;
  final Color sidebarFg;
  final Color sidebarActive;
  switch (portal) {
    case PortalTheme.brand:
      primary = ImColors.teal700;
      sidebarBg = ImColors.cream100;
      sidebarFg = ImColors.ink900;
      sidebarActive = ImColors.teal700;
    case PortalTheme.influencer:
      primary = ImColors.coral600;
      sidebarBg = ImColors.cream100;
      sidebarFg = ImColors.ink900;
      sidebarActive = ImColors.coral600;
    case PortalTheme.admin:
      primary = ImColors.teal800;
      sidebarBg = ImColors.teal800;
      sidebarFg = ImColors.white;
      sidebarActive = ImColors.coral500;
  }

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ImColors.cream50,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: ImColors.white,
      surface: ImColors.white,
      onSurface: ImColors.ink900,
      error: ImColors.danger600,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: ImColors.white,
        minimumSize: const Size(0, ImLayout.touchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusMd),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(0, ImLayout.touchTarget),
        side: BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusMd),
        ),
      ),
    ),
    extensions: [
      PortalThemeExtension(
        portal: portal,
        primary: primary,
        primaryPressed: primary,
        sidebarBg: sidebarBg,
        sidebarFg: sidebarFg,
        sidebarActive: sidebarActive,
      ),
    ],
  );
}

void main() {
  Future<void> pumpTheme(
    WidgetTester tester,
    ThemeData theme,
    Widget child,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final portal in PortalTheme.values) {
    testWidgets('ImButton golden ${portal.name}', (tester) async {
      await pumpTheme(
        tester,
        goldenTheme(portal),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImButton(label: 'Primary action'),
            SizedBox(height: 12),
            ImButton(label: 'Secondary', variant: ImButtonVariant.secondary),
          ],
        ),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('im_button_${portal.name}.png'),
      );
    });

    testWidgets('ImCard golden ${portal.name}', (tester) async {
      await pumpTheme(
        tester,
        goldenTheme(portal),
        const ImCard(
          child: Text('Card content'),
        ),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('im_card_${portal.name}.png'),
      );
    });

    testWidgets('ImStatusChip golden ${portal.name}', (tester) async {
      await pumpTheme(
        tester,
        goldenTheme(portal),
        const Wrap(
          spacing: 8,
          children: [
            ImStatusChip(status: EntityStatus.draft),
            ImStatusChip(status: EntityStatus.approved),
            ImStatusChip(status: EntityStatus.rejected),
            ImStatusChip(status: EntityStatus.negotiating),
          ],
        ),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('im_status_chip_${portal.name}.png'),
      );
    });
  }
}
