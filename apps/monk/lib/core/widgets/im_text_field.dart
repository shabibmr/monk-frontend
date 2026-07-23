import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

class ImTextField extends StatelessWidget {
  const ImTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixText,
    this.suffix,
    this.enabled = true,
    this.autofillHints,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? prefixText;
  final Widget? suffix;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: ImColors.ink900,
          ),
        ),
        const SizedBox(height: ImSpacing.space8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          enabled: enabled,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            helperText: errorText == null ? helperText : null,
            errorText: errorText,
            prefixText: prefixText,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
