import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/onboarding.dart';
import '../../domain/repositories/influencer_repository.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

const _stepLabels = [
  'Account',
  'Platforms',
  'Social',
  'Categories',
  'Team',
  'Confirm',
];

const _platforms = [
  'instagram',
  'youtube',
  'facebook',
  'x',
  'linkedin',
  'blog',
];

const _deliverables = [
  'instagram_reel',
  'instagram_story',
  'instagram_post',
  'youtube_video',
  'youtube_short',
];

class InfluencerOnboardingWizardScreen extends StatelessWidget {
  const InfluencerOnboardingWizardScreen({super.key, this.initialStep});

  final int? initialStep;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(
        repository: getIt<InfluencerRepository>(),
        sessionCubit: getIt<SessionCubit>(),
      )..add(const OnboardingStarted()),
      child: _WizardBody(initialStep: initialStep),
    );
  }
}

class _WizardBody extends StatelessWidget {
  const _WizardBody({this.initialStep});
  final int? initialStep;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.infoMessage != null &&
              state.phase != OnboardingPhase.failure) {
            ImToast.show(
              context,
              message: state.infoMessage!,
              tone: ImToastTone.success,
            );
          }
          if (state.phase == OnboardingPhase.oauthLaunch &&
              state.oauthUrl != null) {
            final url = state.oauthUrl!;
            Clipboard.setData(ClipboardData(text: url));
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Continue OAuth'),
                content: Text(
                  'Authorization URL copied. Open it in a new tab to connect, then refresh accounts.\n\n$url',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }
          // Only on the transition into completion — opening an already
          // complete profile shows the summary instead of redirecting.
          if (state.phase == OnboardingPhase.completed && state.justCompleted) {
            context.go('/c/dashboard');
          }
        },
        builder: (context, state) {
          if (state.phase == OnboardingPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.phase == OnboardingPhase.failure &&
              state.profileId == null) {
            return ImEmptyState(
              message: state.failure?.message ?? 'Could not load onboarding',
              actionLabel: 'Retry',
              onAction: () => context
                  .read<OnboardingBloc>()
                  .add(const OnboardingStarted()),
            );
          }

          final step = state.currentStep;
          final saving = state.phase == OnboardingPhase.saving;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ImLayout.contentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(ImSpacing.space24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Creator onboarding',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        'Progress saved',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: ImSpacing.space24),
                      ImStepper(
                        labels: _stepLabels,
                        currentStep: step,
                        completedSteps: state.progress.completedSteps,
                        onStepTap: (s) => context
                            .read<OnboardingBloc>()
                            .add(OnboardingGoToStep(s)),
                      ),
                      const SizedBox(height: ImSpacing.space32),
                      Expanded(
                        child: SingleChildScrollView(
                          child: ImCard(
                            child: _stepBody(context, state, saving),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stepBody(
    BuildContext context,
    OnboardingState state,
    bool saving,
  ) {
    if (state.phase == OnboardingPhase.completed && !state.justCompleted) {
      return _CompletedSummary(state: state);
    }
    switch (state.currentStep) {
      case 1:
        return _AccountStep(saving: saving);
      case 2:
        return _PlatformsStep(saving: saving);
      case 3:
        return _SocialStep(state: state, saving: saving);
      case 4:
        return _CategoriesStep(saving: saving);
      case 5:
        return _TeamStep(state: state, saving: saving);
      case 6:
      default:
        return _ConfirmStep(state: state, saving: saving);
    }
  }
}

/// Shown when the wizard is opened on an already-complete profile — replaces
/// the old redirect-to-dashboard behaviour.
class _CompletedSummary extends StatelessWidget {
  const _CompletedSummary({required this.state});
  final OnboardingState state;

  EntityStatus get _chip {
    switch (state.verificationStatus) {
      case 'approved':
        return EntityStatus.approved;
      case 'rejected':
        return EntityStatus.rejected;
      default:
        return EntityStatus.inReview;
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = state.progress.completedSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: ImColors.success600,
            ),
            const SizedBox(width: ImSpacing.space8),
            Expanded(
              child: Text(
                'Onboarding complete',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ImStatusChip(
              status: _chip,
              label: 'Verification: ${state.verificationStatus ?? "pending"}',
            ),
          ],
        ),
        const SizedBox(height: ImSpacing.space8),
        Text(
          'Your profile is set up. Pick any step above to review what you '
          'submitted, or head back to the dashboard.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ImColors.ink600,
              ),
        ),
        const SizedBox(height: ImSpacing.space16),
        Text(
          done.isEmpty
              ? 'No steps recorded'
              : 'Completed steps: ${done.join(", ")}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: ImSpacing.space24),
        ImButton(
          label: 'Go to dashboard',
          onPressed: () => context.go('/c/dashboard'),
        ),
      ],
    );
  }
}

class _AccountStep extends StatelessWidget {
  const _AccountStep({required this.saving});
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionCubit>().state.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Account', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: ImSpacing.space8),
        Text(
          'Your account is ready. Continue to set up platforms.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ImColors.ink600,
              ),
        ),
        const SizedBox(height: ImSpacing.space16),
        Text(user?.email ?? '', style: Theme.of(context).textTheme.titleMedium),
        if (user?.fullName != null) ...[
          const SizedBox(height: ImSpacing.space8),
          Text(user!.fullName!),
        ],
        const SizedBox(height: ImSpacing.space24),
        ImButton(
          label: 'Continue to platforms',
          loading: saving,
          onPressed: saving
              ? null
              : () => context
                  .read<OnboardingBloc>()
                  .add(const OnboardingGoToStep(2)),
        ),
      ],
    );
  }
}

