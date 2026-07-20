import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/negotiation.dart';
import '../../domain/repositories/negotiation_repository.dart';
import '../bloc/negotiation_bloc.dart';

/// Shared brand + creator negotiation thread (portal theme from shell).
class NegotiationScreen extends StatelessWidget {
  const NegotiationScreen({
    super.key,
    required this.negotiationId,
    this.portalHome = '/b/applications',
  });

  final String negotiationId;
  final String portalHome;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NegotiationBloc(getIt<NegotiationRepository>())
        ..add(NegotiationLoaded(negotiationId)),
      child: _ThreadView(portalHome: portalHome),
    );
  }
}

/// Open negotiation from shortlisted application (brand).
class OpenNegotiationScreen extends StatelessWidget {
  const OpenNegotiationScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NegotiationBloc(getIt<NegotiationRepository>()),
      child: _OpenForm(applicationId: applicationId),
    );
  }
}

class _OpenForm extends StatefulWidget {
  const _OpenForm({required this.applicationId});
  final String applicationId;

  @override
  State<_OpenForm> createState() => _OpenFormState();
}

class _OpenFormState extends State<_OpenForm> {
  final _deliverableId = TextEditingController();
  final _amountMajor = TextEditingController();
  final _barterDesc = TextEditingController();
  final _barterValue = TextEditingController();
  final _message = TextEditingController();
  String _collab = 'paid';

