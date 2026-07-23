import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

/// Fee lines shown only from API fields — never invent amounts.
class FeeBreakdownLine extends Equatable {
  const FeeBreakdownLine({required this.label, required this.amountMinor});
  final String label;
  final int amountMinor;
  @override
  List<Object?> get props => [label, amountMinor];
}

EntityStatus paymentStatusToEntity(String status) {
  switch (status) {
    case 'created':
      return EntityStatus.draft;
    case 'funded':
      return EntityStatus.funded;
    case 'held':
      return EntityStatus.held;
    case 'released':
    case 'paid_out':
      return EntityStatus.paidOut;
    case 'refunded':
    case 'partially_refunded':
      return EntityStatus.refunded;
    case 'failed':
      return EntityStatus.failed;
    default:
      return EntityStatus.inReview;
  }
}

class Payment extends Equatable {
  const Payment({
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
  final double commissionPct;
  final int? commissionMinor;
  final int? payoutMinor;
  final String? gatewayOrderId;
  final Map<String, dynamic>? checkout;

  bool get canRelease => status == 'held';
  bool get isCash => amountMinor > 0;

  /// Breakdown uses server snapshot fields only (no client * pct).
  List<FeeBreakdownLine> get apiFeeBreakdown {
    final lines = <FeeBreakdownLine>[
      FeeBreakdownLine(label: 'Gross (API)', amountMinor: amountMinor),
    ];
    if (commissionMinor != null) {
      lines.add(
        FeeBreakdownLine(
          label: 'Platform fee snapshot $commissionPct% (API amount)',
          amountMinor: commissionMinor!,
        ),
      );
    }
    if (payoutMinor != null) {
      lines.add(
        FeeBreakdownLine(label: 'Influencer share (API)', amountMinor: payoutMinor!),
      );
    }
    return lines;
  }

  EntityStatus get statusChip => paymentStatusToEntity(status);

  @override
  List<Object?> get props => [
        id,
        collaborationId,
        brandId,
        amountMinor,
        currency,
        status,
        commissionPct,
        commissionMinor,
        payoutMinor,
        gatewayOrderId,
        checkout,
      ];
}

class Earnings extends Equatable {
  const Earnings({
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

  @override
  List<Object?> get props =>
      [profileId, pendingMinor, availableMinor, withdrawnMinor, currency];
}

class PayoutRequest extends Equatable {
  const PayoutRequest({
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

  bool get awaitsOwner =>
      status == 'owner_confirmation_pending' || requiresOwnerConfirmation;

  @override
  List<Object?> get props =>
      [id, status, amountMinor, currency, requiresOwnerConfirmation, confirmationToken];
}

class Invoice extends Equatable {
  const Invoice({
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

  @override
  List<Object?> get props =>
      [id, number, type, totalMinor, currency, taxTotalMinor, lineItems, createdAt];
}

/// Manager role never confirms owner payout (B3).
bool canConfirmPayoutAsOwner({
  required UserRole? role,
  required bool isProfileOwner,
}) {
  if (role == UserRole.admin) return true;
  if (role == UserRole.manager) return false;
  return isProfileOwner;
}
