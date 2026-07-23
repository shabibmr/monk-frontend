import 'package:equatable/equatable.dart';

class BillingInvoice extends Equatable {
  const BillingInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.issueDate,
    required this.status,
    required this.amountMinorUnits,
    required this.currency,
    this.pdfUrl,
  });

  final String id;
  final String invoiceNumber;
  final String issueDate;
  final String status; // 'paid', 'pending', 'void', 'failed'
  final int amountMinorUnits;
  final String currency; // API-provided ISO currency code
  final String? pdfUrl;

  factory BillingInvoice.fromJson(Map<String, dynamic> json) {
    return BillingInvoice(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String? ?? json['invoice_number'] as String? ?? json['id'] as String,
      issueDate: json['issueDate'] as String? ?? json['created_at'] as String? ?? '',
      status: json['status'] as String? ?? 'paid',
      amountMinorUnits: json['amountMinorUnits'] as int? ?? json['amount_minor_units'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      pdfUrl: json['pdfUrl'] as String? ?? json['pdf_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'issueDate': issueDate,
      'status': status,
      'amountMinorUnits': amountMinorUnits,
      'currency': currency,
      'pdfUrl': pdfUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        issueDate,
        status,
        amountMinorUnits,
        currency,
        pdfUrl,
      ];
}
