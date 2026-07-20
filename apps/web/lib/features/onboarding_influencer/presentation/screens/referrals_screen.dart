import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/onboarding.dart';
import '../../domain/repositories/influencer_repository.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  bool _loading = true;
  List<ReferralInvite> _invites = const [];
  String? _profileId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = getIt<InfluencerRepository>();
      final status = await repo.loadOnboarding();
      _profileId = status.profileId;
      _invites = await repo.listReferrals(status.profileId);
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals & Invites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallet_giftcard),
            tooltip: 'View Referral Rewards',
            onPressed: () => context.push('/c/referrals/rewards'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(ImSpacing.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Share invite codes to earn referral rewards on new signups and deals.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: ImColors.ink600,
                              ),
                        ),
                      ),
                      ImButton(
                        label: 'View Rewards',
                        variant: ImButtonVariant.secondary,
                        onPressed: () => context.push('/c/referrals/rewards'),
                      ),
                    ],
                  ),
                  const SizedBox(height: ImSpacing.space16),
                  ImButton(
                    label: 'Create invite code',
                    onPressed: _profileId == null
                        ? null
                        : () async {
                            try {
                              final invite =
                                  await getIt<InfluencerRepository>()
                                      .createReferral(profileId: _profileId!);
                              if (mounted) {
                                ImToast.show(
                                  context,
                                  message: 'Code ${invite.code} created',
                                  tone: ImToastTone.success,
                                );
                                await _load();
                              }
                            } on Failure catch (f) {
                              if (mounted) ErrorPresenter.show(context, f);
                            }
                          },
                  ),
                  const SizedBox(height: ImSpacing.space24),
                  if (_invites.isEmpty)
                    const Expanded(
                      child: ImEmptyState(
                        message: 'No referral codes yet — create one to share.',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _invites.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: ImSpacing.space12),
                        itemBuilder: (context, i) {
                          final r = _invites[i];
                          return ImCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.code,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                if (r.inviteeEmail != null)
                                  Text(r.inviteeEmail!),
                                Text(
                                  'Rewards enabled — check status page',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: ImColors.teal700),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
