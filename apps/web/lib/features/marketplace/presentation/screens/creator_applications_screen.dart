import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../cubit/creator_applications_cubit.dart';

class CreatorApplicationsScreen extends StatefulWidget {
  const CreatorApplicationsScreen({super.key});

  @override
  State<CreatorApplicationsScreen> createState() =>
      _CreatorApplicationsScreenState();
}

class _CreatorApplicationsScreenState extends State<CreatorApplicationsScreen> {
  String? _profileId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      var id = context.read<SessionCubit>().state.activeProfileId;
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
        _loading = false;
      });
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My applications')),
        body: const ImEmptyState(
          message: 'Complete influencer onboarding to track applications.',
        ),
      );
    }
    return BlocProvider(
      create: (_) => CreatorApplicationsCubit(
        getIt<MarketplaceRepository>(),
        _profileId!,
      )..load(),
      child: const _ListView(),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView();

  String _shortId(String id) =>
      id.length <= 8 ? id : '${id.substring(0, 8)}…';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My applications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/c/marketplace'),
        ),
      ),
      body: BlocConsumer<CreatorApplicationsCubit, CreatorApplicationsState>(
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
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return ImEmptyState(
              message: 'No applications yet — browse the marketplace.',
              actionLabel: 'Marketplace',
              onAction: () => context.go('/c/marketplace'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space16),
            itemCount: state.items.length,
            separatorBuilder: (c, i) =>
                const SizedBox(height: ImSpacing.space12),
            itemBuilder: (context, i) {
              final a = state.items[i];
              return ImCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Campaign ${_shortId(a.campaignId)}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        ImStatusChip(status: a.statusChip),
                      ],
                    ),
                    const SizedBox(height: ImSpacing.space4),
                    Text(
                      'Origin: ${a.origin} · ${a.proposedCollabType ?? '—'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (a.pitch != null && a.pitch!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: ImSpacing.space4),
                        child: Text(a.pitch!),
                      ),
                    if (a.rejectionReason != null)
                      Padding(
                        padding: const EdgeInsets.only(top: ImSpacing.space4),
                        child: Text(
                          'Reason: ${a.rejectionReason}',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    const SizedBox(height: ImSpacing.space8),
                    Wrap(
                      spacing: ImSpacing.space8,
                      children: [
                        if (a.isPendingInvite) ...[
                          FilledButton(
                            onPressed: () => context
                                .read<CreatorApplicationsCubit>()
                                .acceptInvite(a.id),
                            child: const Text('Accept invite'),
                          ),
                          OutlinedButton(
                            onPressed: () => context
                                .read<CreatorApplicationsCubit>()
                                .declineInvite(a.id),
                            child: const Text('Decline'),
                          ),
                        ],
                        if (a.canWithdraw && !a.isPendingInvite)
                          TextButton(
                            onPressed: () => context
                                .read<CreatorApplicationsCubit>()
                                .withdraw(a.id),
                            child: const Text('Withdraw'),
                          ),
                        TextButton(
                          onPressed: () =>
                              context.go('/c/marketplace/${a.campaignId}'),
                          child: const Text('View campaign'),
                        ),
                      ],
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
