import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

abstract final class ImTypography {
  static TextTheme textTheme() {
    final inter = GoogleFonts.interTextTheme();
    final baloo = GoogleFonts.baloo2TextTheme();

    return inter.copyWith(
      displayLarge: baloo.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: ImColors.ink900,
      ),
      headlineMedium: baloo.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: ImColors.ink900,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: ImColors.ink900,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: ImColors.ink900,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: ImColors.ink900,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: ImColors.ink900,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: ImColors.ink600,
      ),
    );
  }

  static TextStyle kpiNumber({Color? color}) {
    return GoogleFonts.baloo2(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: color ?? ImColors.ink900,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
