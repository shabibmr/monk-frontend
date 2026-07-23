import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/dispute_repository.dart';
import '../bloc/disputes_bloc.dart';

class DisputeFilingScreen extends StatelessWidget {
  const DisputeFilingScreen({
    super.key,
    required this.collaborationId,
    this.paymentId,
  });

  final String collaborationId;
  final String? paymentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DisputesBloc(getIt<DisputeRepository>()),
      child: _DisputeFilingView(
        collaborationId: collaborationId,
        paymentId: paymentId,
      ),
    );
  }
}

class _DisputeFilingView extends StatefulWidget {
  const _DisputeFilingView({
    required this.collaborationId,
    this.paymentId,
  });

  final String collaborationId;
  final String? paymentId;

  @override
  State<_DisputeFilingView> createState() => _DisputeFilingViewState();
}

class _DisputeFilingViewState extends State<_DisputeFilingView> {
  final _descriptionController = TextEditingController();
  String _reason = 'non_delivery';
  final List<String> _evidenceUrls = [];

  final List<String> _reasons = [
    'non_delivery',
    'quality_issue',
    'breach_of_terms',
    'payment_dispute',
    'other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File a Dispute')),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Payment Freeze Warning Box
                ImCard(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(ImRadii.radiusMd),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    padding: const EdgeInsets.all(ImSpacing.space16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                          size: 28,
                        ),
                        const SizedBox(width: ImSpacing.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Freeze Warning',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.amber.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: ImSpacing.space4),
                              Text(
                                'Filing a dispute will immediately freeze all escrowed funds and pending payments for this collaboration until an administrator completes formal resolution.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.amber.shade900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ImSpacing.space24),
                ImCard(
                  child: Padding(
                    padding: const EdgeInsets.all(ImSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dispute Information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: ImSpacing.space16),
                        DropdownButtonFormField<String>(
                          value: _reason,
                          decoration:
                              const InputDecoration(labelText: 'Dispute Reason'),
                          items: _reasons.map((r) {
                            return DropdownMenuItem(
                              value: r,
                              child: Text(
                                r.replaceAll('_', ' ').toUpperCase(),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _reason = val);
                          },
                        ),
                        const SizedBox(height: ImSpacing.space16),
                        ImTextField(
                          label: 'Detailed Description',
                          controller: _descriptionController,
                          hint:
                              'Explain the issue clearly with dates and references...',
                          maxLines: 5,
                        ),
                        const SizedBox(height: ImSpacing.space16),
                        Text(
                          'Evidence Files / Screenshots',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: ImSpacing.space8),
                        ImFileUploader(
                          label: 'Evidence File Reference ID',
                          onFileIdChanged: (url) {
                            if (url.isNotEmpty && !_evidenceUrls.contains(url)) {
                              setState(() => _evidenceUrls.add(url));
                              ImToast.show(context, message: 'Evidence added');
                            }
                          },
                        ),
                        if (_evidenceUrls.isNotEmpty) ...[
                          const SizedBox(height: ImSpacing.space8),
                          Wrap(
                            spacing: ImSpacing.space8,
                            children: _evidenceUrls
                                .map((url) => Chip(
                                      label: Text(url.split('/').last),
                                      onDeleted: () {
                                        setState(
                                          () => _evidenceUrls.remove(url),
                                        );
                                      },
                                    ))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: ImSpacing.space24),
                        ImButton(
                          label: 'File Dispute & Freeze Funds',
                          variant: ImButtonVariant.destructive,
                          loading: state.submitting,
                          onPressed: state.submitting
                              ? null
                              : () {
                                  final desc =
                                      _descriptionController.text.trim();
                                  if (desc.isNotEmpty) {
                                    context.read<DisputesBloc>().add(
                                          FileDisputeSubmitted(
                                            collaborationId:
                                                widget.collaborationId,
                                            reason: _reason,
                                            description: desc,
                                            paymentId: widget.paymentId,
                                            evidenceUrls: _evidenceUrls,
                                          ),
                                        );
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
