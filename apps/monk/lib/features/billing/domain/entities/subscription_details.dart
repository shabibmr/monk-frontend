import 'package:equatable/equatable.dart';
import 'subscription_plan.dart';

class SubscriptionDetails extends Equatable {
  const SubscriptionDetails({
    required this.id,
    required this.status,
    required this.currentPlan,
    required this.renewsAt,
    required this.currency,
    this.activeCampaignCount = 0,
    this.campaignLimit = 10,
    this.cancelAtPeriodEnd = false,
  });

  final String id;
  final String status; // 'active', 'past_due', 'canceled', 'trialing'
  final SubscriptionPlan currentPlan;
  final String renewsAt;
  final String currency; // API-provided ISO currency code
  final int activeCampaignCount;
  final int campaignLimit;
  final bool cancelAtPeriodEnd;

  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    final planJson = json['currentPlan'] as Map<String, dynamic>? ??
        json['current_plan'] as Map<String, dynamic>? ??
        {
          'id': 'plan_pro',
          'name': 'Pro Plan',
          'tier': 'Pro',
          'priceMinorUnits': 4900,
          'currency': json['currency'] as String? ?? 'USD',
          'features': ['Unlimited Campaigns', 'AI Assist', 'Priority Support'],
          'billingInterval': 'monthly',
        };

    return SubscriptionDetails(
      id: json['id'] as String? ?? 'sub_default',
      status: json['status'] as String? ?? 'active',
      currentPlan: SubscriptionPlan.fromJson(planJson),
      renewsAt: json['renewsAt'] as String? ?? json['renews_at'] as String? ?? '2026-08-01',
      currency: json['currency'] as String? ?? 'USD',
      activeCampaignCount: json['activeCampaignCount'] as int? ?? json['active_campaign_count'] as int? ?? 3,
      campaignLimit: json['campaignLimit'] as int? ?? json['campaign_limit'] as int? ?? 10,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? json['cancel_at_period_end'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'currentPlan': currentPlan.toJson(),
      'renewsAt': renewsAt,
      'currency': currency,
      'activeCampaignCount': activeCampaignCount,
      'campaignLimit': campaignLimit,
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
    };
  }

  @override
  List<Object?> get props => [
        id,
        status,
        currentPlan,
        renewsAt,
        currency,
        activeCampaignCount,
        campaignLimit,
        cancelAtPeriodEnd,
      ];
}
