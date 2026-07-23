import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/brief_repository.dart';
import '../cubit/brief_list_cubit.dart';

class BriefListScreen extends StatelessWidget {
  const BriefListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BriefListCubit(getIt<BriefRepository>())..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Managed briefs'),
        actions: [
          TextButton(
            onPressed: () => context.go('/b/briefs/new'),
            child: const Text('Submit brief'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/b/briefs/new'),
        label: const Text('Submit brief'),
        icon: const Icon(Icons.add),
      ),
      body: BlocConsumer<BriefListCubit, BriefListState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return ImEmptyState(
              message:
                  'No managed briefs yet — submit goals for the agency to build.',
              actionLabel: 'Submit brief',
              onAction: () => context.go('/b/briefs/new'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            b.goals,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        ImStatusChip(status: b.statusChip),
                      ],
                    ),
                    const SizedBox(height: ImSpacing.space8),
                    Text(
                      'Status ${b.status.replaceAll('_', ' ')}'
                      '${b.campaignId != null ? ' · campaign ${b.campaignId!.substring(0, 8)}…' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (b.budgetMinor != null)
                      Padding(
                        padding: const EdgeInsets.only(top: ImSpacing.space8),
                        child: ImMoneyText(
                          minorUnits: b.budgetMinor!,
                          currencyCode: b.currency ?? 'INR',
                        ),
                      ),
                    // Never invent fee lines
                    if (b.showAgencyFee)
                      Text('Agency fee: ${b.agencyFeeMinor}')
                    else
                      Text(
                        'Managed fee: none',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ImColors.ink600,
                            ),
                      ),
                    if (b.campaignId != null)
                      TextButton(
                        onPressed: () =>
                            context.go('/b/campaigns/${b.campaignId}'),
                        child: const Text('Open campaign'),
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
