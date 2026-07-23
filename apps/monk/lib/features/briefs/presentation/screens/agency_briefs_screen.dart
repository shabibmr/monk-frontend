import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/brief.dart';
import '../../domain/repositories/brief_repository.dart';
import '../cubit/agency_briefs_cubit.dart';

class AgencyBriefsScreen extends StatelessWidget {
  const AgencyBriefsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AgencyBriefsCubit(getIt<BriefRepository>())..load(),
      child: const _ListView(),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency briefs')),
      body: BlocConsumer<AgencyBriefsCubit, AgencyBriefsState>(
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
            return const ImEmptyState(
              message: 'No briefs in the intake queue.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space16),
            itemCount: state.items.length,
            separatorBuilder: (c, i) =>
                const SizedBox(height: ImSpacing.space12),
            itemBuilder: (context, i) {
              final b = state.items[i];
              return ImCard(
                onTap: () => context.go('/a/agency/briefs/${b.id}'),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.goals,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            b.status.replaceAll('_', ' '),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    ImStatusChip(status: b.statusChip),
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

class AgencyBriefDetailScreen extends StatelessWidget {
  const AgencyBriefDetailScreen({super.key, required this.briefId});

  final String briefId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AgencyBriefsCubit(getIt<BriefRepository>())..load(),
      child: _DetailBody(briefId: briefId),
    );
  }
}

class _DetailBody extends StatefulWidget {
  const _DetailBody({required this.briefId});
  final String briefId;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  final _notes = TextEditingController();
  final _profileIds = TextEditingController();
  String? _campaignId;

  @override
  void dispose() {
    _notes.dispose();
    _profileIds.dispose();
    super.dispose();
  }

  Brief? _find(AgencyBriefsState state) {
    try {
      return state.items.firstWhere((b) => b.id == widget.briefId);
    } catch (_) {
      return state.selected?.id == widget.briefId ? state.selected : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brief detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/a/agency/briefs'),
        ),
      ),
      body: BlocConsumer<AgencyBriefsCubit, AgencyBriefsState>(
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
          final brief = _find(state);
          if (state.loading && brief == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (brief == null) {
            return ImEmptyState(
              message: 'Brief not found',
              actionLabel: 'Back',
              onAction: () => context.go('/a/agency/briefs'),
            );
          }
          _campaignId ??= brief.campaignId;
          final loading = state.loading;

          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            children: [
              ImCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            brief.goals,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        ImStatusChip(status: brief.statusChip),
                      ],
                    ),
                    const SizedBox(height: ImSpacing.space8),
                    Text('Status: ${brief.status.replaceAll('_', ' ')}'),
                    if (brief.productDescription != null)
                      Text(brief.productDescription!),
                    if (brief.budgetMinor != null)
                      Padding(
                        padding: const EdgeInsets.only(top: ImSpacing.space8),
                        child: ImMoneyText(
                          minorUnits: brief.budgetMinor!,
                          currencyCode: brief.currency ?? 'INR',
                        ),
                      ),
                    const SizedBox(height: ImSpacing.space8),
                    Text(
                      brief.showAgencyFee
                          ? 'Agency fee (API): ${brief.agencyFeeMinor}'
                          : 'Managed fee mode: none (no fee line)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ImColors.ink600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ImSpacing.space16),
              if (brief.status == 'submitted') ...[
                ImTextField(
                  label: 'Triage notes',
                  controller: _notes,
                  maxLines: 2,
                ),
                const SizedBox(height: ImSpacing.space12),
                ImButton(
                  label: 'Triage brief',
                  loading: loading,
                  onPressed: loading
                      ? null
                      : () => context.read<AgencyBriefsCubit>().triage(
                            brief.id,
                            notes: _notes.text.trim().isEmpty
                                ? null
                                : _notes.text.trim(),
                          ),
                ),
              ],
              if (brief.status == 'submitted' ||
                  brief.status == 'triaged' ||
                  brief.status == 'in_build') ...[
                const SizedBox(height: ImSpacing.space12),
                ImButton(
                  label: 'Convert / take ownership',
                  loading: loading,
                  onPressed: loading
                      ? null
                      : () async {
                          final r = await context
                              .read<AgencyBriefsCubit>()
                              .convert(brief.id);
                          if (r?.campaignId != null) {
                            setState(() => _campaignId = r!.campaignId);
                          }
                        },
                ),
              ],
              const SizedBox(height: ImSpacing.space24),
              Text(
                'Assign influencers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ImSpacing.space8),
              Text(
                'Comma-separated profile UUIDs (skips marketplace apply).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: ImSpacing.space8),
              ImTextField(
                label: 'Profile ids',
                controller: _profileIds,
                maxLines: 2,
              ),
              const SizedBox(height: ImSpacing.space12),
              ImButton(
                label: 'Assign',
                loading: loading,
                onPressed: loading ||
                        _campaignId == null ||
                        _profileIds.text.trim().isEmpty
                    ? null
                    : () {
                        final ids = _profileIds.text
                            .split(RegExp(r'[\s,]+'))
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        context.read<AgencyBriefsCubit>().assign(
                              campaignId: _campaignId!,
                              profileIds: ids,
                            );
                      },
              ),
              if (_campaignId != null)
                TextButton(
                  onPressed: () => context.go('/b/campaigns/$_campaignId'),
                  child: const Text('Open campaign (if brand context)'),
                ),
            ],
          );
        },
      ),
    );
  }
}
