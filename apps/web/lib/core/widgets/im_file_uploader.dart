import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'im_text_field.dart';

/// Lightweight file reference capture for MVP.
/// Full upload (files API) wires through [onFileIdChanged];
/// never logs document bytes.
class ImFileUploader extends StatefulWidget {
  const ImFileUploader({
    super.key,
    required this.label,
    this.helperText =
        'Paste file id from upload API (bytes never stored in UI state logs)',
    this.initialFileId,
    this.onFileIdChanged,
    this.enabled = true,
  });

  final String label;
  final String? helperText;
  final String? initialFileId;
  final ValueChanged<String>? onFileIdChanged;
  final bool enabled;

  @override
  State<ImFileUploader> createState() => _ImFileUploaderState();
}

class _ImFileUploaderState extends State<ImFileUploader> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialFileId ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ImTextField(
          label: widget.label,
          helperText: widget.helperText,
          controller: _controller,
          enabled: widget.enabled,
          onChanged: widget.onFileIdChanged,
        ),
        const SizedBox(height: ImSpacing.space8),
        Text(
          'Do not paste document contents — only server file ids.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ImColors.ink600,
              ),
        ),
      ],
    );
  }
}
