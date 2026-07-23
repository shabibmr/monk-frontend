import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/contract.dart';
import '../../domain/repositories/contract_repository.dart';
import '../bloc/contract_bloc.dart';

class ContractScreen extends StatelessWidget {
  const ContractScreen({
    super.key,
    required this.collaborationId,
    this.portalHome = '/b/applications',
  });

  final String collaborationId;
  final String portalHome;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContractBloc(getIt<ContractRepository>())
        ..add(ContractLoaded(collaborationId)),
      child: _View(portalHome: portalHome),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.portalHome});
  final String portalHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(portalHome),
        ),
      ),
      body: BlocConsumer<ContractBloc, ContractState>(
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
          if (state.loading && state.contract == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final c = state.contract;
          if (c == null) {
            return const ImEmptyState(message: 'Contract not available.');
          }
          final rights = c.usageRights;
          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space16),
            children: [
              Row(
                children: [
                  ImStatusChip(status: c.statusChip),
                  const SizedBox(width: ImSpacing.space12),
                  Text(
                    c.status.replaceAll('_', ' '),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: ImSpacing.space16),
              ImCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: ImSpacing.space8),
                    Text(
                      'Template ${c.templateKey ?? '—'} · ${c.templateVersion ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: ImSpacing.space8),
                    SelectableText(
                      'Content hash: ${c.contentHash}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                    const SizedBox(height: ImSpacing.space12),
                    if (c.pdfUrl != null && c.pdfUrl!.isNotEmpty) ...[
                      Text(
                        'PDF (presigned URL — open in new tab)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: ImSpacing.space4),
                      SelectableText(
                        c.pdfUrl!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ImColors.info600,
                            ),
                      ),
                    ] else
                      Text(
                        'PDF link unavailable — usage rights and hash still apply.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: ImSpacing.space16),
              Text(
                'Usage rights',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ImSpacing.space8),
              if (rights == null)
                const Text('No usage rights on contract.')
              else
                _UsageRightsGrid(rights: rights),
              const SizedBox(height: ImSpacing.space24),
              if (state.showReceipt) ...[
                Text(
                  'Acceptance receipt',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ImSpacing.space8),
                ...c.acceptances.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                    child: ImCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${a.party} accepted'),
                          if (a.acceptedAt != null)
                            Text(
                              a.acceptedAt!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          SelectableText(
                            'Hash: ${a.contentHash}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: ImSpacing.space16),
              TextButton(
                onPressed: () {
                  final path = portalHome.startsWith('/c/')
                      ? '/c/collaborations/${c.collaborationId}/barter'
                      : '/b/collaborations/${c.collaborationId}/barter';
                  context.go(path);
                },
                child: const Text('Barter / product fulfillment'),
              ),
              if (!c.isReadOnly) ...[
                const SizedBox(height: ImSpacing.space16),
                CheckboxListTile(
                  value: state.agreed,
                  onChanged: state.accepting
                      ? null
                      : (v) => context
                          .read<ContractBloc>()
                          .add(ContractAgreeToggled(v ?? false)),
                  title: const Text('I agree to these contract terms'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: ImSpacing.space8),
                FilledButton(
                  onPressed: state.canAccept
                      ? () => context
                          .read<ContractBloc>()
                          .add(const ContractAcceptSubmitted())
                      : null,
                  child: Text(
                    state.accepting ? 'Recording…' : 'Accept terms',
                  ),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.only(top: ImSpacing.space16),
                  child: Chip(
                    label: Text('Read-only — terms accepted or void'),
                    backgroundColor: ImColors.success100,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _UsageRightsGrid extends StatelessWidget {
  const _UsageRightsGrid({required this.rights});
  final UsageRights rights;

  @override
  Widget build(BuildContext context) {
    final exclusivity = [
      if (rights.exclusivityCategory != null) rights.exclusivityCategory!,
      if (rights.exclusivityDays != null) '${rights.exclusivityDays} days',
    ].join(' · ');
    return Wrap(
      spacing: ImSpacing.space12,
      runSpacing: ImSpacing.space12,
      children: [
        _RightCard(
          title: 'Organic reuse',
          value: rights.organicReuse ? 'Allowed' : 'Not allowed',
        ),
        _RightCard(
          title: 'Paid amplification',
          value: rights.paidAmplification ? 'Allowed' : 'Not allowed',
        ),
        _RightCard(
          title: 'Duration',
          value: '${rights.durationDays} days',
        ),
        _RightCard(
          title: 'Territory',
          value: rights.territory.isEmpty ? '—' : rights.territory,
        ),
        _RightCard(
          title: 'Channels',
          value: rights.channels.isEmpty ? '—' : rights.channels.join(', '),
        ),
        _RightCard(
          title: 'Exclusivity',
          value: exclusivity.isEmpty ? '—' : exclusivity,
        ),
      ],
    );
  }
}

class _RightCard extends StatelessWidget {
  const _RightCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ImCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: ImSpacing.space4),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
