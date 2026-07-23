import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';

class LandingStubScreen extends StatelessWidget {
  const LandingStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(ImSpacing.space32),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MonkLogo(
                  height: 80,
                  heroTag: 'monk-brand-logo',
                ),
                const SizedBox(height: ImSpacing.space24),
                Text(
                  'Marketplace for brands and creators — start earning together.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ImColors.ink600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ImSpacing.space32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImButton(
                      label: 'Sign in',
                      onPressed: () => context.go('/login'),

                    ),
                    const SizedBox(width: ImSpacing.space16),
                    ImButton(
                      label: 'Create account',
                      variant: ImButtonVariant.secondary,
                      onPressed: () => context.go('/register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
