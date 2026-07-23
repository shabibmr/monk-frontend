import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubit/sessions_cubit.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionsCubit(getIt<AuthRepository>())..load(),
      child: const _SessionsView(),
    );
  }
}

class _SessionsView extends StatelessWidget {
  const _SessionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: BlocConsumer<SessionsCubit, SessionsState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
        },
        builder: (context, state) {
          if (state.loading && state.sessions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.sessions.isEmpty) {
            return const ImEmptyState(message: 'No active sessions');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space24),
            itemCount: state.sessions.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: ImSpacing.space12),
            itemBuilder: (context, index) {
              final s = state.sessions[index];
              return ImCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.userAgent ?? 'Unknown device',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: ImSpacing.space4),
                          Text(
                            s.ipAddress ?? '—',
                            style:
                                Theme.of(context).textTheme.bodySmall,
                          ),
                          if (s.current)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: ImSpacing.space8,
                              ),
                              child: Text(
                                'Current session',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: ImColors.success600,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!s.current)
                      ImButton(
                        label: 'Revoke',
                        variant: ImButtonVariant.destructive,
                        onPressed: () =>
                            context.read<SessionsCubit>().revoke(s.id),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
