import 'package:flutter/material.dart';
import 'tokens.dart';

abstract final class MobileTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: ImColors.teal700,
      onPrimary: ImColors.white,
      secondary: ImColors.coral500,
      onSecondary: ImColors.white,
      surface: ImColors.white,
      onSurface: ImColors.ink900,
      error: ImColors.danger600,
      onError: ImColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ImColors.cream50,
      appBarTheme: const AppBarTheme(
        backgroundColor: ImColors.teal800,
        foregroundColor: ImColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ImColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: ImColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusMd),
          side: const BorderSide(color: ImColors.cream100),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ImColors.coral500,
          foregroundColor: ImColors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ImRadii.radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ImColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ImSpacing.space16,
          vertical: ImSpacing.space16,
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
          borderSide: const BorderSide(color: ImColors.teal700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ImRadii.radiusSm),
          borderSide: const BorderSide(color: ImColors.danger600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ImColors.white,
        selectedItemColor: ImColors.teal700,
        unselectedItemColor: ImColors.ink600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
