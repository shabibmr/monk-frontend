import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/roster.dart';
import '../../domain/repositories/manager_repository.dart';

/// Consolidated earnings stub — no split payout controls (B3 / Appendix B).
class ManagerEarningsScreen extends StatefulWidget {
  const ManagerEarningsScreen({super.key});

  @override
  State<ManagerEarningsScreen> createState() => _ManagerEarningsScreenState();
}

class _ManagerEarningsScreenState extends State<ManagerEarningsScreen> {
  bool _loading = true;
  ManagerEarnings? _earnings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final e = await getIt<ManagerRepository>().getEarnings();
      setState(() => _earnings = e);
    } on Failure catch (f) {
      if (mounted) ErrorPresenter.show(context, f);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _earnings == null
              ? const ImEmptyState(message: 'Could not load earnings.')
              : ListView(
                  padding: const EdgeInsets.all(ImSpacing.space24),
                  children: [
                    ImCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consolidated (read-only)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: ImSpacing.space8),
                          ImMoneyText(
                            minorUnits: _earnings!.totalPayableMinor,
                            currencyCode: _earnings!.currency,
                          ),
                          if (_earnings!.note != null) ...[
                            const SizedBox(height: ImSpacing.space8),
                            Text(
                              _earnings!.note!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          if (_earnings!.managerSplitEnabled)
                            Text(
                              'Split payouts are not available in the UI.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: ImColors.warning600),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: ImSpacing.space16),
                    ..._earnings!.lines.map(
                      (l) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: ImSpacing.space12),
                        child: ImCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l.displayName ?? l.profileId,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              ImMoneyText(
                                minorUnits: l.payableMinor,
                                currencyCode: l.currency,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
