import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.priceMinorUnits,
    required this.currency,
    required this.features,
    required this.billingInterval,
    this.isRecommended = false,
  });

  final String id;
  final String name;
  final String tier; // e.g., 'Free', 'Pro', 'Enterprise'
  final int priceMinorUnits;
  final String currency; // API-provided ISO currency code, e.g. 'USD', 'INR', 'AED', 'EUR'
  final List<String> features;
  final String billingInterval; // 'monthly', 'yearly'
  final bool isRecommended;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: json['tier'] as String? ?? 'Standard',
      priceMinorUnits: json['priceMinorUnits'] as int? ?? json['price_minor_units'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      billingInterval: json['billingInterval'] as String? ?? json['billing_interval'] as String? ?? 'monthly',
      isRecommended: json['isRecommended'] as bool? ?? json['is_recommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tier': tier,
      'priceMinorUnits': priceMinorUnits,
      'currency': currency,
      'features': features,
      'billingInterval': billingInterval,
      'isRecommended': isRecommended,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        tier,
        priceMinorUnits,
        currency,
        features,
        billingInterval,
        isRecommended,
      ];
}
