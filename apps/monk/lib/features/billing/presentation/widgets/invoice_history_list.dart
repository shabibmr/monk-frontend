import 'package:flutter/material.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/widgets/im_card.dart';
import '../../../../core/widgets/im_money_text.dart';
import '../../../../core/widgets/im_status_chip.dart';
import '../../domain/entities/billing_invoice.dart';

class InvoiceHistoryList extends StatelessWidget {
  const InvoiceHistoryList({
    super.key,
    required this.invoices,
  });

  final List<BillingInvoice> invoices;

  EntityStatus _parseStatus(String s) {
    switch (s.toLowerCase()) {
      case 'active':
      case 'paid':
        return EntityStatus.approved;
      case 'pending':
        return EntityStatus.inProgress;
      case 'canceled':
      case 'failed':
      case 'void':
        return EntityStatus.failed;
      default:
        return EntityStatus.approved;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (invoices.isEmpty) {
      return ImCard(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'No invoice history found.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return ImCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice History & Receipts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoices.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.invoiceNumber,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Issued: ${invoice.issueDate}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ImStatusChip(
                      status: _parseStatus(invoice.status),
                      label: invoice.status.toUpperCase(),
                    ),
                    const SizedBox(width: 24),
                    ImMoneyText(
                      minorUnits: invoice.amountMinorUnits,
                      currencyCode: invoice.currency,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
