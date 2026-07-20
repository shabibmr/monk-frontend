import 'package:api_client/api_client.dart';
import '../../domain/entities/billing_invoice.dart';
import '../../domain/entities/subscription_details.dart';
import '../../domain/entities/subscription_plan.dart';

class BillingRemoteDataSource {
  const BillingRemoteDataSource(this._client);

  final MonkApiClient _client;

  Future<SubscriptionDetails> getCurrentSubscription() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiPaths.billingSubscriptions,
      );
      final data = response.data;
      if (data != null) {
        return SubscriptionDetails.fromJson(data);
      }
    } catch (_) {
      // Fallback stub for backend offline/development
    }

    return const SubscriptionDetails(
      id: 'sub_live_101',
      status: 'active',
      renewsAt: '2026-08-15',
      currency: 'USD',
      activeCampaignCount: 4,
      campaignLimit: 10,
      currentPlan: SubscriptionPlan(
        id: 'plan_pro',
        name: 'Growth Pro',
        tier: 'Pro',
        priceMinorUnits: 4900,
        currency: 'USD',
        features: [
          'Up to 10 Active Campaigns',
          'Multi-Currency Invoicing',
          'AI-Powered Matchmaking',
          'Priority Deliverable Review',
        ],
        billingInterval: 'monthly',
      ),
    );
  }

  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        ApiPaths.billingPlans,
      );
      final data = response.data;
      if (data != null) {
        return data
            .map((item) => SubscriptionPlan.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback stub for development
    }

    return const [
      SubscriptionPlan(
        id: 'plan_starter',
        name: 'Starter Tier',
        tier: 'Starter',
        priceMinorUnits: 1900,
        currency: 'USD',
        features: [
          '2 Active Campaigns',
          'Standard Support',
          'Basic Analytics',
        ],
        billingInterval: 'monthly',
      ),
      SubscriptionPlan(
        id: 'plan_pro',
        name: 'Growth Pro',
        tier: 'Pro',
        priceMinorUnits: 4900,
        currency: 'USD',
        features: [
          'Up to 10 Active Campaigns',
          'Multi-Currency Invoicing',
          'AI-Powered Matchmaking',
          'Priority Deliverable Review',
        ],
        billingInterval: 'monthly',
        isRecommended: true,
      ),
      SubscriptionPlan(
        id: 'plan_enterprise',
        name: 'Scale Enterprise',
        tier: 'Enterprise',
        priceMinorUnits: 14900,
        currency: 'USD',
        features: [
          'Unlimited Active Campaigns',
          'Dedicated Manager Account',
          'Custom SLA & Invoicing',
          'Full API & Export Access',
        ],
        billingInterval: 'monthly',
      ),
    ];
  }

  Future<List<BillingInvoice>> getInvoiceHistory() async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        ApiPaths.billingInvoices,
      );
      final data = response.data;
      if (data != null) {
        return data
            .map((item) => BillingInvoice.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback stub for development
    }

    return const [
      BillingInvoice(
        id: 'inv_1001',
        invoiceNumber: 'INV-2026-001',
        issueDate: '2026-07-01',
        status: 'paid',
        amountMinorUnits: 4900,
        currency: 'USD',
      ),
      BillingInvoice(
        id: 'inv_1000',
        invoiceNumber: 'INV-2026-000',
        issueDate: '2026-06-01',
        status: 'paid',
        amountMinorUnits: 4900,
        currency: 'USD',
      ),
      BillingInvoice(
        id: 'inv_0999',
        invoiceNumber: 'INV-2026-OLD',
        issueDate: '2026-05-01',
        status: 'paid',
        amountMinorUnits: 1900,
        currency: 'USD',
      ),
    ];
  }

  Future<SubscriptionDetails> subscribeToPlan(String planId) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiPaths.billingSubscribe(planId),
      );
      final data = response.data;
      if (data != null) {
        return SubscriptionDetails.fromJson(data);
      }
    } catch (_) {
      // Fallback stub for upgrade request
    }

    final plans = await getAvailablePlans();
    final selectedPlan = plans.firstWhere(
      (p) => p.id == planId,
      orElse: () => plans.first,
    );

    return SubscriptionDetails(
      id: 'sub_live_101',
      status: 'active',
      renewsAt: '2026-08-21',
      currency: selectedPlan.currency,
      activeCampaignCount: 4,
      campaignLimit: selectedPlan.tier == 'Enterprise' ? 999 : 10,
      currentPlan: selectedPlan,
    );
  }
}
