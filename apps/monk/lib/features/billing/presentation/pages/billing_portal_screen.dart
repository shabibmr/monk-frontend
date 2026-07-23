import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/im_card.dart';
import '../../../../core/widgets/im_skeleton.dart';
import '../../../../core/widgets/im_toast.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';
import '../widgets/active_plan_card.dart';
import '../widgets/invoice_history_list.dart';
import '../widgets/plan_upgrade_modal.dart';

class BillingPortalScreen extends StatelessWidget {
  const BillingPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillingBloc>(
      create: (_) => getIt<BillingBloc>()..add(const FetchBillingDetailsStarted()),
      child: const _BillingPortalContentView(),
    );
  }
}

class _BillingPortalContentView extends StatelessWidget {
  const _BillingPortalContentView();

  void _showUpgradeModal(BuildContext context, BillingState state) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<BillingBloc>(),
          child: BlocBuilder<BillingBloc, BillingState>(
            builder: (ctx, modalState) {
              return PlanUpgradeModal(
                plans: modalState.availablePlans,
                currentPlanId: modalState.subscription?.currentPlan.id ?? '',
                isSubmitting: modalState.isUpgrading,
                onSelectPlan: (planId) {
                  ctx.read<BillingBloc>().add(UpgradePlanRequested(planId));
                  Navigator.of(dialogContext).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<BillingBloc, BillingState>(
      listener: (context, state) {
        if (state.actionSuccessMessage != null) {
          ImToast.show(
            context,
            message: state.actionSuccessMessage!,
            tone: ImToastTone.success,
          );
        }
        if (state.failure != null) {
          ImToast.show(
            context,
            message: state.failure!.message,
            tone: ImToastTone.danger,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subscription & Billing Portal'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Manage your organization subscription plan, view multi-currency invoices, and upgrade your tier with server-formatted pricing.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<BillingBloc, BillingState>(
                builder: (context, state) {
                  if (state.phase == BillingPhase.loading && state.subscription == null) {
                    return const Column(
                      children: [
                        ImSkeleton(height: 220, width: double.infinity),
                        SizedBox(height: 24),
                        ImSkeleton(height: 180, width: double.infinity),
                      ],
                    );
                  }

                  if (state.phase == BillingPhase.failure && state.subscription == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.failure?.message ?? 'Failed to load billing information',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  final subscription = state.subscription;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subscription != null)
                        ActivePlanCard(
                          subscription: subscription,
                          onUpgradePressed: () => _showUpgradeModal(context, state),
                        ),
                      const SizedBox(height: 24),
                      InvoiceHistoryList(invoices: state.invoices),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
