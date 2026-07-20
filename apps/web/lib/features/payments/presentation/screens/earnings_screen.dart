import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../cubit/earnings_cubit.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String? _profileId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      final session = context.read<SessionCubit>().state;
      var id = session.activeProfileId;
      if (id == null && session.role == UserRole.influencer) {
        final status = await getIt<InfluencerRepository>().loadOnboarding();
        id = status.profileId;
        context.read<SessionCubit>().setActiveProfile(
              profileId: id,
              isManagerContext: false,
            );
      }
      setState(() {
        _profileId = id;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final session = context.watch<SessionCubit>().state;
    if (_profileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Earnings')),
        body: const ImEmptyState(
          message: 'Select a profile (or complete influencer onboarding).',
        ),
      );
    }
    final isOwner = session.role == UserRole.influencer && !session.isManagerContext;
    return BlocProvider(
      create: (_) => EarningsCubit(
        getIt<PaymentRepository>(),
        profileId: _profileId!,
        role: session.role,
        isProfileOwner: isOwner,
      )..load(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _amount = TextEditingController();
  final _confirmId = TextEditingController();
  final _confirmToken = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _confirmId.dispose();
    _confirmToken.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          TextButton(
            onPressed: () => context.go('/c/invoices'),
            child: const Text('Invoices'),
          ),
        ],
      ),
      body: BlocConsumer<EarningsCubit, EarningsState>(
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
          if (state.loading && state.earnings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final e = state.earnings;
          final cubit = context.read<EarningsCubit>();
          return ListView(
            padding: const EdgeInsets.all(ImSpacing.space16),
            children: [
              if (e != null) ...[
                _Kpi(
                  label: 'Pending (held)',
                  minor: e.pendingMinor,
                  currency: e.currency,
                ),
                _Kpi(
                  label: 'Available',
                  minor: e.availableMinor,
                  currency: e.currency,
                ),
                _Kpi(
                  label: 'Withdrawn',
                  minor: e.withdrawnMinor,
                  currency: e.currency,
                ),
              ],
              const SizedBox(height: ImSpacing.space24),
              Text(
                'Withdraw',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (major units)',
                ),
              ),
              const SizedBox(height: ImSpacing.space8),
              FilledButton(
                onPressed: state.acting
                    ? null
                    : () {
                        final major = double.tryParse(_amount.text.trim()) ?? 0;
                        final minor = (major * 100).round();
                        cubit.requestPayout(minor);
                      },
                child: Text(state.acting ? 'Requesting…' : 'Request withdrawal'),
              ),
              if (state.lastPayout?.requiresOwnerConfirmation == true) ...[
                const SizedBox(height: ImSpacing.space12),
                ImCard(
                  child: Text(
                    cubit.canConfirmPayout
                        ? 'Confirm your withdrawal below (owner).'
                        : 'Awaiting owner confirmation — managers cannot confirm.',
                  ),
                ),
              ],
              const SizedBox(height: ImSpacing.space24),
              Text(
                'Owner confirm payout',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextField(
                controller: _confirmId,
                decoration: const InputDecoration(labelText: 'Payout UUID'),
              ),
              TextField(
                controller: _confirmToken,
                decoration: const InputDecoration(
                  labelText: 'Confirmation token (optional)',
                ),
              ),
              const SizedBox(height: ImSpacing.space8),
              FilledButton.tonal(
                onPressed: !cubit.canConfirmPayout || state.acting
                    ? null
                    : () => cubit.confirmPayout(
                          _confirmId.text.trim(),
                          token: _confirmToken.text.trim().isEmpty
                              ? null
                              : _confirmToken.text.trim(),
                        ),
                child: Text(
                  cubit.canConfirmPayout
                      ? 'Confirm as owner'
                      : 'Confirm disabled for managers',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.minor,
    required this.currency,
  });
  final String label;
  final int minor;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ImSpacing.space12),
      child: ImCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: ImSpacing.space4),
            ImMoneyText(minorUnits: minor, currencyCode: currency),
          ],
        ),
      ),
    );
  }
}
