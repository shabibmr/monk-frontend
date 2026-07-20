import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../cubit/payment_cubit.dart';

class CollabPaymentsScreen extends StatelessWidget {
  const CollabPaymentsScreen({super.key, required this.collaborationId});

  final String collaborationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentCubit(
        getIt<PaymentRepository>(),
        collaborationId,
      )..load(),
      child: _View(collaborationId: collaborationId),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.collaborationId});
  final String collaborationId;

  Future<void> _confirmRelease(BuildContext context, Payment p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Release payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Breakdown from server snapshot fields only (no client fee math):',
            ),
            const SizedBox(height: ImSpacing.space12),
            ...p.apiFeeBreakdown.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                child: Row(
                  children: [
                    Expanded(child: Text(line.label)),
                    ImMoneyText(
                      minorUnits: line.amountMinor,
                      currencyCode: p.currency,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Release payment'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<PaymentCubit>().release(p.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaboration payments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/b/applications'),
        ),
      ),
      body: BlocConsumer<PaymentCubit, PaymentState>(
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
          if (state.loading && state.payments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space16),
            children: [
              if (state.barterOnly)
                ImCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No cash settlement — pure barter fulfillment.',
                      ),
                      TextButton(
                        onPressed: () => context.go(
                          '/b/collaborations/$collaborationId/barter',
                        ),
                        child: const Text('Open barter panel'),
                      ),
                    ],
                  ),
                )
              else ...[
                FilledButton(
                  onPressed: state.acting
                      ? null
                      : () => context.read<PaymentCubit>().fund(),
                  child: Text(
                    state.acting ? 'Working…' : 'Fund collaboration',
                  ),
                ),
                if (state.lastCheckout != null) ...[
                  const SizedBox(height: ImSpacing.space8),
                  Text(
                    'Checkout order: ${state.lastCheckout!['orderId']} '
                    '(public key ${state.lastCheckout!['keyId']})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
              const SizedBox(height: ImSpacing.space16),
              if (state.payments.isEmpty && !state.barterOnly)
                const ImEmptyState(message: 'No payments yet for this collab.')
              else
                ...state.payments.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: ImSpacing.space12),
                    child: ImCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ImMoneyText(
                                  minorUnits: p.amountMinor,
                                  currencyCode: p.currency,
                                ),
                              ),
                              ImStatusChip(status: p.statusChip),
                            ],
                          ),
                          Text(
                            'Commission snapshot: ${p.commissionPct}%'
                            '${p.commissionMinor != null ? ' · fee amount from API' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: ImSpacing.space8),
                          Wrap(
                            spacing: ImSpacing.space8,
                            children: [
                              if (p.canRelease)
                                FilledButton(
                                  onPressed: state.acting
                                      ? null
                                      : () => _confirmRelease(context, p),
                                  child: const Text('Release payment'),
                                ),
                              if (p.status == 'held' || p.status == 'funded')
                                OutlinedButton(
                                  onPressed: state.acting
                                      ? null
                                      : () => context
                                          .read<PaymentCubit>()
                                          .refund(p.id),
                                  child: const Text('Refund'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
