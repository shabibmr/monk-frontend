import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../cubit/marketplace_cubit.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketplaceCubit(getIt<MarketplaceRepository>())..load(),
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
        title: const Text('Marketplace'),
        actions: [
          TextButton(
            onPressed: () => context.go('/c/applications'),
            child: const Text('My applications'),
          ),
        ],
      ),
      body: BlocConsumer<MarketplaceCubit, MarketplaceState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
        },
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return ListView.separated(
              padding: const EdgeInsets.all(ImSpacing.space16),
              itemCount: 4,
              separatorBuilder: (c, i) =>
                  const SizedBox(height: ImSpacing.space12),
              itemBuilder: (c, i) => const ImSkeletonCard(),
            );
          }
          if (state.isEmpty) {
            return ImEmptyState(
              message:
                  'No open campaigns right now. Complete your profile and KYC to stay ready to apply.',
              actionLabel: 'View applications',
              onAction: () => context.go('/c/applications'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<MarketplaceCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(ImSpacing.space16),
              itemCount:
                  state.items.length + (state.nextCursor != null ? 1 : 0),
              separatorBuilder: (c, i) =>
                  const SizedBox(height: ImSpacing.space12),
              itemBuilder: (context, i) {
                if (i >= state.items.length) {
                  return Center(
                    child: TextButton(
                      onPressed: state.loading
                          ? null
                          : () =>
                              context.read<MarketplaceCubit>().loadMore(),
                      child: Text(state.loading ? 'Loading…' : 'Load more'),
                    ),
                  );
                }
                final c = state.items[i];
                final budget = c.budgetTotalMinor != null && c.currency != null
                    ? formatMoneyMinor(c.budgetTotalMinor!, c.currency!)
                    : null;
                return ImCard(
                  onTap: () => context.go('/c/marketplace/${c.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          ImStatusChip(
                            status: EntityStatus.applicationsOpen,
                            label: c.status.replaceAll('_', ' '),
                          ),
                        ],
                      ),
                      if (c.brand != null) ...[
                        const SizedBox(height: ImSpacing.space4),
                        Text(
                          c.brand!.companyName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: ImSpacing.space8),
                      Wrap(
                        spacing: ImSpacing.space8,
                        runSpacing: ImSpacing.space4,
                        children: [
                          if (c.objective != null)
                            Chip(label: Text(c.objective!)),
                          ...c.permittedCollabTypes
                              .where((t) => t != 'licensing')
                              .map((t) => Chip(label: Text(t))),
                          if (budget != null) Chip(label: Text(budget)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
