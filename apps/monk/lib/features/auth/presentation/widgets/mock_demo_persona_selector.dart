import 'package:flutter/material.dart';

import '../../../../core/mock/mock_ids.dart';
import '../../../../core/theme/tokens.dart';

/// Login chrome for offline demo — fills email/password from a persona list.
class MockDemoPersonaSelector extends StatelessWidget {
  const MockDemoPersonaSelector({
    super.key,
    required this.selectedEmail,
    required this.onSelected,
  });

  final String? selectedEmail;
  final ValueChanged<String> onSelected;

  static const _personas = <(String value, String label)>[
    (MockIds.emailCreator1, 'Creator (Arjun)'),
    (MockIds.emailBrand1, 'Brand User (Priya)'),
    (MockIds.emailManager1, 'Manager (Meera)'),
    (MockIds.emailAdmin, 'Admin'),
    (MockIds.emailAgency1, 'Agency (Alex)'),
    (MockIds.emailBrandFresh, 'Fresh Brand (Onboarding)'),
    (MockIds.emailCreatorFresh, 'Fresh Creator (Onboarding)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ImSpacing.space16),
      padding: const EdgeInsets.all(ImSpacing.space12),
      decoration: BoxDecoration(
        color: ImColors.coral100.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(ImRadii.radiusSm),
        border: Border.all(color: ImColors.coral500.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science_outlined, size: 16, color: ImColors.coral600),
              SizedBox(width: ImSpacing.space4),
              Text(
                'Mock Mode Demo Selector',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: ImColors.coral600,
                ),
              ),
            ],
          ),
          const SizedBox(height: ImSpacing.space8),
          DropdownButtonFormField<String>(
            initialValue: selectedEmail,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Demo User',
              isDense: true,
            ),
            hint: const Text('Choose persona to auto-fill credentials'),
            items: [
              for (final (value, label) in _personas)
                DropdownMenuItem(value: value, child: Text(label)),
            ],
            onChanged: (email) {
              if (email != null) onSelected(email);
            },
          ),
          const SizedBox(height: ImSpacing.space8),
          const Text(
            'Sign in with a short name — creator, brand, manager, admin, '
            'agency, newbrand, newcreator. Password for every persona: '
            '${MockIds.demoPassword}',
            style: TextStyle(fontSize: 11, color: ImColors.ink600),
          ),
        ],
      ),
    );
  }
}