class _PlatformsStep extends StatefulWidget {
  const _PlatformsStep({required this.saving});
  final bool saving;

  @override
  State<_PlatformsStep> createState() => _PlatformsStepState();
}

class _PlatformsStepState extends State<_PlatformsStep> {
  String _primary = 'instagram';
  String? _secondary;
  final _region = TextEditingController();
  final _country = TextEditingController(text: 'IN');
  final _city = TextEditingController();
  final _blog = TextEditingController();

  @override
  void dispose() {
    _region.dispose();
    _country.dispose();
    _city.dispose();
    _blog.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Platforms & reach',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: ImSpacing.space16),
        Text('Primary platform',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        const SizedBox(height: ImSpacing.space8),
        Wrap(
          spacing: 8,
          children: _platforms
              .map(
                (p) => ChoiceChip(
                  label: Text(p),
                  selected: _primary == p,
                  onSelected: (_) => setState(() => _primary = p),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: ImSpacing.space16),
        Text('Secondary platform (optional)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        const SizedBox(height: ImSpacing.space8),
        Wrap(
          spacing: 8,
          children: _platforms
              .map(
                (p) => ChoiceChip(
                  label: Text(p),
                  selected: _secondary == p,
                  onSelected: (_) => setState(
                    () => _secondary = _secondary == p ? null : p,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: ImSpacing.space16),
        ImTextField(label: 'Main region of influence', controller: _region),
        const SizedBox(height: ImSpacing.space16),
        ImTextField(label: 'Country (ISO-2)', controller: _country),
        const SizedBox(height: ImSpacing.space16),
        ImTextField(label: 'City', controller: _city),
        const SizedBox(height: ImSpacing.space16),
        ImTextField(label: 'Blog URL (optional)', controller: _blog),
        const SizedBox(height: ImSpacing.space24),
        ImButton(
          label: 'Save and continue',
          loading: widget.saving,
          onPressed: widget.saving
              ? null
              : () {
                  context.read<OnboardingBloc>().add(
                        OnboardingSavePlatforms(
                          primaryPlatform: _primary,
                          secondaryPlatform: _secondary,
                          mainRegion: _region.text.trim().isEmpty
                              ? null
                              : _region.text.trim(),
                          country: _country.text.trim().isEmpty
                              ? null
                              : _country.text.trim(),
                          city: _city.text.trim().isEmpty
                              ? null
                              : _city.text.trim(),
                          blogUrl: _blog.text.trim().isEmpty
                              ? null
                              : _blog.text.trim(),
                        ),
                      );
                },
        ),
      ],
    );
  }
}

class _SocialStep extends StatefulWidget {
  const _SocialStep({required this.state, required this.saving});
  final OnboardingState state;
  final bool saving;

  @override
  State<_SocialStep> createState() => _SocialStepState();
}

class _SocialStepState extends State<_SocialStep> {
  final _handle = TextEditingController();
  String _platform = 'instagram';

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.state.socialAccounts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Connected accounts',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: ImSpacing.space8),
        Text(
          'Connect Instagram or YouTube, or declare a handle manually. Tokens are never shown.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ImColors.ink600,
              ),
        ),
        const SizedBox(height: ImSpacing.space16),
        Row(
          children: [
            Expanded(
              child: ImButton(
                label: 'Connect Instagram',
                variant: ImButtonVariant.secondary,
                onPressed: widget.saving
                    ? null
                    : () => context
                        .read<OnboardingBloc>()
                        .add(const OnboardingStartOAuth('instagram')),
              ),
            ),
            const SizedBox(width: ImSpacing.space12),
            Expanded(
              child: ImButton(
                label: 'Connect YouTube',
                variant: ImButtonVariant.secondary,
                onPressed: widget.saving
                    ? null
                    : () => context
                        .read<OnboardingBloc>()
                        .add(const OnboardingStartOAuth('youtube')),
              ),
            ),
          ],
        ),
        const SizedBox(height: ImSpacing.space24),
        Text('Manual declaration',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ImSpacing.space12),
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: _platform,
          items: _platforms
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) => setState(() => _platform = v ?? 'instagram'),
          decoration: const InputDecoration(labelText: 'Platform'),
        ),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Handle', controller: _handle),
        const SizedBox(height: ImSpacing.space12),
        ImButton(
          label: 'Add declaration',
          variant: ImButtonVariant.secondary,
          loading: widget.saving,
          onPressed: widget.saving || _handle.text.trim().isEmpty
              ? null
              : () {
                  context.read<OnboardingBloc>().add(
                        OnboardingManualSocial(
                          platform: _platform,
                          handle: _handle.text.trim(),
                        ),
                      );
                },
        ),
        const SizedBox(height: ImSpacing.space24),
        if (accounts.isEmpty)
          Text(
            'No accounts yet — add at least one when ready.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...accounts.map(
            (a) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${a.platform} · ${a.handle ?? "—"}'),
              subtitle: Text(
                a.declaredOnly == true
                    ? 'Declared only'
                    : 'Followers: ${a.followersCount ?? "—"}',
              ),
            ),
          ),
        const SizedBox(height: ImSpacing.space16),
        ImButton(
          label: 'Refresh accounts',
          variant: ImButtonVariant.tertiary,
          onPressed: () => context
              .read<OnboardingBloc>()
              .add(const OnboardingRefreshSocial()),
        ),
        const SizedBox(height: ImSpacing.space16),
        ImButton(
          label: 'Continue',
          onPressed: () => context
              .read<OnboardingBloc>()
              .add(const OnboardingContinueFromSocial()),
        ),
      ],
    );
  }
}

