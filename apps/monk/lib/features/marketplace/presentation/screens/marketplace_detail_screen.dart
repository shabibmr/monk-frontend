import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../cubit/marketplace_detail_cubit.dart';

class MarketplaceDetailScreen extends StatelessWidget {
  const MarketplaceDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketplaceDetailCubit(
        getIt<MarketplaceRepository>(),
        campaignId,
      )..load(),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView();

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  final _pitch = TextEditingController();
  String? _collab;
  String? _profileId;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    _resolveProfile();
  }

  Future<void> _resolveProfile() async {
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
        _resolving = false;
      });
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
      setState(() => _resolving = false);
    }
  }

  @override
  void dispose() {
    _pitch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/c/marketplace'),
        ),
      ),
      body: BlocConsumer<MarketplaceDetailCubit, MarketplaceDetailState>(
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
          if (state.loading || state.campaign == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final c = state.campaign!;
          _collab ??= c.applyCollabOptions.first;
          final budget = c.budgetTotalMinor != null && c.currency != null
              ? formatMoneyMinor(c.budgetTotalMinor!, c.currency!)
              : null;

          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space16),
            children: [
              Text(c.name, style: Theme.of(context).textTheme.headlineSmall),
              if (c.brand != null) ...[
                const SizedBox(height: ImSpacing.space8),
                Text(
                  c.brand!.companyName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              const SizedBox(height: ImSpacing.space12),
              Wrap(
                spacing: ImSpacing.space8,
                children: [
                  if (c.objective != null) Chip(label: Text(c.objective!)),
                  if (budget != null) Chip(label: Text(budget)),
                  Chip(label: Text(c.mode.replaceAll('_', ' '))),
                ],
              ),
              const SizedBox(height: ImSpacing.space16),
              Text('Deliverables', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: ImSpacing.space8),
              ...c.deliverables.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                  child: ImCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${d.platform} · ${d.deliverableType}'),
                        if (d.disclosureTags.isNotEmpty) ...[
                          const SizedBox(height: ImSpacing.space4),
                          Wrap(
                            spacing: 4,
                            children: d.disclosureTags
                                .map((t) => Chip(label: Text(t)))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: ImSpacing.space32),
              Text('Apply', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: ImSpacing.space8),
              if (_resolving)
                const LinearProgressIndicator()
              else if (_profileId == null)
                const ImEmptyState(
                  message:
                      'Create an influencer profile before applying. Complete onboarding first.',
                )
              else if (state.application != null)
                ImCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Application ${state.application!.status}'),
                      TextButton(
                        onPressed: () => context.go('/c/applications'),
                        child: const Text('View my applications'),
                      ),
                    ],
                  ),
                )
              else ...[
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _collab,
                  decoration: const InputDecoration(
                    labelText: 'Collaboration type',
                  ),
                  items: c.applyCollabOptions
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _collab = v),
                ),
                const SizedBox(height: ImSpacing.space12),
                TextField(
                  controller: _pitch,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Pitch / proposal',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: ImSpacing.space16),
                FilledButton(
                  onPressed: state.applying
                      ? null
                      : () {
                          context.read<MarketplaceDetailCubit>().apply(
                                profileId: _profileId!,
                                proposedCollabType: _collab ?? 'paid',
                                pitch: _pitch.text.trim().isEmpty
                                    ? null
                                    : _pitch.text.trim(),
                              );
                        },
                  child: Text(state.applying ? 'Submitting…' : 'Submit application'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
