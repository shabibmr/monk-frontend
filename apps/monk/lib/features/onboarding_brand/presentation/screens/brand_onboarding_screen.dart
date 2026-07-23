import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';
import '../bloc/brand_onboarding_bloc.dart';

class BrandOnboardingScreen extends StatelessWidget {
  const BrandOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BrandOnboardingBloc(
        repository: getIt<BrandRepository>(),
        sessionCubit: getIt<SessionCubit>(),
      )..add(const BrandOnboardingStarted()),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<BrandOnboardingBloc, BrandOnboardingState>(
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
          if (state.phase == BrandOnboardingPhase.done) {
            context.go('/b/dashboard');
          }
        },
        builder: (context, state) {
          if (state.phase == BrandOnboardingPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.phase == BrandOnboardingPhase.failure &&
              state.brand == null &&
              state.phase != BrandOnboardingPhase.form) {
            // fall through to form retry
          }

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ImSpacing.space24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Brand onboarding',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        state.phase == BrandOnboardingPhase.team
                            ? 'Optional: invite teammates, then finish.'
                            : 'Tell us about your company.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ImColors.ink600,
                            ),
                      ),
                      const SizedBox(height: ImSpacing.space24),
                      ImCard(
                        child: state.phase == BrandOnboardingPhase.team
                            ? _TeamStep(state: state)
                            : _CompanyForm(
                                brand: state.brand,
                                saving: state.phase ==
                                    BrandOnboardingPhase.saving,
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
}

class _CompanyForm extends StatefulWidget {
  const _CompanyForm({this.brand, required this.saving});
  final Brand? brand;
  final bool saving;

  @override
  State<_CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<_CompanyForm> {
  late final TextEditingController _name;
  late final TextEditingController _website;
  late final TextEditingController _industry;
  late final TextEditingController _gst;
  late final TextEditingController _country;
  late final TextEditingController _timezone;
  late final TextEditingController _address;
  late final TextEditingController _contact;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final b = widget.brand;
    _name = TextEditingController(text: b?.companyName ?? '');
    _website = TextEditingController(text: b?.website ?? '');
    _industry = TextEditingController(text: b?.industry ?? '');
    _gst = TextEditingController(text: b?.gstVatNumber ?? '');
    _country = TextEditingController(text: b?.country ?? 'IN');
    _timezone = TextEditingController(text: b?.timezone ?? 'Asia/Kolkata');
    _address = TextEditingController(text: b?.address ?? '');
    _contact = TextEditingController(text: b?.contactPerson ?? '');
    _email = TextEditingController(text: b?.contactEmail ?? '');
    _phone = TextEditingController(text: b?.contactPhone ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _website,
      _industry,
      _gst,
      _country,
      _timezone,
      _address,
      _contact,
      _email,
      _phone,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Company profile',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: ImSpacing.space16),
        ImTextField(label: 'Company name', controller: _name),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Website', controller: _website),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Industry', controller: _industry),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'GST / VAT', controller: _gst),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Country (ISO-2)', controller: _country),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Timezone', controller: _timezone),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Address', controller: _address, maxLines: 2),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Contact person', controller: _contact),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(
          label: 'Contact email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: ImSpacing.space12),
        ImTextField(label: 'Contact phone', controller: _phone),
        const SizedBox(height: ImSpacing.space24),
        ImButton(
          label: 'Save and continue',
          loading: widget.saving,
          onPressed: widget.saving || _name.text.trim().isEmpty
              ? null
              : () {
                  context.read<BrandOnboardingBloc>().add(
                        BrandOnboardingSubmitted({
                          'companyName': _name.text.trim(),
                          if (_website.text.trim().isNotEmpty)
                            'website': _website.text.trim(),
                          if (_industry.text.trim().isNotEmpty)
                            'industry': _industry.text.trim(),
                          if (_gst.text.trim().isNotEmpty)
                            'gstVatNumber': _gst.text.trim(),
                          if (_country.text.trim().isNotEmpty)
                            'country': _country.text.trim(),
                          if (_timezone.text.trim().isNotEmpty)
                            'timezone': _timezone.text.trim(),
                          if (_address.text.trim().isNotEmpty)
                            'address': _address.text.trim(),
                          if (_contact.text.trim().isNotEmpty)
                            'contactPerson': _contact.text.trim(),
                          if (_email.text.trim().isNotEmpty)
                            'contactEmail': _email.text.trim(),
                          if (_phone.text.trim().isNotEmpty)
                            'contactPhone': _phone.text.trim(),
                        }),
                      );
                },
        ),
      ],
    );
  }
}

class _TeamStep extends StatefulWidget {
  const _TeamStep({required this.state});
  final BrandOnboardingState state;

  @override
  State<_TeamStep> createState() => _TeamStepState();
}

class _TeamStepState extends State<_TeamStep> {
  final _email = TextEditingController();
  String _role = brandInviteRoles.first;
  final _perms = <String>{'read', 'write'};

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saving =
        context.watch<BrandOnboardingBloc>().state.phase ==
            BrandOnboardingPhase.saving;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Team (optional)',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: ImSpacing.space8),
        Text(
          'Invite teammates with role + permissions. You can skip and manage later in Settings.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ImColors.ink600,
              ),
        ),
        if (widget.state.brand != null) ...[
          const SizedBox(height: ImSpacing.space12),
          Text(
            widget.state.brand!.companyName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
        const SizedBox(height: ImSpacing.space16),
        ImTextField(
          label: 'Teammate email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: ImSpacing.space12),
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: _role,
          items: brandInviteRoles
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.replaceAll('_', ' ')),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _role = v ?? _role),
          decoration: const InputDecoration(labelText: 'Role'),
        ),
        const SizedBox(height: ImSpacing.space12),
        Wrap(
          spacing: 8,
          children: brandPermissionOptions
              .map(
                (p) => FilterChip(
                  label: Text(p),
                  selected: _perms.contains(p),
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _perms.add(p);
                      } else {
                        _perms.remove(p);
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: ImSpacing.space16),
        ImButton(
          label: 'Send invite',
          variant: ImButtonVariant.secondary,
          loading: saving,
          onPressed: saving ||
                  _email.text.trim().isEmpty ||
                  _perms.isEmpty
              ? null
              : () {
                  context.read<BrandOnboardingBloc>().add(
                        BrandInviteSubmitted(
                          email: _email.text.trim(),
                          memberRole: _role,
                          permissions: _perms.toList(),
                        ),
                      );
                },
        ),
        if (widget.state.devInviteToken != null) ...[
          const SizedBox(height: ImSpacing.space12),
          Text(
            'Dev invite token: ${widget.state.devInviteToken}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: ImSpacing.space24),
        ImButton(
          label: 'Finish and go to dashboard',
          onPressed: () => context
              .read<BrandOnboardingBloc>()
              .add(const BrandOnboardingFinished()),
        ),
      ],
    );
  }
}
