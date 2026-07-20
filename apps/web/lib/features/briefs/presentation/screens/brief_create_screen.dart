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
import '../../domain/repositories/brief_repository.dart';
import '../bloc/brief_form_bloc.dart';

class BriefCreateScreen extends StatefulWidget {
  const BriefCreateScreen({super.key});

  @override
  State<BriefCreateScreen> createState() => _BriefCreateScreenState();
}

class _BriefCreateScreenState extends State<BriefCreateScreen> {
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
      create: (_) => BriefFormBloc(getIt<BriefRepository>()),
      child: _Form(brandId: _brandId!),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.brandId});
  final String brandId;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final _goals = TextEditingController();
  final _product = TextEditingController();
  final _name = TextEditingController();
  final _budget = TextEditingController();

  @override
  void dispose() {
    _goals.dispose();
    _product.dispose();
    _name.dispose();
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit managed brief')),
      body: BlocConsumer<BriefFormBloc, BriefFormState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
          if (state.phase == BriefFormPhase.success) {
            ImToast.show(
              context,
              message: 'Brief submitted · managed fee none',
              tone: ImToastTone.success,
            );
            context.go('/b/briefs');
          }
        },
        builder: (context, state) {
          final saving = state.phase == BriefFormPhase.saving;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: ImCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Agency will build the campaign. No platform managed fee is charged in this slice.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ImColors.ink600,
                        ),
                  ),
                  const SizedBox(height: ImSpacing.space16),
                  ImTextField(
                    label: 'Campaign name (optional)',
                    controller: _name,
                  ),
                  const SizedBox(height: ImSpacing.space12),
                  ImTextField(
                    label: 'Goals',
                    controller: _goals,
                    maxLines: 4,
                  ),
                  const SizedBox(height: ImSpacing.space12),
                  ImTextField(
                    label: 'Product description',
                    controller: _product,
                    maxLines: 3,
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
                    label: 'Submit brief',
                    loading: saving,
                    onPressed: saving || _goals.text.trim().isEmpty
                        ? null
                        : () {
                            context.read<BriefFormBloc>().add(
                                  BriefFormSubmitted(
                                    brandId: widget.brandId,
                                    goals: _goals.text.trim(),
                                    productDescription:
                                        _product.text.trim().isEmpty
                                            ? null
                                            : _product.text.trim(),
                                    name: _name.text.trim().isEmpty
                                        ? null
                                        : _name.text.trim(),
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
