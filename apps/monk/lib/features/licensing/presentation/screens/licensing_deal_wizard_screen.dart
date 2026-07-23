import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/licensing_repository.dart';
import '../bloc/licensing_bloc.dart';

class LicensingDealWizardScreen extends StatelessWidget {
  const LicensingDealWizardScreen({
    super.key,
    required this.collaborationId,
  });

  final String collaborationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LicensingBloc(getIt<LicensingRepository>()),
      child: _WizardView(collaborationId: collaborationId),
    );
  }
}

class _WizardView extends StatefulWidget {
  const _WizardView({required this.collaborationId});
  final String collaborationId;

  @override
  State<_WizardView> createState() => _WizardViewState();
}

class _WizardViewState extends State<_WizardView> {
  final _assetUrlController = TextEditingController();
  final _scopeController = TextEditingController(text: 'digital_and_social');
  final _territoryController = TextEditingController(text: 'Worldwide');
  final _durationController = TextEditingController(text: '365');
  final _feeController = TextEditingController(text: '500');

  @override
  void dispose() {
    _assetUrlController.dispose();
    _scopeController.dispose();
    _territoryController.dispose();
    _durationController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Licensing Deal Wizard')),
      body: BlocConsumer<LicensingBloc, LicensingState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.infoMessage != null) {
            ImToast.show(context, message: state.infoMessage!);
          }
        },
        builder: (context, state) {
          final step = state.wizardStep;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: Column(
              children: [
                ImStepper(
                  currentStep: step,
                  labels: const ['1. Scope', '2. Duration', '3. Fee & Review'],
                  onStepTap: (s) =>
                      context.read<LicensingBloc>().add(WizardStepChanged(s)),
                ),
                const SizedBox(height: ImSpacing.space24),
                ImCard(
                  child: Padding(
                    padding: const EdgeInsets.all(ImSpacing.space16),
                    child: _buildStepContent(context, step, state),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    int step,
    LicensingState state,
  ) {
    switch (step) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Step 1: Scope & Asset',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: ImSpacing.space16),
            ImTextField(
              label: 'Deliverable / Asset URL',
              controller: _assetUrlController,
              hint: 'https://cdn.example.com/assets/video_1.mp4',
            ),
            const SizedBox(height: ImSpacing.space12),
            ImTextField(
              label: 'Licensing Scope',
              controller: _scopeController,
              hint: 'e.g. digital_only, broadcast, organic_and_paid',
            ),
            const SizedBox(height: ImSpacing.space12),
            ImTextField(
              label: 'Territory',
              controller: _territoryController,
              hint: 'e.g. Worldwide, North America, India',
            ),
            const SizedBox(height: ImSpacing.space24),
            ImButton(
              label: 'Next: Duration',
              onPressed: () {
                if (_assetUrlController.text.trim().isNotEmpty) {
                  context.read<LicensingBloc>().add(const WizardStepChanged(2));
                }
              },
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Step 2: Duration & Exclusivity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: ImSpacing.space16),
            ImTextField(
              label: 'Grant Duration (Days)',
              controller: _durationController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: ImSpacing.space24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context
                        .read<LicensingBloc>()
                        .add(const WizardStepChanged(1)),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: ImSpacing.space12),
                Expanded(
                  child: ImButton(
                    label: 'Next: Fee & Review',
                    onPressed: () => context
                        .read<LicensingBloc>()
                        .add(const WizardStepChanged(3)),
                  ),
                ),
              ],
            ),
          ],
        );

      case 3:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Step 3: Fee & Confirm Deal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: ImSpacing.space16),
            ImTextField(
              label: 'Licensing Fee (USD)',
              controller: _feeController,
              prefixText: '\$ ',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: ImSpacing.space16),
            ImCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deal Summary',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: ImSpacing.space8),
                  Text('Asset: ${_assetUrlController.text.trim()}'),
                  Text('Scope: ${_scopeController.text.trim()}'),
                  Text('Territory: ${_territoryController.text.trim()}'),
                  Text('Duration: ${_durationController.text.trim()} days'),
                  Text('Fee: \$${_feeController.text.trim()}'),
                ],
              ),
            ),
            const SizedBox(height: ImSpacing.space24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context
                        .read<LicensingBloc>()
                        .add(const WizardStepChanged(2)),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: ImSpacing.space12),
                Expanded(
                  child: ImButton(
                    label: 'Create Licensing Grant',
                    loading: state.submitting,
                    onPressed: state.submitting
                        ? null
                        : () {
                            final assetUrl = _assetUrlController.text.trim();
                            final scope = _scopeController.text.trim();
                            final territory = _territoryController.text.trim();
                            final duration = int.tryParse(
                                    _durationController.text.trim()) ??
                                365;
                            final fee = double.tryParse(
                                    _feeController.text.trim()) ??
                                0.0;

                            if (assetUrl.isNotEmpty) {
                              context.read<LicensingBloc>().add(
                                    CreateLicensingGrantSubmitted(
                                      collaborationId: widget.collaborationId,
                                      assetUrl: assetUrl,
                                      scope: scope,
                                      territory: territory,
                                      durationDays: duration,
                                      fee: fee,
                                    ),
                                  );
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}
