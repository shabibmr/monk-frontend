import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/repositories/dispute_repository.dart';
import '../bloc/disputes_bloc.dart';

class AdminDisputeResolutionPanel extends StatelessWidget {
  const AdminDisputeResolutionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DisputesBloc(getIt<DisputeRepository>())
        ..add(const LoadAdminDisputesRequested()),
      child: const _AdminDisputePanelCardView(),
    );
  }
}

class _AdminDisputePanelCardView extends StatefulWidget {
  const _AdminDisputePanelCardView();

  @override
  State<_AdminDisputePanelCardView> createState() =>
      _AdminDisputePanelCardViewState();
}

class _AdminDisputePanelCardViewState
    extends State<_AdminDisputePanelCardView> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showResolveDialog(
    BuildContext context,
    Dispute dispute,
    String resolution,
  ) {
    _notesController.clear();
    final bloc = context.read<DisputesBloc>();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            resolution == 'resolved_refund'
                ? 'Resolve: Refund Brand'
                : 'Resolve: Release to Creator',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Are you sure you want to resolve dispute #${dispute.id} with resolution "$resolution"?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: ImSpacing.space12),
              ImTextField(
                label: 'Admin Notes / Resolution Rationale',
                controller: _notesController,
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ImButton(
              label: 'Confirm Resolution',
              onPressed: () {
                bloc.add(
                  ResolveDisputeSubmitted(
                    disputeId: dispute.id,
                    resolution: resolution,
                    notes: _notesController.text.trim(),
                  ),
                );
                Navigator.of(dialogCtx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  EntityStatus _disputeStatusToChip(String status) {
    switch (status) {
      case 'open':
      case 'under_review':
        return EntityStatus.inReview;
      case 'resolved_refund':
      case 'resolved_release':
      case 'closed':
        return EntityStatus.completed;
      default:
        return EntityStatus.draft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dispute Resolution Panel')),
      body: BlocConsumer<DisputesBloc, DisputesState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.infoMessage != null) {
            ImToast.show(context, message: state.infoMessage!);
          }
        },
        builder: (context, state) {
          if (state.loading && state.adminDisputes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.adminDisputes.isEmpty) {
            return const ImEmptyState(
              message: 'All filed disputes have been reviewed and resolved.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space16),
            itemCount: state.adminDisputes.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: ImSpacing.space16),
            itemBuilder: (context, index) {
              final dispute = state.adminDisputes[index];
              return ImCard(
                child: Padding(
                  padding: const EdgeInsets.all(ImSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dispute #${dispute.id}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ImStatusChip(
                            status: _disputeStatusToChip(dispute.status),
                            label: dispute.status.replaceAll('_', ' ').toUpperCase(),
                          ),
                        ],
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        'Collaboration ID: ${dispute.collaborationId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Reason: ${dispute.reason}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        dispute.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (dispute.evidenceUrls.isNotEmpty) ...[
                        const SizedBox(height: ImSpacing.space8),
                        Text(
                          'Evidence Files:',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Wrap(
                          spacing: ImSpacing.space8,
                          children: dispute.evidenceUrls
                              .map(
                                (url) => Chip(
                                  label: Text(url.split('/').last),
                                  avatar: const Icon(Icons.attachment, size: 16),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (dispute.isOpen) ...[
                        const SizedBox(height: ImSpacing.space16),
                        Row(
                          children: [
                            Expanded(
                              child: ImButton(
                                label: 'Refund Brand',
                                variant: ImButtonVariant.destructive,
                                onPressed: () => _showResolveDialog(
                                  context,
                                  dispute,
                                  'resolved_refund',
                                ),
                              ),
                            ),
                            const SizedBox(width: ImSpacing.space12),
                            Expanded(
                              child: ImButton(
                                label: 'Release to Creator',
                                onPressed: () => _showResolveDialog(
                                  context,
                                  dispute,
                                  'resolved_release',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