  @override
  void dispose() {
    _deliverableId.dispose();
    _amountMajor.dispose();
    _barterDesc.dispose();
    _barterValue.dispose();
    _message.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _buildBody() {
    final major = double.tryParse(_amountMajor.text.trim()) ?? 0;
    final minor = (major * 100).round();
    final lines = [
      OfferPriceLine(
        deliverableId: _deliverableId.text.trim(),
        priceMinor: _collab == 'barter' ? 0 : minor,
      ),
    ];
    final barterMinor = _barterValue.text.trim().isEmpty
        ? null
        : ((double.tryParse(_barterValue.text.trim()) ?? 0) * 100).round();
    final v = OfferDraftValidation.validate(
      collabType: _collab,
      priceLines: lines,
      barterProductDescription: _barterDesc.text,
      barterDeclaredValueMinor: barterMinor,
    );
    if (!v.ok) {
      ImToast.show(
        context,
        message: v.message ?? 'Invalid offer',
        tone: ImToastTone.warning,
      );
      return null;
    }
    return {
      'collabType': _collab,
      'priceLines': lines.map((e) => e.toJson()).toList(),
      if (_message.text.trim().isNotEmpty) 'message': _message.text.trim(),
      if (_collab == 'barter' || _collab == 'hybrid') ...{
        'barterProductDescription': _barterDesc.text.trim(),
        'barterDeclaredValueMinor': barterMinor,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start negotiation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/b/applications'),
        ),
      ),
      body: BlocConsumer<NegotiationBloc, NegotiationState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.negotiation != null) {
            context.go('/b/negotiations/${state.negotiation!.id}');
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space16),
            children: [
              Text(
                'Structured first offer (required commercial fields)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ImSpacing.space12),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _collab,
                decoration: const InputDecoration(labelText: 'Collab type'),
                items: offerCollabTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _collab = v ?? 'paid'),
              ),
              const SizedBox(height: ImSpacing.space12),
              TextField(
                controller: _deliverableId,
                decoration: const InputDecoration(
                  labelText: 'Deliverable UUID',
                ),
              ),
              const SizedBox(height: ImSpacing.space12),
              if (_collab != 'barter')
                TextField(
                  controller: _amountMajor,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Cash amount (major units)',
                  ),
                ),
              if (_collab == 'barter' || _collab == 'hybrid') ...[
                const SizedBox(height: ImSpacing.space12),
                TextField(
                  controller: _barterDesc,
                  decoration: const InputDecoration(
                    labelText: 'Barter product description',
                  ),
                ),
                const SizedBox(height: ImSpacing.space12),
                TextField(
                  controller: _barterValue,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Barter declared value (major)',
                  ),
                ),
              ],
              const SizedBox(height: ImSpacing.space12),
              TextField(
                controller: _message,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message (optional, not alone)',
                ),
              ),
              const SizedBox(height: ImSpacing.space24),
              FilledButton(
                onPressed: state.acting
                    ? null
                    : () {
                        final body = _buildBody();
                        if (body == null) return;
                        context.read<NegotiationBloc>().add(
                              NegotiationOpened(
                                applicationId: widget.applicationId,
                                body: body,
                              ),
                            );
                      },
                child: Text(state.acting ? 'Opening…' : 'Open negotiation'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThreadView extends StatefulWidget {
  const _ThreadView({required this.portalHome});
  final String portalHome;

  @override
  State<_ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<_ThreadView> {
  final _deliverableId = TextEditingController();
  final _amountMajor = TextEditingController();
  final _barterDesc = TextEditingController();
  final _barterValue = TextEditingController();
  final _message = TextEditingController();
  String _collab = 'paid';

  @override
  void dispose() {
    _deliverableId.dispose();
    _amountMajor.dispose();
    _barterDesc.dispose();
    _barterValue.dispose();
    _message.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _buildBody() {
    final major = double.tryParse(_amountMajor.text.trim()) ?? 0;
    final minor = (major * 100).round();
    final lines = [
      OfferPriceLine(
        deliverableId: _deliverableId.text.trim(),
        priceMinor: _collab == 'barter' ? 0 : minor,
      ),
    ];
    final barterMinor = _barterValue.text.trim().isEmpty
        ? null
        : ((double.tryParse(_barterValue.text.trim()) ?? 0) * 100).round();
    final v = OfferDraftValidation.validate(
      collabType: _collab,
      priceLines: lines,
      barterProductDescription: _barterDesc.text,
      barterDeclaredValueMinor: barterMinor,
    );
    if (!v.ok) {
      ImToast.show(
        context,
        message: v.message ?? 'Invalid offer',
        tone: ImToastTone.warning,
      );
      return null;
    }
    return {
      'collabType': _collab,
      'priceLines': lines.map((e) => e.toJson()).toList(),
      if (_message.text.trim().isNotEmpty) 'message': _message.text.trim(),
      if (_collab == 'barter' || _collab == 'hybrid') ...{
        'barterProductDescription': _barterDesc.text.trim(),
        'barterDeclaredValueMinor': barterMinor,
      },
    };
  }

  Future<void> _confirmAccept(String offerId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept terms?'),
        content: const Text(
          'Accepting freezes commercial terms. Commission % is taken from the server snapshot only.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Accept & lock'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context
          .read<NegotiationBloc>()
          .add(NegotiationOfferAccepted(offerId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Negotiation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(widget.portalHome),
        ),
      ),
      body: BlocConsumer<NegotiationBloc, NegotiationState>(
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
          if (state.validationMessage != null) {
            ImToast.show(
              context,
              message: state.validationMessage!,
              tone: ImToastTone.warning,
            );
          }
        },
        builder: (context, state) {
          if (state.loading && state.negotiation == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final n = state.negotiation;
          if (n == null) {
            return const ImEmptyState(message: 'Negotiation not found.');
          }
          final pending = n.pendingOffer;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(ImSpacing.space16),
                child: Row(
                  children: [
                    ImStatusChip(status: n.statusChip),
                    const SizedBox(width: ImSpacing.space12),
                    Text('Round ${n.roundCount} of ${n.maxRounds}'),
                    if (state.termsLocked) ...[
                      const SizedBox(width: ImSpacing.space12),
                      const Chip(
                        label: Text('Terms locked'),
                        backgroundColor: ImColors.success100,
                      ),
                    ],
                  ],
                ),
              ),
              if (state.acceptResult?.collaboration != null)
                _CommissionSnapshotCard(
                  collab: state.acceptResult!.collaboration!,
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ImSpacing.space16,
                  ),
                  itemCount: n.offers.length,
                  itemBuilder: (context, i) {
                    final o = n.offers[i];
                    final locked = state.termsLocked &&
                        (o.status == 'accepted' ||
                            (i == n.offers.length - 1 && n.isAccepted));
                    return ImBubbleCard(
                      side: o.isBrand
                          ? ImBubbleSide.brand
                          : ImBubbleSide.creator,
                      locked: locked || n.isAccepted,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Round ${o.round} · ${o.offeredBy} · ${o.collabType}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: ImSpacing.space8),
                          ImMoneyText(
                            minorUnits: o.agreedPriceMinor,
                            currencyCode: o.currency,
                          ),
                          if (o.barterProductDescription != null) ...[
                            const SizedBox(height: ImSpacing.space4),
                            Text('Barter: ${o.barterProductDescription}'),
                            if (o.barterDeclaredValueMinor != null)
                              ImMoneyText(
                                minorUnits: o.barterDeclaredValueMinor!,
                                currencyCode: o.currency,
                              ),
                          ],
                          if (o.message != null && o.message!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: ImSpacing.space8),
                              child: Text(o.message!),
                            ),
                          Text(
                            o.status,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (!state.termsLocked && pending != null)
                Padding(
                  padding: const EdgeInsets.all(ImSpacing.space12),
                  child: Wrap(
                    spacing: ImSpacing.space8,
                    children: [
                      FilledButton(
                        onPressed: state.acting
                            ? null
                            : () => _confirmAccept(pending.id),
                        child: const Text('Accept pending offer'),
                      ),
                      OutlinedButton(
                        onPressed: state.acting
                            ? null
                            : () => context.read<NegotiationBloc>().add(
                                  NegotiationOfferDeclined(pending.id),
                                ),
                        child: const Text('Decline'),
                      ),
                      TextButton(
                        onPressed: state.acting
                            ? null
                            : () => context
                                .read<NegotiationBloc>()
                                .add(const NegotiationCancelled()),
                        child: const Text('Cancel thread'),
                      ),
                    ],
                  ),
                ),
              if (state.canSubmitCounter)
                Material(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(ImSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Counter-offer (structured)',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: ImSpacing.space8),
                        DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _collab,
                          decoration:
                              const InputDecoration(labelText: 'Collab type'),
                          items: offerCollabTypes
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _collab = v ?? 'paid'),
                        ),
                        TextField(
                          controller: _deliverableId,
                          decoration: const InputDecoration(
                            labelText: 'Deliverable UUID',
                          ),
                        ),
                        if (_collab != 'barter')
                          TextField(
                            controller: _amountMajor,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Cash amount (major)',
                            ),
                          ),
                        if (_collab == 'barter' || _collab == 'hybrid') ...[
                          TextField(
                            controller: _barterDesc,
                            decoration: const InputDecoration(
                              labelText: 'Barter description',
                            ),
                          ),
                          TextField(
                            controller: _barterValue,
                            decoration: const InputDecoration(
                              labelText: 'Barter value (major)',
                            ),
                          ),
                        ],
                        TextField(
                          controller: _message,
                          decoration: const InputDecoration(
                            labelText: 'Message (optional)',
                          ),
                        ),
                        const SizedBox(height: ImSpacing.space8),
                        FilledButton(
                          onPressed: state.acting
                              ? null
                              : () {
                                  final body = _buildBody();
                                  if (body == null) return;
                                  context.read<NegotiationBloc>().add(
                                        NegotiationCounterSubmitted(body),
                                      );
                                },
                          child: const Text('Send counter'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (n.isOpen && !n.canCounter)
                const Padding(
                  padding: EdgeInsets.all(ImSpacing.space16),
                  child: Text(
                    'Maximum 5 rounds reached. Accept, decline, or cancel.',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CommissionSnapshotCard extends StatelessWidget {
  const _CommissionSnapshotCard({required this.collab});
  final CollaborationSnapshot collab;

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final isCreator = loc.startsWith('/c/');
    final contractPath = isCreator
        ? '/c/collaborations/${collab.id}/contract'
        : '/b/collaborations/${collab.id}/contract';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ImSpacing.space16),
      child: ImCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Locked terms (server snapshot)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: ImSpacing.space8),
            ImMoneyText(
              minorUnits: collab.agreedPriceMinor,
              currencyCode: collab.currency,
            ),
            // Display API commission only — never invent fee math.
            Text(
              'Platform commission: ${collab.commissionPct}% (snapshot)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text('Collab: ${collab.collabType} · ${collab.status}'),
            const SizedBox(height: ImSpacing.space8),
            TextButton(
              onPressed: () => context.go(contractPath),
              child: const Text('View contract'),
            ),
          ],
        ),
      ),
    );
  }
}
