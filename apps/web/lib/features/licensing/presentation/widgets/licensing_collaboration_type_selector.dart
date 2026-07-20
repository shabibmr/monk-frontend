import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

class LicensingCollaborationTypeSelector extends StatelessWidget {
  const LicensingCollaborationTypeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final String selectedMode;
  final ValueChanged<String> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collaboration / Campaign Mode',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: ImSpacing.space8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'self_serve',
              label: Text('Self-serve'),
              icon: Icon(Icons.person_outline),
            ),
            ButtonSegment(
              value: 'managed',
              label: Text('Managed'),
              icon: Icon(Icons.business_outlined),
            ),
            ButtonSegment(
              value: 'licensing',
              label: Text('Licensing Deal'),
              icon: Icon(Icons.verified_user_outlined),
            ),
          ],
          selected: {selectedMode},
          onSelectionChanged: (s) => onModeChanged(s.first),
        ),
      ],
    );
  }
}
