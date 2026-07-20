import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/payment_repository.dart';
import '../cubit/invoices_cubit.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key, this.portalHome = '/b/dashboard'});

  final String portalHome;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InvoicesCubit(getIt<PaymentRepository>())..load(),
      child: _View(portalHome: portalHome),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.portalHome});
  final String portalHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(portalHome),
        ),
      ),
      body: BlocConsumer<InvoicesCubit, InvoicesState>(
        listener: (context, state) {
          if (state.failure != null) {
            ErrorPresenter.show(context, state.failure!);
          }
        },
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const ImEmptyState(message: 'No invoices yet.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(ImSpacing.space16),
            itemCount: state.items.length,
            separatorBuilder: (c, i) =>
                const SizedBox(height: ImSpacing.space12),
            itemBuilder: (context, i) {
              final inv = state.items[i];
              return ImCard(
                onTap: () => context.read<InvoicesCubit>().open(inv.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.number.isEmpty ? inv.id : inv.number,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(inv.type, style: Theme.of(context).textTheme.bodySmall),
                    ImMoneyText(
                      minorUnits: inv.totalMinor,
                      currencyCode: inv.currency,
                    ),
                    if (inv.taxTotalMinor != null)
                      Text(
                        'Tax (API): display only',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (state.selected?.id == inv.id &&
                        state.selected?.lineItems != null)
                      Padding(
                        padding: const EdgeInsets.only(top: ImSpacing.space8),
                        child: Text(
                          'Lines: ${state.selected!.lineItems}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
