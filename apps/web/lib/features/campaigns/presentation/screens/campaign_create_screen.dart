import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_brand/domain/repositories/brand_repository.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../bloc/campaign_form_bloc.dart';

class CampaignCreateScreen extends StatefulWidget {
  const CampaignCreateScreen({super.key});

  @override
  State<CampaignCreateScreen> createState() => _CampaignCreateScreenState();
}

class _CampaignCreateScreenState extends State<CampaignCreateScreen> {
  String? _brandId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      var id = context.read<SessionCubit>().state.activeBrandId;
      if (id == null) {
        final brands = await getIt<BrandRepository>().listMine();
        if (brands.isNotEmpty) {
          id = brands.first.id;
          context.read<SessionCubit>().setActiveBrand(id);
        }
      }
      setState(() {
        _brandId = id;
        _loading = false;
      });
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_brandId == null) {
      return const Scaffold(
        body: ImEmptyState(message: 'Create a brand first.'),
      );
    }
    return BlocProvider(
      create: (_) => CampaignFormBloc(getIt<CampaignRepository>()),
      child: _FormView(brandId: _brandId!),
    );
  }
}

class _FormView extends StatefulWidget {
  const _FormView({required this.brandId});
  final String brandId;

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _budget = TextEditingController();
  String _mode = 'self_serve';
  String _objective = campaignObjectives.first;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New campaign')),
      body: BlocConsumer<CampaignFormBloc, CampaignFormState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.phase == CampaignFormPhase.success &&
              state.created != null) {
            context.go('/b/campaigns/${state.created!.id}');
          }
        },
        builder: (context, state) {
          final saving = state.phase == CampaignFormPhase.saving;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: ImCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Campaign mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ImSpacing.space8),
                  // Explicit mode cards — licensing deal type intentionally omitted (T2.8)
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'self_serve',
                        label: Text('Self-serve'),
                      ),
                      ButtonSegment(
                        value: 'managed',
                        label: Text('Managed'),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) =>
                        setState(() => _mode = s.first),
                  ),
                  if (isLicensingUiHidden()) ...[
                    const SizedBox(height: ImSpacing.space8),
                    Text(
                      'Licensing campaigns will appear in a later release.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ImColors.ink600,
                          ),
                    ),
                  ],
                  const SizedBox(height: ImSpacing.space16),
                  ImTextField(label: 'Name', controller: _name),
                  const SizedBox(height: ImSpacing.space12),
                  ImTextField(label: 'Code', controller: _code),
                  const SizedBox(height: ImSpacing.space12),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _objective,
                    decoration: const InputDecoration(labelText: 'Objective'),
                    items: campaignObjectives
                        .map(
                          (o) => DropdownMenuItem(
                            value: o,
                            child: Text(o),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _objective = v ?? _objective),
                  ),
                  const SizedBox(height: ImSpacing.space12),
                  ImTextField(
                    label: 'Budget (major units)',
                    controller: _budget,
                    prefixText: '₹ ',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: ImSpacing.space24),
                  ImButton(
                    label: 'Create draft',
                    loading: saving,
                    onPressed: saving ||
                            _name.text.trim().isEmpty ||
                            _code.text.trim().isEmpty
                        ? null
                        : () {
                            context.read<CampaignFormBloc>().add(
                                  CampaignFormSubmitted(
                                    brandId: widget.brandId,
                                    name: _name.text.trim(),
                                    code: _code.text.trim(),
                                    objective: _objective,
                                    mode: _mode,
                                    budgetMajor: _budget.text.trim().isEmpty
                                        ? null
                                        : _budget.text.trim(),
                                  ),
                                );
                          },
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
