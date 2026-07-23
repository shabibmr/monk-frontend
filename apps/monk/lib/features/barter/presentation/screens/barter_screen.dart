import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/barter_repository.dart';
import '../bloc/barter_bloc.dart';

/// Brand ship panel + creator receive (shared; role actions differ by API).
class BarterScreen extends StatelessWidget {
  const BarterScreen({
    super.key,
    required this.collaborationId,
    this.portalHome = '/b/applications',
    this.isCreator = false,
  });

  final String collaborationId;
  final String portalHome;
  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BarterBloc(getIt<BarterRepository>())
        ..add(BarterLoaded(collaborationId)),
      child: _View(
        portalHome: portalHome,
        isCreator: isCreator,
      ),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.portalHome, required this.isCreator});
  final String portalHome;
  final bool isCreator;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _tracking = TextEditingController();
  final _carrier = TextEditingController();
  final _notes = TextEditingController();
  final _evidenceIds = TextEditingController();

  @override
  void dispose() {
    _tracking.dispose();
    _carrier.dispose();
    _notes.dispose();
    _evidenceIds.dispose();
    super.dispose();
  }

  List<String> _parseEvidence() {
    return _evidenceIds.text
        .split(RegExp(r'[\s,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreator ? 'Receive product' : 'Barter fulfillment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(widget.portalHome),
        ),
      ),
      body: BlocConsumer<BarterBloc, BarterState>(
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
          if (state.loading && state.status == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = state.status;
          if (s == null) {
            return const ImEmptyState(message: 'Barter status unavailable.');
          }

          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space16),
            children: [
              Row(
                children: [
                  ImStatusChip(status: s.collabStatusChip),
                  const SizedBox(width: ImSpacing.space12),
                  Text(s.collabStatus.replaceAll('_', ' ')),
                  const SizedBox(width: ImSpacing.space12),
                  Chip(label: Text(s.collabType)),
                ],
              ),
              const SizedBox(height: ImSpacing.space16),
              ImCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content gate',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: ImSpacing.space8),
                    Text(
                      s.contentLockMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: s.contentUnlocked
                                ? ImColors.success600
                                : ImColors.warning600,
                          ),
                    ),
                    if (!s.contentUnlocked && s.requiresFulfillment)
                      const Padding(
                        padding: EdgeInsets.only(top: ImSpacing.space8),
                        child: Text(
                          'Ship → receive must complete before content submission.',
                        ),
                      ),
                  ],
                ),
              ),
              // Pure barter: never invent platform fee / cash charge UI.
              if (s.isPureBarter) ...[
                const SizedBox(height: ImSpacing.space12),
                const ImCard(
                  child: Text(
                    'Pure barter collaboration — no cash charge or platform fee lines on this panel.',
                  ),
                ),
              ],
              if (s.fulfillment != null) ...[
                const SizedBox(height: ImSpacing.space16),
                Text(
                  'Fulfillment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ImSpacing.space8),
                ImCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(s.fulfillment!.productDescription),
                          ),
                          ImStatusChip(status: s.fulfillment!.statusChip),
                        ],
                      ),
                      if (s.fulfillment!.declaredValueMinor != null) ...[
                        const SizedBox(height: ImSpacing.space8),
                        Text(
                          'Declared value (API): ${formatMoneyMinor(s.fulfillment!.declaredValueMinor!, 'INR')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (s.fulfillment!.trackingRef != null) ...[
                        const SizedBox(height: ImSpacing.space8),
                        Text('Tracking: ${s.fulfillment!.trackingRef}'),
                        if (s.fulfillment!.shippingCarrier != null)
                          Text('Carrier: ${s.fulfillment!.shippingCarrier}'),
                      ],
                      if (s.fulfillment!.evidenceFileIds.isNotEmpty) ...[
                        const SizedBox(height: ImSpacing.space8),
                        Text(
                          'Evidence files: ${s.fulfillment!.evidenceFileIds.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (!widget.isCreator && s.requiresFulfillment) ...[
                const SizedBox(height: ImSpacing.space24),
                Text(
                  'Mark shipped',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ImSpacing.space8),
                TextField(
                  controller: _tracking,
                  decoration: const InputDecoration(
                    labelText: 'Tracking reference *',
                  ),
                ),
                const SizedBox(height: ImSpacing.space8),
                TextField(
                  controller: _carrier,
                  decoration: const InputDecoration(
                    labelText: 'Carrier (optional)',
                  ),
                ),
                const SizedBox(height: ImSpacing.space8),
                TextField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: ImSpacing.space12),
                FilledButton(
                  onPressed: state.acting
                      ? null
                      : () => context.read<BarterBloc>().add(
                            BarterShipSubmitted(
                              trackingRef: _tracking.text,
                              shippingCarrier: _carrier.text.trim().isEmpty
                                  ? null
                                  : _carrier.text.trim(),
                              notes: _notes.text.trim().isEmpty
                                  ? null
                                  : _notes.text.trim(),
                            ),
                          ),
                  child: Text(state.acting ? 'Saving…' : 'Mark shipped'),
                ),
              ],
              if (widget.isCreator && s.requiresFulfillment) ...[
                const SizedBox(height: ImSpacing.space24),
                Text(
                  'Confirm received',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ImSpacing.space8),
                if (!s.canCreatorReceive)
                  Text(
                    s.fulfillment?.isShipped == true
                        ? 'Waiting for collab status product_shipped.'
                        : 'Waiting for brand to ship with tracking.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else ...[
                  TextField(
                    controller: _notes,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space12),
                  FilledButton(
                    onPressed: state.acting
                        ? null
                        : () => context.read<BarterBloc>().add(
                              BarterReceiveSubmitted(
                                notes: _notes.text.trim().isEmpty
                                    ? null
                                    : _notes.text.trim(),
                              ),
                            ),
                    child: Text(
                      state.acting ? 'Confirming…' : 'Confirm product received',
                    ),
                  ),
                ],
              ],
              if (s.requiresFulfillment) ...[
                const SizedBox(height: ImSpacing.space24),
                Text(
                  'Evidence (file UUIDs)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ImSpacing.space8),
                TextField(
                  controller: _evidenceIds,
                  decoration: const InputDecoration(
                    labelText: 'Comma-separated file UUIDs',
                  ),
                ),
                const SizedBox(height: ImSpacing.space8),
                OutlinedButton(
                  onPressed: state.acting
                      ? null
                      : () => context.read<BarterBloc>().add(
                            BarterEvidenceSubmitted(_parseEvidence()),
                          ),
                  child: const Text('Attach evidence'),
                ),
              ],
              if (s.skipsProductStates) ...[
                const SizedBox(height: ImSpacing.space24),
                FilledButton.tonal(
                  onPressed: state.acting
                      ? null
                      : () => context
                          .read<BarterBloc>()
                          .add(const BarterOpenContentSubmitted()),
                  child: const Text('Open content path (paid)'),
                ),
              ],
              if (s.contentUnlocked) ...[
                const SizedBox(height: ImSpacing.space16),
                FilledButton.tonal(
                  onPressed: () {
                    final id = s.collaborationId;
                    context.go(
                      widget.isCreator
                          ? '/c/collaborations/$id/content'
                          : '/b/collaborations/$id/review',
                    );
                  },
                  child: Text(
                    widget.isCreator ? 'Submit content' : 'Review content',
                  ),
                ),
              ],
              if (!s.returnsSupported) ...[
                const SizedBox(height: ImSpacing.space16),
                Text(
                  'Returns workflow is not supported (API flag).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
