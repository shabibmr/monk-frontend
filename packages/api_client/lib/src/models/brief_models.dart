class BriefDto {
  const BriefDto({
    required this.id,
    required this.brandId,
    required this.goals,
    required this.status,
    this.campaignId,
    this.budgetMinor,
    this.currency,
    this.productDescription,
    this.notes,
    this.assignedOperatorUserId,
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
  final String? assignedOperatorUserId;

  factory BriefDto.fromJson(Map<String, dynamic> json) {
    final budget = json['budgetMinor'];
    return BriefDto(
      id: json['id'] as String,
      brandId: json['brandId'] as String,
      campaignId: json['campaignId'] as String?,
      goals: json['goals'] as String? ?? '',
      status: json['status'] as String? ?? 'submitted',
      budgetMinor: budget is int
          ? budget
          : budget is num
              ? budget.toInt()
              : int.tryParse('$budget'),
      currency: json['currency'] as String?,
      productDescription: json['productDescription'] as String?,
      notes: json['notes'] as String?,
      assignedOperatorUserId: json['assignedOperatorUserId'] as String?,
    );
  }
}

class SubmitBriefResultDto {
  const SubmitBriefResultDto({
    required this.brief,
    this.campaignId,
    this.managedFeeMode = 'none',
    this.agencyFeeMinor,
  });

  final BriefDto brief;
  final String? campaignId;
  final String managedFeeMode;
  final int? agencyFeeMinor;

  factory SubmitBriefResultDto.fromJson(Map<String, dynamic> json) {
    return SubmitBriefResultDto(
      brief: BriefDto.fromJson(json['brief'] as Map<String, dynamic>),
      campaignId: json['campaignId'] as String?,
      managedFeeMode: json['managedFeeMode'] as String? ?? 'none',
      agencyFeeMinor: json['agencyFeeMinor'] as int?,
    );
  }
}

class ConvertBriefResultDto {
  const ConvertBriefResultDto({
    required this.brief,
    this.campaignId,
    this.managedFeeMode = 'none',
    this.agencyFeeMinor,
  });

  final BriefDto brief;
  final String? campaignId;
  final String managedFeeMode;
  final int? agencyFeeMinor;

  factory ConvertBriefResultDto.fromJson(Map<String, dynamic> json) {
    return ConvertBriefResultDto(
      brief: BriefDto.fromJson(json['brief'] as Map<String, dynamic>),
      campaignId: json['campaignId'] as String?,
      managedFeeMode: json['managedFeeMode'] as String? ?? 'none',
      agencyFeeMinor: json['agencyFeeMinor'] as int?,
    );
  }
}
