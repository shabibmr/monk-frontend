import 'package:equatable/equatable.dart';

class ReferralReward extends Equatable {
  const ReferralReward({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    this.referredUserLabel,
    required this.rewardAmountMinor,
    this.currency = 'INR',
    required this.status,
    required this.attributionType,
    this.createdAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  final String id;
  final String referrerId;
  final String referredUserId;
  final String? referredUserLabel;
  final int rewardAmountMinor;
  final String currency;
  /// 'pending', 'approved', 'paid', 'rejected'
  final String status;
  /// 'user_signup', 'first_deal', 'campaign_published'
  final String attributionType;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  factory ReferralReward.fromJson(Map<String, dynamic> json) {
    return ReferralReward(
      id: json['id'] as String? ?? '',
      referrerId: json['referrerId'] as String? ?? '',
      referredUserId: json['referredUserId'] as String? ?? '',
      referredUserLabel: json['referredUserLabel'] as String? ??
          json['referredUserEmail'] as String?,
      rewardAmountMinor: json['rewardAmountMinor'] as int? ??
          json['amountMinor'] as int? ??
          0,
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'pending',
      attributionType: json['attributionType'] as String? ?? 'user_signup',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'referrerId': referrerId,
        'referredUserId': referredUserId,
        'referredUserLabel': referredUserLabel,
        'rewardAmountMinor': rewardAmountMinor,
        'currency': currency,
        'status': status,
        'attributionType': attributionType,
        'createdAt': createdAt?.toIso8601String(),
        'reviewedAt': reviewedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
      };

  @override
  List<Object?> get props => [
        id,
        referrerId,
        referredUserId,
        referredUserLabel,
        rewardAmountMinor,
        currency,
        status,
        attributionType,
        createdAt,
        reviewedAt,
        rejectionReason,
      ];
}

class ReferralSummary extends Equatable {
  const ReferralSummary({
    required this.totalEarnedMinor,
    required this.pendingRewardsMinor,
    required this.totalReferralsCount,
    this.currency = 'INR',
    this.attributionBreakdown = const {},
  });

  final int totalEarnedMinor;
  final int pendingRewardsMinor;
  final int totalReferralsCount;
  final String currency;
  final Map<String, int> attributionBreakdown;

  factory ReferralSummary.fromJson(Map<String, dynamic> json) {
    final breakdown = (json['attributionBreakdown'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v as int)) ??
        const {};
    return ReferralSummary(
      totalEarnedMinor: json['totalEarnedMinor'] as int? ?? 0,
      pendingRewardsMinor: json['pendingRewardsMinor'] as int? ?? 0,
      totalReferralsCount: json['totalReferralsCount'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      attributionBreakdown: breakdown,
    );
  }

  @override
  List<Object?> get props => [
        totalEarnedMinor,
        pendingRewardsMinor,
        totalReferralsCount,
        currency,
        attributionBreakdown,
      ];
}
