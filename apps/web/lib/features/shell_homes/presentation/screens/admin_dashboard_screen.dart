import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Admin ops home (T1.16 polish) — links to verification + sessions.
/// No secrets; KPI aggregates await future admin analytics APIs.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionCubit>().state.user;
    return ListView(
      padding: const EdgeInsets.all(ImSpacing.space24),
      children: [
        Text(
          'Admin dashboard',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: ImSpacing.space8),
        Text(
          'Verification, agency briefs, and session tools. '
          'Client never holds API secrets — only public base URL from environment.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: ImColors.ink600,
              ),
        ),
        if (user != null) ...[
          const SizedBox(height: ImSpacing.space16),
          ImCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? user.email,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(user.email, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
        const SizedBox(height: ImSpacing.space24),
        Text('Ops shortcuts', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ImSpacing.space12),
        Wrap(
          spacing: ImSpacing.space12,
          runSpacing: ImSpacing.space12,
          children: [
            SizedBox(
              width: 220,
              child: ImCard(
                onTap: () => context.go('/a/verification'),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.fact_check_outlined),
                    SizedBox(height: ImSpacing.space8),
                    Text('Verification queue'),
                    Text(
                      'KYC & license review',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: ImCard(
                onTap: () => context.go('/a/agency/briefs'),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.work_outline),
                    SizedBox(height: ImSpacing.space8),
                    Text('Agency briefs'),
                    Text(
                      'Managed intake',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: ImCard(
                onTap: () => context.go('/a/settings/sessions'),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.devices_outlined),
                    SizedBox(height: ImSpacing.space8),
                    Text('Sessions'),
                    Text(
                      'Active devices',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ImSpacing.space24),
        TextButton(
          onPressed: () =>
              context.read<AuthBloc>().add(const AuthLogoutRequested()),
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
