import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

enum PortalTheme { brand, influencer, admin }

abstract final class AppTheme {
  static ThemeData brand() => _build(
        portal: PortalTheme.brand,
        primary: ImColors.teal700,
        primaryPressed: ImColors.teal800,
        sidebarBg: ImColors.cream100,
        sidebarFg: ImColors.ink900,
        sidebarActive: ImColors.teal700,
      );

  static ThemeData influencer() => _build(
        portal: PortalTheme.influencer,
        primary: ImColors.coral600,
        primaryPressed: ImColors.coral500,
        sidebarBg: ImColors.cream100,
        sidebarFg: ImColors.ink900,
        sidebarActive: ImColors.coral600,
      );

  static ThemeData admin() => _build(
        portal: PortalTheme.admin,
        primary: ImColors.teal800,
        primaryPressed: ImColors.teal700,
        sidebarBg: ImColors.teal800,
        sidebarFg: ImColors.white,
        sidebarActive: ImColors.coral500,
      );

  static ThemeData forPortal(PortalTheme portal) {
    switch (portal) {
      case PortalTheme.brand:
        return brand();
      case PortalTheme.influencer:
        return influencer();
      case PortalTheme.admin:
        return admin();
    }
  }

  static ThemeData _build({
    required PortalTheme portal,
    required Color primary,
    required Color primaryPressed,
    required Color sidebarBg,
    required Color sidebarFg,
    required Color sidebarActive,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ImColors.cream50,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: ImColors.white,
        secondary: ImColors.coral500,
        onSecondary: ImColors.white,
        error: ImColors.danger600,
        onError: ImColors.white,
        surface: ImColors.white,
        onSurface: ImColors.ink900,
      ),
      textTheme: ImTypography.textTheme(),
      dividerColor: ImColors.ink300.withValues(alpha: 0.4),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ImColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ImSpacing.space16,
          vertical: ImSpacing.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
          borderSide: const BorderSide(color: ImColors.ink300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
          borderSide: const BorderSide(color: ImColors.ink300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
          borderSide: const BorderSide(color: ImColors.danger600),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
          borderSide: const BorderSide(color: ImColors.danger600, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: ImColors.white,
          minimumSize: const Size(0, ImLayout.touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ImRadii.radiusMd),
          ),
          textStyle: ImTypography.textTheme().labelLarge,
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
          textStyle: ImTypography.textTheme().labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, ImLayout.touchTarget),
          textStyle: ImTypography.textTheme().labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: ImColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusMd),
          side: BorderSide(color: ImColors.ink300.withValues(alpha: 0.4)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ImColors.cream50,
        foregroundColor: ImColors.ink900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: ImTypography.textTheme().titleMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ImColors.ink900,
        contentTextStyle: ImTypography.textTheme().bodyMedium?.copyWith(
              color: ImColors.white,
            ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusMd),
        ),
      ),
    );

    return base.copyWith(
      extensions: [
        PortalThemeExtension(
          portal: portal,
          primary: primary,
          primaryPressed: primaryPressed,
          sidebarBg: sidebarBg,
          sidebarFg: sidebarFg,
          sidebarActive: sidebarActive,
        ),
      ],
    );
  }
}

@immutable
class PortalThemeExtension extends ThemeExtension<PortalThemeExtension> {
  const PortalThemeExtension({
    required this.portal,
    required this.primary,
    required this.primaryPressed,
    required this.sidebarBg,
    required this.sidebarFg,
    required this.sidebarActive,
  });

  final PortalTheme portal;
  final Color primary;
  final Color primaryPressed;
  final Color sidebarBg;
  final Color sidebarFg;
  final Color sidebarActive;

  @override
  PortalThemeExtension copyWith({
    PortalTheme? portal,
    Color? primary,
    Color? primaryPressed,
    Color? sidebarBg,
    Color? sidebarFg,
    Color? sidebarActive,
  }) {
    return PortalThemeExtension(
      portal: portal ?? this.portal,
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      sidebarBg: sidebarBg ?? this.sidebarBg,
      sidebarFg: sidebarFg ?? this.sidebarFg,
      sidebarActive: sidebarActive ?? this.sidebarActive,
    );
  }

  @override
  ThemeExtension<PortalThemeExtension> lerp(
    covariant ThemeExtension<PortalThemeExtension>? other,
    double t,
  ) {
    if (other is! PortalThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}

extension PortalThemeX on BuildContext {
  PortalThemeExtension get portalTheme =>
      Theme.of(this).extension<PortalThemeExtension>()!;
}
