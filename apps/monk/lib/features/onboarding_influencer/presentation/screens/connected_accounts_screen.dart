import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';

/// Standalone social accounts entry; full manage flow reuses wizard step 3 APIs.
class ConnectedAccountsScreen extends StatelessWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connected accounts')),
      body: Padding(
        padding: const EdgeInsets.all(ImSpacing.space24),
        child: ImEmptyState(
          message: 'Manage social connects from onboarding or settings.',
          actionLabel: 'Open onboarding',
          onAction: () => context.go('/c/onboarding'),
        ),
      ),
    );
  }
}
