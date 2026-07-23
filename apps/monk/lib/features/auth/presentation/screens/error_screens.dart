import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImEmptyState(
        message: 'You do not have access to this area.',
        actionLabel: 'Go home',
        onAction: () => context.go('/'),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(ImSpacing.space32),
        child: ImEmptyState(
          message: 'Page not found',
          actionLabel: 'Go home',
          onAction: () => context.go('/'),
        ),
      ),
    );
  }
}
