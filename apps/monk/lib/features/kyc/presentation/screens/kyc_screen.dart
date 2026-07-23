import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../bloc/kyc_bloc.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _bootstrap(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            body: ImEmptyState(
              message: snap.error is Failure
                  ? (snap.error! as Failure).message
                  : 'Could not load profile for KYC',
            ),
          );
        }
        final data = snap.data!;
        return BlocProvider(
          create: (_) => KycBloc(getIt<KycRepository>())
            ..add(
              KycLoadRequested(
                profileId: data.profileId,
                country: data.country,
              ),
            ),
          child: const _KycView(),
        );
      },
    );
  }

  Future<({String profileId, String? country})> _bootstrap() async {
    final status = await getIt<InfluencerRepository>().loadOnboarding();
    // Country may be on profile via platforms step; optional.
    return (profileId: status.profileId, country: null);
  }
}

class _KycView extends StatefulWidget {
  const _KycView();

  @override
  State<_KycView> createState() => _KycViewState();
}

class _KycViewState extends State<_KycView> {
  String? _identityFileId;
  final _account = TextEditingController();
  final _ifsc = TextEditingController();
  final _iban = TextEditingController();
  final _pan = TextEditingController();
  final _gst = TextEditingController();
  bool _gstRegistered = false;
  final _uaeLicense = TextEditingController();
  final _uaeAuthority = TextEditingController();
  final _uaeExpiry = TextEditingController();
  String? _uaeDocFileId;
  String _jurisdiction = 'IN'; // UI preference; API gates still authoritative

  @override
  void dispose() {
    _account.dispose();
    _ifsc.dispose();
    _iban.dispose();
    _pan.dispose();
    _gst.dispose();
    _uaeLicense.dispose();
    _uaeAuthority.dispose();
    _uaeExpiry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC & licenses')),
      body: BlocConsumer<KycBloc, KycState>(
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
          if (state.phase == KycPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final showIndia = _jurisdiction == 'IN' || state.showIndia;
          final showUae = _jurisdiction == 'AE' || state.showUae;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(ImSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.records.isNotEmpty) ...[
                  Text(
                    'Submissions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ImSpacing.space12),
                  ...state.records.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                      child: ImCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.id, style: Theme.of(context).textTheme.bodySmall),
                                  if (r.panMasked != null)
                                    Text('PAN ${r.panMasked}'),
                                  if (r.accountMasked != null)
                                    Text('Account ${r.accountMasked}'),
                                  if (r.rejectionReason != null)
                                    Text(
                                      r.rejectionReason!,
                                      style: const TextStyle(
                                        color: ImColors.danger600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            ImStatusChip(status: r.statusChip),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space16),
                ],
                if (state.licenses.isNotEmpty) ...[
                  Text(
                    'Media licenses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ImSpacing.space12),
                  ...state.licenses.map(
                    (l) => Padding(
                      padding: const EdgeInsets.only(bottom: ImSpacing.space8),
                      child: ImCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${l.licenseNumber} · ${l.issuingAuthority ?? ""}',
                              ),
                            ),
                            ImStatusChip(status: l.statusChip),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ImSpacing.space16),
                ],
                ImCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Submit KYC',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: ImSpacing.space8),
                      Text(
                        'Sensitive fields are encrypted server-side. Never paste full document contents.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      Text(
                        'Jurisdiction (form fields)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'IN', label: Text('India')),
                          ButtonSegment(value: 'AE', label: Text('UAE')),
                          ButtonSegment(value: 'OTHER', label: Text('Other')),
                        ],
                        selected: {_jurisdiction},
                        onSelectionChanged: (s) =>
                            setState(() => _jurisdiction = s.first),
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImFileUploader(
                        label: 'Identity document file id',
                        onFileIdChanged: (v) => _identityFileId = v,
                      ),
                      const SizedBox(height: ImSpacing.space16),
                      ImTextField(
                        label: 'Payout account number',
                        controller: _account,
                      ),
                      const SizedBox(height: ImSpacing.space12),
                      if (showIndia) ...[
                        ImTextField(label: 'IFSC', controller: _ifsc),
                        const SizedBox(height: ImSpacing.space12),
                        ImTextField(label: 'PAN', controller: _pan),
                        const SizedBox(height: ImSpacing.space12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('GST registered'),
                          value: _gstRegistered,
                          onChanged: (v) =>
                              setState(() => _gstRegistered = v),
                        ),
                        if (_gstRegistered)
                          ImTextField(label: 'GST number', controller: _gst),
                      ] else ...[
                        ImTextField(label: 'IBAN', controller: _iban),
                      ],
                      if (showUae) ...[
                        const SizedBox(height: ImSpacing.space16),
                        Text(
                          'UAE media license',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: ImSpacing.space8),
                        Text(
                          'License status messaging comes from verification APIs; this form only collects fields.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: ImSpacing.space12),
                        ImTextField(
                          label: 'License number',
                          controller: _uaeLicense,
                        ),
                        const SizedBox(height: ImSpacing.space12),
                        ImTextField(
                          label: 'Issuing authority',
                          controller: _uaeAuthority,
                        ),
                        const SizedBox(height: ImSpacing.space12),
                        ImTextField(
                          label: 'Expiry (YYYY-MM-DD)',
                          controller: _uaeExpiry,
                        ),
                        const SizedBox(height: ImSpacing.space12),
                        ImFileUploader(
                          label: 'License document file id',
                          onFileIdChanged: (v) => _uaeDocFileId = v,
                        ),
                      ],
                      const SizedBox(height: ImSpacing.space24),
                      ImButton(
                        label: 'Submit KYC',
                        loading: state.phase == KycPhase.saving,
                        onPressed: state.phase == KycPhase.saving
                            ? null
                            : () {
                                context.read<KycBloc>().add(
                                      KycSubmitted(
                                        identityDocFileId: _identityFileId,
                                        accountNumber: _account.text.trim(),
                                        ifsc: _ifsc.text.trim(),
                                        iban: _iban.text.trim(),
                                        panNumber: _pan.text.trim(),
                                        gstRegistered: showIndia
                                            ? _gstRegistered
                                            : null,
                                        gstNumber: _gst.text.trim(),
                                        uaeLicenseNumber:
                                            _uaeLicense.text.trim(),
                                        uaeDocFileId: _uaeDocFileId,
                                        uaeAuthority:
                                            _uaeAuthority.text.trim(),
                                        uaeExpiryDate:
                                            _uaeExpiry.text.trim().isEmpty
                                                ? null
                                                : _uaeExpiry.text.trim(),
                                      ),
                                    );
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
