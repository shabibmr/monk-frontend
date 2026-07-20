import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../bloc/verification_bloc.dart';

class VerificationDetailScreen extends StatelessWidget {
  const VerificationDetailScreen({super.key, required this.kycId});

  final String kycId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerificationBloc(getIt<KycRepository>())
        ..add(const VerificationQueueLoaded())
        ..add(VerificationSelected(kycId)),
      child: _DetailView(kycId: kycId),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView({required this.kycId});
  final String kycId;

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  final _reason = TextEditingController();
  String? _templateKey;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/a/verification'),
        ),
      ),
      body: BlocConsumer<VerificationBloc, VerificationState>(
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
            context.go('/a/verification');
          }
        },
        builder: (context, state) {
          final matches = state.kyc.where((e) => e.id == widget.kycId);
          final record = state.selected ??
              (matches.isEmpty ? null : matches.first);

          if (state.phase == VerificationPhase.loading && record == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (record == null) {
            return ImEmptyState(
              message: 'KYC record not found or already processed.',
              actionLabel: 'Back to queue',
              onAction: () => context.go('/a/verification'),
            );
          }

          final acting = state.phase == VerificationPhase.acting;

          return Padding(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: ImCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'KYC ${record.id}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: ImSpacing.space8),
                  ImStatusChip(status: record.statusChip),
                  const SizedBox(height: ImSpacing.space16),
                  Text('Profile: ${record.influencerProfileId ?? "—"}'),
                  if (record.panMasked != null) Text('PAN: ${record.panMasked}'),
                  if (record.gstMasked != null) Text('GST: ${record.gstMasked}'),
                  if (record.accountMasked != null)
                    Text('Account: ${record.accountMasked}'),
                  if (record.identityDocFileId != null)
                    Text('Identity file: ${record.identityDocFileId}'),
                  const SizedBox(height: ImSpacing.space24),
                  Text(
                    'Rejection reason (if rejecting)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ImSpacing.space8),
                  if (state.templates.isNotEmpty)
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _templateKey,
                      items: state.templates
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.key,
                              child: Text(t.key),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _templateKey = v),
                      decoration: const InputDecoration(
                        labelText: 'Template',
                      ),
                    ),
                  const SizedBox(height: ImSpacing.space12),
                  ImTextField(
                    label: 'Custom reason',
                    controller: _reason,
                    maxLines: 3,
                  ),
                  const SizedBox(height: ImSpacing.space24),
                  Row(
                    children: [
                      Expanded(
                        child: ImButton(
                          label: 'Approve',
                          loading: acting,
                          onPressed: acting
                              ? null
                              : () => context.read<VerificationBloc>().add(
                                    VerificationApproved(widget.kycId),
                                  ),
                        ),
                      ),
                      const SizedBox(width: ImSpacing.space12),
                      Expanded(
                        child: ImButton(
                          label: 'Reject',
                          variant: ImButtonVariant.destructive,
                          loading: acting,
                          onPressed: acting
                              ? null
                              : () => context.read<VerificationBloc>().add(
                                    VerificationRejected(
                                      widget.kycId,
                                      templateKey: _templateKey,
                                      reason: _reason.text.trim().isEmpty
                                          ? null
                                          : _reason.text.trim(),
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
