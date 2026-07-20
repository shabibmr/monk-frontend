import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/manager_repository.dart';
import '../cubit/roster_cubit.dart';

class ManagerRosterScreen extends StatelessWidget {
  const ManagerRosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RosterCubit(
        repository: getIt<ManagerRepository>(),
        sessionCubit: getIt<SessionCubit>(),
      )..load(),
      child: const _RosterView(),
    );
  }
}

class _RosterView extends StatelessWidget {
  const _RosterView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roster')),
      body: BlocConsumer<RosterCubit, RosterState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.infoMessage != null) {
            ImToast.show(
              context,
              message: state.infoMessage!,
              tone: ImToastTone.success,
            );
          }
        },
        builder: (context, state) {
          if (state.loading && state.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.entries.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(ImSpacing.space24),
              child: ImEmptyState(
                message:
                    'Invite an influencer or accept an invite to build your roster.',
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space24),
            itemCount: state.entries.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: ImSpacing.space12),
            itemBuilder: (context, i) {
              final e = state.entries[i];
              return ImCard(
                onTap: state.loading
                    ? null
                    : () async {
                        await context.read<RosterCubit>().selectProfile(e);
                        if (context.mounted) {
                          context.go('/c/dashboard');
                        }
                      },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: ImSpacing.space4),
                          Text(
                            e.country ?? '—',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: ImSpacing.space8),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (e.openApplications > 0)
                                ImStatusChip(
                                  status: EntityStatus.applicationsOpen,
                                  label: '${e.openApplications} applications',
                                ),
                              if (e.contentDue > 0)
                                ImStatusChip(
                                  status: EntityStatus.revisionRequested,
                                  label: '${e.contentDue} content due',
                                ),
                            ],
                          ),
                          const SizedBox(height: ImSpacing.space8),
                          ImMoneyText(
                            minorUnits: e.payableMinor,
                            currencyCode: e.currency,
                          ),
                        ],
                      ),
                    ),
                    ImStatusChip(status: e.verificationChip),
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
