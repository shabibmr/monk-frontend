import '../../../features/billing/domain/entities/billing_invoice.dart';
import '../../../features/billing/domain/entities/subscription_details.dart';
import '../../../features/billing/domain/entities/subscription_plan.dart';
import '../../../features/billing/domain/repositories/billing_repository.dart';
import '../../errors/failures.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [BillingRepository].
class MockBillingRepository implements BillingRepository {
  MockBillingRepository(this.store);

  final MockSeedStore store;

  static const _plansKey = 'billing_plans';
  static const _invoicesKey = 'billing_invoices';
  static const _subKey = 'subscription';

  static const _starter = SubscriptionPlan(
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
  );

  static const _pro = SubscriptionPlan(
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
  );

  static const _enterprise = SubscriptionPlan(
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
  );

  void _ensureSeeded() {
    if (store.list<SubscriptionPlan>(_plansKey).isEmpty) {
      store.putAll(_plansKey, [_starter, _pro, _enterprise]);
    }
    if (store.singles[_subKey] is! SubscriptionDetails) {
      store.singles[_subKey] = const SubscriptionDetails(
        id: 'sub_demo_101',
        status: 'active',
        currentPlan: _pro,
        renewsAt: '2026-08-15',
        currency: 'USD',
        activeCampaignCount: 4,
        campaignLimit: 10,
        cancelAtPeriodEnd: false,
      );
    }
    if (store.list<BillingInvoice>(_invoicesKey).isEmpty) {
      store.putAll(_invoicesKey, [
        const BillingInvoice(
          id: 'inv-demo-1',
          invoiceNumber: 'INV-2026-0701',
          issueDate: '2026-07-01',
          status: 'paid',
          amountMinorUnits: 4900,
          currency: 'USD',
          pdfUrl: 'https://cdn.monk.local/invoices/inv-demo-1.pdf',
        ),
        const BillingInvoice(
          id: 'inv-demo-2',
          invoiceNumber: 'INV-2026-0601',
          issueDate: '2026-06-01',
          status: 'paid',
          amountMinorUnits: 4900,
          currency: 'USD',
          pdfUrl: 'https://cdn.monk.local/invoices/inv-demo-2.pdf',
        ),
        const BillingInvoice(
          id: 'inv-demo-3',
          invoiceNumber: 'INV-2026-0501',
          issueDate: '2026-05-01',
          status: 'paid',
          amountMinorUnits: 1900,
          currency: 'USD',
        ),
      ]);
    }
  }

  @override
  Future<SubscriptionDetails> getCurrentSubscription() async {
    await store.delay();
    _ensureSeeded();
    return store.singles[_subKey] as SubscriptionDetails;
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    await store.delay();
    _ensureSeeded();
    return store.list<SubscriptionPlan>(_plansKey);
  }

  @override
  Future<List<BillingInvoice>> getInvoiceHistory() async {
    await store.delay();
    _ensureSeeded();
    return store.list<BillingInvoice>(_invoicesKey);
  }

  @override
  Future<SubscriptionDetails> subscribeToPlan(String planId) async {
    await store.delay();
    _ensureSeeded();
    final plan = store.findWhere<SubscriptionPlan>(
      _plansKey,
      (p) => p.id == planId,
    );
    if (plan == null) {
      throw NotFoundFailure('Subscription plan not found: $planId');
    }
    final limit = switch (plan.tier.toLowerCase()) {
      'starter' => 2,
      'enterprise' => 999,
      _ => 10,
    };
    final renews = DateTime.now().add(const Duration(days: 30));
    final sub = SubscriptionDetails(
      id: 'sub_demo_${DateTime.now().millisecondsSinceEpoch}',
      status: 'active',
      currentPlan: plan,
      renewsAt: renews.toIso8601String().split('T').first,
      currency: plan.currency,
      activeCampaignCount:
          (store.singles[_subKey] as SubscriptionDetails?)?.activeCampaignCount ??
              0,
      campaignLimit: limit,
      cancelAtPeriodEnd: false,
    );
    store.singles[_subKey] = sub;

    // Append a pending invoice for the new plan.
    store.add(
      _invoicesKey,
      BillingInvoice(
        id: 'inv-mock-${DateTime.now().millisecondsSinceEpoch}',
        invoiceNumber: 'INV-MOCK-${DateTime.now().millisecondsSinceEpoch}',
        issueDate: DateTime.now().toIso8601String().split('T').first,
        status: 'pending',
        amountMinorUnits: plan.priceMinorUnits,
        currency: plan.currency,
      ),
    );
    return sub;
  }
}
