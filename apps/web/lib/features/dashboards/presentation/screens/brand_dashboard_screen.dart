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
import '../../domain/repositories/dashboard_repository.dart';
import '../cubit/dashboard_cubit.dart';

class BrandDashboardScreen extends StatefulWidget {
  const BrandDashboardScreen({super.key});

  @override
  State<BrandDashboardScreen> createState() => _BrandDashboardScreenState();
}

class _BrandDashboardScreenState extends State<BrandDashboardScreen> {
  String? _brandId;
  bool _resolving = true;

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
        _resolving = false;
      });
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
      setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_brandId == null) {
      return const ImEmptyState(message: 'Create a brand to see KPIs.');
    }
    return BlocProvider(
      create: (_) =>
          DashboardCubit(getIt<DashboardRepository>())..loadBrand(_brandId!),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state.failure != null) {
          ErrorPresenter.show(context, state.failure!);
        }
      },
      builder: (context, state) {
        if (state.loading && state.brand == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final d = state.brand;
        if (d == null || d.isEmpty) {
          return ImEmptyState(
            message: 'No campaign activity yet — post a campaign to populate KPIs.',
            actionLabel: 'Campaigns',
            onAction: () => context.go('/b/campaigns'),
          );
        }
        final m = d.metrics;
        return ListView(
          padding: const EdgeInsets.all(ImSpacing.space16),
          children: [
            Text(
              'Brand dashboard',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            if (!d.automatedSync)
              Padding(
                padding: const EdgeInsets.only(top: ImSpacing.space8),
                child: Text(
                  'Manual metrics only — automated sync not enabled (API).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: ImSpacing.space16),
            Wrap(
              spacing: ImSpacing.space12,
              runSpacing: ImSpacing.space12,
              children: [
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Campaigns',
                    valueText: '${d.totalCampaigns}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Pending approvals',
                    valueText: '${d.pendingApprovals}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Spend',
                    moneyMinor: d.spendMinor,
                    currencyCode: 'INR',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Pending payments',
                    moneyMinor: d.pendingPaymentsAmountMinor,
                    currencyCode: 'INR',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Reach',
                    valueText: '${m.reach}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Engagement',
                    valueText: '${m.engagement}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Impressions',
                    valueText: '${m.impressions}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Clicks',
                    valueText: '${m.clicks}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Upcoming posts',
                    valueText: '${d.upcomingPosts}',
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ImKpiCard(
                    label: 'Managed active',
                    valueText: '${d.managedCollaborationsActive}',
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
