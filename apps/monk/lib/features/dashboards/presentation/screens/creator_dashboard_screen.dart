import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../cubit/dashboard_cubit.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  String? _profileId;
  bool _resolving = true;
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final session = context.read<SessionCubit>().state;
    _isManager = session.role == UserRole.manager;
    try {
      if (_isManager) {
        setState(() => _resolving = false);
        return;
      }
      var id = session.activeProfileId;
      if (id == null) {
        final status = await getIt<InfluencerRepository>().loadOnboarding();
        id = status.profileId;
        context.read<SessionCubit>().setActiveProfile(
              profileId: id,
              isManagerContext: false,
            );
      }
      setState(() {
        _profileId = id;
        _resolving = false;
      });
    } catch (_) {
      setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_isManager) {
      return BlocProvider(
        create: (_) =>
            DashboardCubit(getIt<DashboardRepository>())..loadManager(),
        child: const _ManagerBody(),
      );
    }
    if (_profileId == null) {
      return const ImEmptyState(
        message: 'Complete onboarding to see your dashboard.',
      );
    }
    return BlocProvider(
      create: (_) => DashboardCubit(getIt<DashboardRepository>())
        ..loadProfile(_profileId!),
      child: const _CreatorBody(),
    );
  }
}

class _CreatorBody extends StatelessWidget {
  const _CreatorBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state.failure != null) {
          ErrorPresenter.show(context, state.failure!);
        }
      },
      builder: (context, state) {
        if (state.loading && state.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final d = state.profile;
        if (d == null || d.isEmpty) {
          return ImEmptyState(
            message: 'No collaboration activity yet — browse the marketplace.',
            actionLabel: 'Marketplace',
            onAction: () => context.go('/c/marketplace'),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(ImSpacing.space16),
          children: [
            Text(
              'Creator dashboard',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: ImSpacing.space16),
            Wrap(
              spacing: ImSpacing.space12,
              runSpacing: ImSpacing.space12,
              children: [
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Invitations',
                    valueText: '${d.invitations}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Content due',
                    valueText: '${d.pendingContent}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Earnings pending',
                    moneyMinor: d.earningsPendingMinor,
                    currencyCode: 'INR',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Earnings released',
                    moneyMinor: d.earningsReleasedMinor,
                    currencyCode: 'INR',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Reach',
                    valueText: '${d.metrics.reach}',
                  ),
                ),
              ],
            ),
            if (d.deadlines.isNotEmpty) ...[
              const SizedBox(height: ImSpacing.space24),
              Text(
                'Deadlines',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...d.deadlines.take(5).map(
                    (row) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Deliverable ${row['deliverableId']}'),
                      subtitle: Text(
                        'Due ${row['dueDate'] ?? row['publishDate'] ?? '—'}',
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: ImSpacing.space16),
            TextButton(
              onPressed: () => context.go('/c/metrics'),
              child: const Text('Enter manual post metrics'),
            ),
          ],
        );
      },
    );
  }
}

class _ManagerBody extends StatelessWidget {
  const _ManagerBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state.failure != null) {
          ErrorPresenter.show(context, state.failure!);
        }
      },
      builder: (context, state) {
        if (state.loading && state.manager == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final d = state.manager;
        if (d == null || d.isEmpty) {
          return const ImEmptyState(message: 'No roster activity yet.');
        }
        return ListView(
          padding: const EdgeInsets.all(ImSpacing.space16),
          children: [
            Text(
              'Manager dashboard',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: ImSpacing.space16),
            Wrap(
              spacing: ImSpacing.space12,
              runSpacing: ImSpacing.space12,
              children: [
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Roster size',
                    valueText: '${d.rosterSize}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Open tasks',
                    valueText: '${d.openTasks}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Collaborations',
                    valueText: '${d.collaborations}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Earnings rollup',
                    moneyMinor: d.earningsRollupMinor,
                    currencyCode: 'INR',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
