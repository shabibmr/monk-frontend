import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/dispute_repository.dart';
import '../bloc/disputes_bloc.dart';

class DataErasureStatusScreen extends StatelessWidget {
  const DataErasureStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DisputesBloc(getIt<DisputeRepository>())
        ..add(const LoadDataErasureRequestsRequested()),
      child: const _DataErasureView(),
    );
  }
}

class _DataErasureView extends StatefulWidget {
  const _DataErasureView();

  @override
  State<_DataErasureView> createState() => _DataErasureViewState();
}

class _DataErasureViewState extends State<_DataErasureView> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  EntityStatus _mapErasureStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return EntityStatus.draft;
      case 'in_progress':
        return EntityStatus.inProgress;
      case 'completed':
        return EntityStatus.completed;
      case 'rejected':
        return EntityStatus.cancelled;
      default:
        return EntityStatus.draft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Erasure Requests (GDPR)')),
      body: BlocConsumer<DisputesBloc, DisputesState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.infoMessage != null) {
            ImToast.show(context, message: state.infoMessage!);
            _reasonController.clear();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ImCard(
                  child: Padding(
                    padding: const EdgeInsets.all(ImSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit Data Erasure Request',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: ImSpacing.space8),
                        Text(
                          'In compliance with GDPR and privacy standards, you may request full erasure of your account data. Pending requests will be processed within 30 days.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: ImSpacing.space16),
                        ImTextField(
                          label: 'Reason for Erasure Request',
                          controller: _reasonController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: ImSpacing.space16),
                        ImButton(
                          label: 'Submit Erasure Request',
                          variant: ImButtonVariant.destructive,
                          loading: state.submitting,
                          onPressed: state.submitting
                              ? null
                              : () {
                                  final reason = _reasonController.text.trim();
                                  if (reason.isNotEmpty) {
                                    context.read<DisputesBloc>().add(
                                          SubmitDataErasureRequested(reason),
                                        );
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ImSpacing.space24),
                Text(
                  'Your Data Erasure Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ImSpacing.space12),
                if (state.loading && state.erasureRequests.isEmpty) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (state.erasureRequests.isEmpty) ...[
                  const ImEmptyState(
                    message: 'You have not submitted any data erasure requests.',
                  ),
                ] else ...[
                  ...state.erasureRequests.map(
                    (req) => Padding(
                      padding: const EdgeInsets.only(bottom: ImSpacing.space12),
                      child: ImCard(
                        child: Padding(
                          padding: const EdgeInsets.all(ImSpacing.space16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Request #${req.id}',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  ImStatusChip(
                                    status: _mapErasureStatus(req.status),
                                    label: req.status.replaceAll('_', ' ').toUpperCase(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: ImSpacing.space8),
                              Text('Reason: ${req.reason}',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              if (req.requestedAt != null)
                                Text('Submitted: ${req.requestedAt}',
                                    style: Theme.of(context).textTheme.bodySmall),
                              if (req.rejectionReason != null)
                                Text(
                                  'Rejection reason: ${req.rejectionReason}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.red),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