class _CategoriesStep extends StatefulWidget {
  const _CategoriesStep({required this.saving});
  final bool saving;

  @override
  State<_CategoriesStep> createState() => _CategoriesStepState();
}

class _CategoriesStepState extends State<_CategoriesStep> {
  final _main = TextEditingController();
  final _secondary = TextEditingController();
  final _displayName = TextEditingController();
  final _bio = TextEditingController();
  final _priceControllers = {
    for (final d in _deliverables) d: TextEditingController(),
  };
  String _gender = 'both';
  bool _barter = false;
  bool _licensing = false;

  @override
  void dispose() {
    _main.dispose();
    _secondary.dispose();
    _displayName.dispose();
    _bio.dispose();
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Categories & pricing',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: ImSpacing.space16),
        ImTextField(label: 'Display name', controller: _displayName),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Main category', controller: _main),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(
          label: 'Secondary categories (comma-separated, max 2)',
          controller: _secondary,
        ),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Biography', controller: _bio, maxLines: 3),
        const SizedBox(height: ImSpacing.space16),
        Text('Audience gender',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'men', label: Text('Men')),
            ButtonSegment(value: 'women', label: Text('Women')),
            ButtonSegment(value: 'both', label: Text('Both')),
          ],
          selected: {_gender},
          onSelectionChanged: (s) => setState(() => _gender = s.first),
        ),
        const SizedBox(height: ImSpacing.space12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Open to barter'),
          value: _barter,
          onChanged: (v) => setState(() => _barter = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Licensing price available (field only)'),
          value: _licensing,
          onChanged: (v) => setState(() => _licensing = v),
        ),
        const SizedBox(height: ImSpacing.space16),
        Text('Pricing (INR major units → sent as minor)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ImSpacing.space8),
        ..._deliverables.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: ImSpacing.space12),
            child: ImTextField(
              label: d.replaceAll('_', ' '),
              controller: _priceControllers[d],
              prefixText: '₹ ',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ),
        const SizedBox(height: ImSpacing.space16),
        ImButton(
          label: 'Save and continue',
          loading: widget.saving,
          onPressed: widget.saving || _main.text.trim().isEmpty
              ? null
              : () {
                  final secondaries = _secondary.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .take(2)
                      .toList();
                  final lines = <PricingLine>[];
                  for (final d in _deliverables) {
                    final t = _priceControllers[d]!.text.trim();
                    if (t.isEmpty) continue;
                    lines.add(
                      PricingLine(
                        deliverableType: d,
                        priceMinor: majorToMinor(t),
                        currency: 'INR',
                      ),
                    );
                  }
                  if (lines.isEmpty) {
                    ImToast.show(
                      context,
                      message: 'Add at least one price',
                      tone: ImToastTone.warning,
                    );
                    return;
                  }
                  context.read<OnboardingBloc>().add(
                        OnboardingSaveCategoriesPricing(
                          mainCategory: _main.text.trim(),
                          secondaryCategories: secondaries,
                          audienceGender: _gender,
                          openToBarter: _barter,
                          licensingAvailable: _licensing,
                          biography: _bio.text.trim().isEmpty
                              ? null
                              : _bio.text.trim(),
                          displayName: _displayName.text.trim().isEmpty
                              ? null
                              : _displayName.text.trim(),
                          pricing: lines,
                        ),
                      );
                },
        ),
      ],
    );
  }
}

