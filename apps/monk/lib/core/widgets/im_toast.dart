import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum ImToastTone { info, success, warning, danger }

abstract final class ImToast {
  static void show(
    BuildContext context, {
    required String message,
    ImToastTone tone = ImToastTone.info,
  }) {
    final color = switch (tone) {
      ImToastTone.info => ImColors.info600,
      ImToastTone.success => ImColors.success600,
      ImToastTone.warning => ImColors.warning600,
      ImToastTone.danger => ImColors.danger600,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
