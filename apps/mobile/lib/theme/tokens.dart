import 'package:flutter/material.dart';

/// Design system tokens for Monk Mobile App matching web/brand standards.
abstract final class ImColors {
  static const coral500 = Color(0xFFF08A7A);
  static const coral600 = Color(0xFFE06A57);
  static const coral100 = Color(0xFFFBE3DE);
  
  static const teal700 = Color(0xFF2E5A6B);
  static const teal800 = Color(0xFF20414E);
  static const teal100 = Color(0xFFDCE8EC);
  
  static const cream50 = Color(0xFFF7F5EE);
  static const cream100 = Color(0xFFEFEDE4);
  
  static const ink900 = Color(0xFF1D2B32);
  static const ink600 = Color(0xFF5A6B72);
  static const ink300 = Color(0xFFB9C2C6);
  static const white = Color(0xFFFFFFFF);

  static const success600 = Color(0xFF2E7D5B);
  static const success100 = Color(0xFFDBEEE5);
  
  static const warning600 = Color(0xFFB97A1B);
  static const warning100 = Color(0xFFF7E9D2);
  
  static const danger600 = Color(0xFFC24E3A);
  static const danger100 = Color(0xFFF6DEDA);
  
  static const info600 = Color(0xFF3A6EA5);
  static const info100 = Color(0xFFDEE9F4);
}

abstract final class ImSpacing {
  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space24 = 24.0;
  static const space32 = 32.0;
  static const space48 = 48.0;
}

abstract final class ImRadii {
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 20.0;
  static const radiusFull = 999.0;
}

abstract final class ImShadows {
  static final card = [
    BoxShadow(
      color: ImColors.ink900.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
