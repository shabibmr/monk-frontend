import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_brand/domain/repositories/brand_repository.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../cubit/campaign_list_cubit.dart';

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  String? _brandId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      var id = context.read<SessionCubit>().state.activeBrandId;
      if (id == null) {
        final brands = await getIt<BrandRepository>().listMine();
        if (brands.isNotEmpty) {
          id = brands.first.id;
          context.read<SessionCubit>().setActiveBrand(id);
        }
      }
      setState(() {
        _brandId = id;
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
    if (_brandId == null) {
      return const Scaffold(
        body: ImEmptyState(message: 'Create a brand before campaigns.'),
      );
    }
    return BlocProvider(
      create: (_) =>
          CampaignListCubit(getIt<CampaignRepository>(), _brandId!)..load(),
      child: const _ListView(),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
        actions: [
          TextButton(
            onPressed: () => context.go('/b/campaigns/new'),
            child: const Text('New campaign'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/b/campaigns/new'),
        label: const Text('Post campaign'),
        icon: const Icon(Icons.add),
      ),
      body: BlocConsumer<CampaignListCubit, CampaignListState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return ListView.separated(
              padding: const EdgeInsets.all(ImSpacing.space16),
              itemCount: 4,
              separatorBuilder: (c, i) =>
                  const SizedBox(height: ImSpacing.space12),
              itemBuilder: (c, i) => const ImSkeletonCard(),
            );
          }
          if (state.items.isEmpty) {
            return ImEmptyState(
              message: 'No campaigns yet — post your first one.',
              actionLabel: 'Post campaign',
              onAction: () => context.go('/b/campaigns/new'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space16),
            itemCount: state.items.length,
            separatorBuilder: (c, i) =>
                const SizedBox(height: ImSpacing.space12),
            itemBuilder: (context, i) {
              final c = state.items[i];
              return ImCard(
                onTap: () => context.go('/b/campaigns/${c.id}'),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${c.code} · ${c.mode.replaceAll('_', ' ')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (c.budgetTotalMinor != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: ImSpacing.space8,
                              ),
                              child: ImMoneyText(
                                minorUnits: c.budgetTotalMinor!,
                                currencyCode: c.currency ?? 'INR',
                              ),
                            ),
                        ],
                      ),
                    ),
                    ImStatusChip(status: c.statusChip),
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
