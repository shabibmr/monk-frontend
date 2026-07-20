class PaymentDto {
  const PaymentDto({
    required this.id,
    required this.collaborationId,
    required this.brandId,
    required this.amountMinor,
    required this.currency,
    required this.status,
    required this.commissionPct,
    this.commissionMinor,
    this.payoutMinor,
    this.gatewayOrderId,
    this.checkout,
  });

  final String id;
  final String collaborationId;
  final String brandId;
  final int amountMinor;
  final String currency;
  final String status;

  /// Server snapshot — never recompute client fees from this alone.
  final double commissionPct;
  final int? commissionMinor;
  final int? payoutMinor;
  final String? gatewayOrderId;
  final Map<String, dynamic>? checkout;

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    final amount = json['amountMinor'];
    final commission = json['commissionPct'];
    final commissionMinor = json['commissionMinor'];
    final payout = json['payoutMinor'];
    final checkout = json['checkout'];
    return PaymentDto(
      id: json['id'] as String,
      collaborationId: json['collaborationId'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      amountMinor: amount is int
          ? amount
          : amount is num
              ? amount.toInt()
              : int.tryParse('$amount') ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'created',
      commissionPct: commission is num
          ? commission.toDouble()
          : double.tryParse('$commission') ?? 0,
      commissionMinor: commissionMinor is int
          ? commissionMinor
          : commissionMinor is num
              ? commissionMinor.toInt()
              : int.tryParse('$commissionMinor'),
      payoutMinor: payout is int
          ? payout
          : payout is num
              ? payout.toInt()
              : int.tryParse('$payout'),
      gatewayOrderId: json['gatewayOrderId'] as String?,
      checkout: checkout is Map<String, dynamic>
          ? Map<String, dynamic>.from(checkout)
          : null,
    );
  }
}

class EarningsDto {
  const EarningsDto({
    required this.profileId,
    required this.pendingMinor,
    required this.availableMinor,
    required this.withdrawnMinor,
    required this.currency,
  });

  final String profileId;
  final int pendingMinor;
  final int availableMinor;
  final int withdrawnMinor;
  final String currency;

  factory EarningsDto.fromJson(Map<String, dynamic> json) {
    int asInt(Object? v) => v is int
        ? v
        : v is num
            ? v.toInt()
            : int.tryParse('$v') ?? 0;
    return EarningsDto(
      profileId: json['profileId'] as String? ?? '',
      pendingMinor: asInt(json['pendingMinor']),
      availableMinor: asInt(json['availableMinor']),
      withdrawnMinor: asInt(json['withdrawnMinor']),
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}

class PayoutRequestDto {
  const PayoutRequestDto({
    required this.id,
    required this.status,
    required this.amountMinor,
    required this.currency,
    required this.requiresOwnerConfirmation,
    this.confirmationToken,
  });

  final String id;
  final String status;
  final int amountMinor;
  final String currency;
  final bool requiresOwnerConfirmation;
  final String? confirmationToken;

  factory PayoutRequestDto.fromJson(Map<String, dynamic> json) {
    final amount = json['amountMinor'];
    return PayoutRequestDto(
      id: json['id'] as String,
      status: json['status'] as String? ?? '',
      amountMinor: amount is int
          ? amount
          : amount is num
              ? amount.toInt()
              : int.tryParse('$amount') ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      requiresOwnerConfirmation:
          json['requiresOwnerConfirmation'] as bool? ?? false,
      confirmationToken: json['confirmationToken'] as String?,
    );
  }
}

class InvoiceDto {
  const InvoiceDto({
    required this.id,
    required this.number,
    required this.type,
    required this.totalMinor,
    required this.currency,
    this.taxTotalMinor,
    this.lineItems,
    this.createdAt,
  });

  final String id;
  final String number;
  final String type;
  final int totalMinor;
  final String currency;
  final int? taxTotalMinor;
  final Object? lineItems;
  final String? createdAt;

  factory InvoiceDto.fromJson(Map<String, dynamic> json) {
    final total = json['totalMinor'];
    final tax = json['taxTotalMinor'];
    return InvoiceDto(
      id: json['id'] as String,
      number: json['number'] as String? ?? '',
      type: json['type'] as String? ?? '',
      totalMinor: total is int
          ? total
          : total is num
              ? total.toInt()
              : int.tryParse('$total') ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      taxTotalMinor: tax is int
          ? tax
          : tax is num
              ? tax.toInt()
              : int.tryParse('$tax'),
      lineItems: json['lineItems'],
      createdAt: json['createdAt']?.toString(),
    );
  }
}
