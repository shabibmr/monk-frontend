import '../../../features/payments/domain/entities/payment.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Payments, earnings, payouts, collab invoices.
void seedMoney(MockSeedStore store) {
  // pay-demo-1: held → releasable (brand can release to creator).
  // Also fundable sample via second payment in created state.
  store.putAll('payments', [
    const Payment(
      id: MockIds.payment1,
      collaborationId: MockIds.collab1,
      brandId: MockIds.brandOrg1,
      amountMinor: 2500000,
      currency: 'INR',
      status: 'held',
      commissionPct: 15,
      commissionMinor: 375000,
      payoutMinor: 2125000,
      gatewayOrderId: 'order_demo_pay_1',
      checkout: {
        'provider': 'mock_razorpay',
        'orderId': 'order_demo_pay_1',
        'keyId': 'rzp_test_demo',
      },
    ),
    const Payment(
      id: 'pay-demo-fundable',
      collaborationId: MockIds.collab1,
      brandId: MockIds.brandOrg1,
      amountMinor: 500000,
      currency: 'INR',
      status: 'created',
      commissionPct: 15,
      commissionMinor: 75000,
      payoutMinor: 425000,
      gatewayOrderId: null,
      checkout: null,
    ),
    const Payment(
      id: 'pay-demo-released',
      collaborationId: MockIds.collab1,
      brandId: MockIds.brandOrg1,
      amountMinor: 2000000,
      currency: 'INR',
      status: 'released',
      commissionPct: 15,
      commissionMinor: 300000,
      payoutMinor: 1700000,
      gatewayOrderId: 'order_demo_pay_rel',
    ),
  ]);

  store.putAll('earnings', [
    const Earnings(
      profileId: MockIds.influencer1,
      pendingMinor: 2125000,
      availableMinor: 1850000,
      withdrawnMinor: 7200000,
      currency: 'INR',
    ),
  ]);

  store.putAll('payouts', [
    const PayoutRequest(
      id: 'payout-demo-1',
      status: 'completed',
      amountMinor: 3000000,
      currency: 'INR',
      requiresOwnerConfirmation: false,
    ),
    const PayoutRequest(
      id: 'payout-demo-2',
      status: 'owner_confirmation_pending',
      amountMinor: 1850000,
      currency: 'INR',
      requiresOwnerConfirmation: true,
      confirmationToken: 'mock-payout-confirm-token',
    ),
  ]);

  store.putAll('invoices', [
    const Invoice(
      id: 'inv-demo-1',
      number: 'INV-2026-001',
      type: 'collaboration',
      totalMinor: 2500000,
      currency: 'INR',
      taxTotalMinor: 0,
      lineItems: [
        {
          'label': 'Summer Launch — reel package',
          'amountMinor': 2500000,
        },
      ],
      createdAt: '2026-06-16T00:00:00Z',
    ),
    const Invoice(
      id: 'inv-demo-2',
      number: 'INV-2026-002',
      type: 'platform_fee',
      totalMinor: 375000,
      currency: 'INR',
      taxTotalMinor: 67500,
      createdAt: '2026-06-16T00:00:00Z',
    ),
  ]);
}
