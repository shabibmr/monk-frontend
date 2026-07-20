import 'package:flutter/material.dart';

import '../utils/money_format.dart';

/// Displays API-provided minor units. No client-side fee math.
class ImMoneyText extends StatelessWidget {
  const ImMoneyText({
    super.key,
    required this.minorUnits,
    required this.currencyCode,
    this.style,
  });

  final int minorUnits;
  final String currencyCode;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    return Text(
      formatMoneyMinor(minorUnits, currencyCode),
      style: base?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
