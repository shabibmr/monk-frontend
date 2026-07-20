import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';

class ContractAmendmentDialog extends StatefulWidget {
  const ContractAmendmentDialog({
    super.key,
    required this.contractId,
    required this.collaborationId,
    required this.onSubmit,
  });

  final String contractId;
  final String collaborationId;
  final Function(String title, String reason, String amendedTerms) onSubmit;

  @override
  State<ContractAmendmentDialog> createState() =>
      _ContractAmendmentDialogState();
}

class _ContractAmendmentDialogState extends State<ContractAmendmentDialog> {
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();
  final _termsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Contract Amendment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImTextField(
              label: 'Amendment Title',
              controller: _titleController,
            ),
            const SizedBox(height: ImSpacing.space12),
            ImTextField(
              label: 'Reason for Amendment',
              controller: _reasonController,
              maxLines: 3,
            ),
            const SizedBox(height: ImSpacing.space12),
            ImTextField(
              label: 'Amended Terms / Specific Changes',
              controller: _termsController,
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ImButton(
          label: 'Submit Request',
          onPressed: () {
            final title = _titleController.text.trim();
            final reason = _reasonController.text.trim();
            final terms = _termsController.text.trim();
            if (title.isNotEmpty && reason.isNotEmpty && terms.isNotEmpty) {
              widget.onSubmit(title, reason, terms);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