class _TeamStep extends StatefulWidget {
  const _TeamStep({required this.state, required this.saving});
  final OnboardingState state;
  final bool saving;

  @override
  State<_TeamStep> createState() => _TeamStepState();
}

class _TeamStepState extends State<_TeamStep> {
  final _manager = TextEditingController();
  final _referral = TextEditingController();

  @override
  void dispose() {
    _manager.dispose();
    _referral.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Manager & community',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: ImSpacing.space8),
        Text(
          'Invite a manager and generate a referral code. Rewards are not enabled yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ImColors.ink600,
              ),
        ),
        const SizedBox(height: ImSpacing.space16),
        ImTextField(
          label: 'Manager email (optional)',
          controller: _manager,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(
          label: 'Invite influencer email (optional)',
          controller: _referral,
          keyboardType: TextInputType.emailAddress,
        ),
        if (widget.state.lastReferral != null) ...[
          const SizedBox(height: ImSpacing.space16),
          ImCard(
            child: Text(
              'Referral code: ${widget.state.lastReferral!.code}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
        const SizedBox(height: ImSpacing.space24),
        ImButton(
          label: 'Save and continue',
          loading: widget.saving,
          onPressed: widget.saving
              ? null
              : () {
                  context.read<OnboardingBloc>().add(
                        OnboardingSaveTeam(
                          managerEmail: _manager.text.trim().isEmpty
                              ? null
                              : _manager.text.trim(),
                          referralEmail: _referral.text.trim().isEmpty
                              ? null
                              : _referral.text.trim(),
                        ),
                      );
                },
        ),
      ],
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({required this.state, required this.saving});
  final OnboardingState state;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Confirm & submit',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: ImSpacing.space8),
        Text(
          'KYC document capture arrives in T1.2. Submit now to enter pending verification.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ImColors.ink600,
              ),
        ),
        const SizedBox(height: ImSpacing.space16),
        Text(
          'Completed steps: ${state.progress.completedSteps.join(", ")}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: ImSpacing.space24),
        ImButton(
          label: 'Complete onboarding',
          loading: saving,
          onPressed: saving
              ? null
              : () => context
                  .read<OnboardingBloc>()
                  .add(const OnboardingConfirmComplete()),
        ),
      ],
    );
  }
}
