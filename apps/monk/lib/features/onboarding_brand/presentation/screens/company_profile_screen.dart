import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  bool _loading = true;
  Brand? _brand;
  late final TextEditingController _name;
  late final TextEditingController _website;
  late final TextEditingController _industry;
  late final TextEditingController _gst;
  late final TextEditingController _country;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _website = TextEditingController();
    _industry = TextEditingController();
    _gst = TextEditingController();
    _country = TextEditingController();
    _address = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final brands = await getIt<BrandRepository>().listMine();
      if (brands.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final id =
          context.read<SessionCubit>().state.activeBrandId ?? brands.first.id;
      final brand = brands.firstWhere(
        (b) => b.id == id,
        orElse: () => brands.first,
      );
      _brand = brand;
      context.read<SessionCubit>().setActiveBrand(brand.id);
      _name.text = brand.companyName;
      _website.text = brand.website ?? '';
      _industry.text = brand.industry ?? '';
      _gst.text = brand.gstVatNumber ?? '';
      _country.text = brand.country ?? '';
      _address.text = brand.address ?? '';
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _website.dispose();
    _industry.dispose();
    _gst.dispose();
    _country.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Company profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _brand == null
              ? const ImEmptyState(
                  message: 'No brand yet — complete onboarding first.',
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(ImSpacing.space24),
                  child: ImCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ImTextField(label: 'Company name', controller: _name),
                        const SizedBox(height: ImSpacing.space12),
                        ImTextField(label: 'Website', controller: _website),
                        const SizedBox(height: ImSpacing.space12),
                        ImTextField(label: 'Industry', controller: _industry),
                        const SizedBox(height: ImSpacing.space12),
                        ImTextField(label: 'GST / VAT', controller: _gst),
                        const SizedBox(height: ImSpacing.space12),
                        ImTextField(label: 'Country', controller: _country),
                        const SizedBox(height: ImSpacing.space12),
                        ImTextField(
                          label: 'Address',
                          controller: _address,
                          maxLines: 2,
                        ),
                        const SizedBox(height: ImSpacing.space24),
                        ImButton(
                          label: 'Save changes',
                          onPressed: () async {
                            try {
                              await getIt<BrandRepository>().update(
                                _brand!.id,
                                {
                                  'companyName': _name.text.trim(),
                                  'website': _website.text.trim().isEmpty
                                      ? null
                                      : _website.text.trim(),
                                  'industry': _industry.text.trim().isEmpty
                                      ? null
                                      : _industry.text.trim(),
                                  'gstVatNumber': _gst.text.trim().isEmpty
                                      ? null
                                      : _gst.text.trim(),
                                  'country': _country.text.trim().isEmpty
                                      ? null
                                      : _country.text.trim(),
                                  'address': _address.text.trim().isEmpty
                                      ? null
                                      : _address.text.trim(),
                                },
                              );
                              if (mounted) {
                                ImToast.show(
                                  context,
                                  message: 'Company profile updated',
                                  tone: ImToastTone.success,
                                );
                              }
                            } on Failure catch (f) {
                              if (mounted) ErrorPresenter.show(context, f);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
