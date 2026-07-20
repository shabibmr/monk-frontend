import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/licensing_repository.dart';
import '../bloc/licensing_bloc.dart';

class LicensingGrantDeliveryScreen extends StatelessWidget {
  const LicensingGrantDeliveryScreen({
    super.key,
    required this.grantId,
  });

  final String grantId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LicensingBloc(getIt<LicensingRepository>())
        ..add(LoadLicensingGrantDetailRequested(grantId)),
      child: const _GrantDeliveryView(),
    );
  }
}

class _GrantDeliveryView extends StatelessWidget {
  const _GrantDeliveryView();

  EntityStatus _mapGrantStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return EntityStatus.termsAccepted;
      case 'expired':
        return EntityStatus.inReview;
      case 'revoked':
        return EntityStatus.cancelled;
      default:
        return EntityStatus.draft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Licensing Grant Delivery')),
      body: BlocConsumer<LicensingBloc, LicensingState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.infoMessage != null) {
            ImToast.show(context, message: state.infoMessage!);
          }
        },
        builder: (context, state) {
          if (state.loading && state.activeGrant == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final grant = state.activeGrant;
          if (grant == null) {
            return const ImEmptyState(
              message: 'The requested licensing grant details are unavailable.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Licensing Grant #${grant.id}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ImStatusChip(
                      status: _mapGrantStatus(grant.status),
                      label: grant.status.toUpperCase(),
                    ),
                  ],
                ),
                const SizedBox(height: ImSpacing.space16),
                ImCard(
                  child: Padding(
                    padding: const EdgeInsets.all(ImSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asset Delivery & License Token',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: ImSpacing.space12),
                        Text('Asset URL:',
                            style: Theme.of(context).textTheme.labelLarge),
                        SelectableText(
                          grant.assetUrl,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: ImColors.info600,
                              ),
                        ),
                        const SizedBox(height: ImSpacing.space12),
                        Text('Verification Token:',
                            style: Theme.of(context).textTheme.labelLarge),
                        Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                grant.token,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              tooltip: 'Copy Token',
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: grant.token),
                                );
                                ImToast.show(context, message: 'Token copied!');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ImSpacing.space16),
                ImCard(
                  child: Padding(
                    padding: const EdgeInsets.all(ImSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Licensing Rights & Terms',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: ImSpacing.space12),
                        _InfoRow(label: 'Scope', value: grant.scope),
                        _InfoRow(label: 'Territory', value: grant.territory),
                        _InfoRow(
                            label: 'Duration',
                            value: '${grant.durationDays} days'),
                        _InfoRow(
                            label: 'Licensing Fee',
                            value: '\$${grant.fee.toStringAsFixed(2)}'),
                        if (grant.expiresAt != null)
                          _InfoRow(
                              label: 'Expires At', value: grant.expiresAt!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ImSpacing.space24),
                if (grant.isActive) ...[
                  ImButton(
                    label: 'Revoke License Grant',
                    variant: ImButtonVariant.destructive,
                    loading: state.submitting,
                    onPressed: state.submitting
                        ? null
                        : () {
                            context.read<LicensingBloc>().add(
                                  RevokeLicensingGrantSubmitted(grant.id),
                                );
                          },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ImSpacing.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
