import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

class Brief extends Equatable {
  const Brief({
    required this.id,
    required this.brandId,
    required this.goals,
    required this.status,
    this.campaignId,
    this.budgetMinor,
    this.currency,
    this.productDescription,
    this.notes,
    this.managedFeeMode = 'none',
    this.agencyFeeMinor,
  });

  final String id;
  final String brandId;
  final String? campaignId;
  final String goals;
  final String status;
  final int? budgetMinor;
  final String? currency;
  final String? productDescription;
  final String? notes;
  final String managedFeeMode;
  final int? agencyFeeMinor;

  /// Never invent fee lines when mode is none / null amount.
  bool get showAgencyFee =>
      managedFeeMode != 'none' && agencyFeeMinor != null;

  EntityStatus get statusChip {
    switch (status) {
      case 'submitted':
        return EntityStatus.submitted;
      case 'triaged':
      case 'in_build':
        return EntityStatus.inProgress;
      case 'converted':
        return EntityStatus.completed;
      case 'cancelled':
        return EntityStatus.cancelled;
      default:
        return EntityStatus.inReview;
    }
  }

  @override
  List<Object?> get props => [
        id,
        brandId,
        campaignId,
        goals,
        status,
        budgetMinor,
        currency,
        productDescription,
        notes,
        managedFeeMode,
        agencyFeeMinor,
      ];
}

class SubmitBriefResult extends Equatable {
  const SubmitBriefResult({
    required this.brief,
    this.campaignId,
    this.managedFeeMode = 'none',
    this.agencyFeeMinor,
  });

  final Brief brief;
  final String? campaignId;
  final String managedFeeMode;
  final int? agencyFeeMinor;

  @override
  List<Object?> get props =>
      [brief, campaignId, managedFeeMode, agencyFeeMinor];
}
