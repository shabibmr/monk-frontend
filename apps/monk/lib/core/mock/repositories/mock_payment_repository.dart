import '../../../features/payments/domain/entities/payment.dart';
import '../../../features/payments/domain/repositories/payment_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// In-memory [PaymentRepository].
///
/// Store keys:
/// - `payments` → `List<Payment>`
/// - `invoices` → `List<Invoice>`
/// - `payouts` → `List<_PayoutRow>` stored as Map entries
/// - singles `earnings` → `Map<String, Earnings>` (profileId → earnings)
class MockPaymentRepository implements PaymentRepository {
  MockPaymentRepository(this._store);

  final MockSeedStore _store;

  void _ensureFixtures() {
    if (_store.list<Payment>('payments').isEmpty) {
      const amount = 1500000;
      const commissionPct = 15.0;
      final commission = (amount * commissionPct / 100).round();
      _store.putAll('payments', [
        Payment(
          id: MockIds.payment1,
          collaborationId: MockIds.collab1,
          brandId: MockIds.brandOrg1,
          amountMinor: amount,
          currency: 'INR',
          status: 'created',
          commissionPct: commissionPct,
          commissionMinor: commission,
          payoutMinor: amount - commission,
          gatewayOrderId: 'order-demo-1',
          checkout: const {
            'provider': 'mock',
            'orderId': 'order-demo-1',
            'amountMinor': amount,
            'currency': 'INR',
          },
        ),
      ]);
    }

    if (_store.list<Invoice>('invoices').isEmpty) {
      _store.putAll('invoices', [
        Invoice(
          id: 'inv-demo-1',
          number: 'INV-DEMO-001',
          type: 'platform_fee',
          totalMinor: 225000,
          currency: 'INR',
          taxTotalMinor: 0,
          createdAt: DateTime.now().toUtc().toIso8601String(),
        ),
        Invoice(
          id: 'inv-demo-2',
          number: 'INV-DEMO-002',
          type: 'collaboration',
          totalMinor: 1500000,
          currency: 'INR',
          taxTotalMinor: 0,
          createdAt: DateTime.now().toUtc().toIso8601String(),
        ),
      ]);
    }

    // Fallback only when seed did not run; keep in sync with seed_money.dart.
    final earningsMap = _earningsMap();
    earningsMap.putIfAbsent(
      MockIds.influencer1,
      () => const Earnings(
        profileId: MockIds.influencer1,
        pendingMinor: 2125000,
        availableMinor: 1850000,
        withdrawnMinor: 7200000,
        currency: 'INR',
      ),
    );
  }

  Map<String, Earnings> _earningsMap() {
    final raw = _store.singles['earnings'];
    if (raw is Map<String, Earnings>) return raw;
    if (raw is Map) {
      final converted = <String, Earnings>{};
      raw.forEach((k, v) {
        if (v is Earnings) converted[k.toString()] = v;
      });
      _store.singles['earnings'] = converted;
      return converted;
    }
    final map = <String, Earnings>{};
    _store.singles['earnings'] = map;
    return map;
  }

  Payment _replacePayment(Payment p) {
    _store.replaceWhere<Payment>('payments', (x) => x.id == p.id, p);
    return p;
  }

  Payment _copyPayment(Payment p, {String? status, Map<String, dynamic>? checkout}) =>
      Payment(
        id: p.id,
        collaborationId: p.collaborationId,
        brandId: p.brandId,
        amountMinor: p.amountMinor,
        currency: p.currency,
        status: status ?? p.status,
        commissionPct: p.commissionPct,
        commissionMinor: p.commissionMinor,
        payoutMinor: p.payoutMinor,
        gatewayOrderId: p.gatewayOrderId,
        checkout: checkout ?? p.checkout,
      );

  @override
  Future<Payment> fund(String collaborationId) async {
    await _store.delay();
    _ensureFixtures();

    final existing = _store
        .list<Payment>('payments')
        .where(
          (p) =>
              p.collaborationId == collaborationId &&
              p.status != 'refunded' &&
              p.status != 'failed',
        )
        .toList();

    // If already held/funded/released, return current cash payment.
    for (final p in existing) {
      if (p.status == 'held' ||
          p.status == 'funded' ||
          p.status == 'released' ||
          p.status == 'paid_out') {
        return p;
      }
    }

    final created = existing.where((p) => p.status == 'created').toList();
    if (created.isNotEmpty) {
      // Transition created → held (escrow funded for demo).
      final p = created.first;
      return _replacePayment(
        _copyPayment(
          p,
          status: 'held',
          checkout: {
            ...?p.checkout,
            'status': 'paid',
            'fundedAt': DateTime.now().toUtc().toIso8601String(),
          },
        ),
      );
    }

    const amount = 1500000;
    const commissionPct = 15.0;
    final commission = (amount * commissionPct / 100).round();
    final payment = Payment(
      id: collaborationId == MockIds.collab1
          ? MockIds.payment1
          : 'pay-mock-${DateTime.now().microsecondsSinceEpoch}',
      collaborationId: collaborationId,
      brandId: MockIds.brandOrg1,
      amountMinor: amount,
      currency: 'INR',
      status: 'held',
      commissionPct: commissionPct,
      commissionMinor: commission,
      payoutMinor: amount - commission,
      gatewayOrderId: 'order-mock-${DateTime.now().millisecondsSinceEpoch}',
      checkout: {
        'provider': 'mock',
        'status': 'paid',
        'fundedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
    _store.add('payments', payment);
    return payment;
  }

  @override
  Future<List<Payment>> listPayments(String collaborationId) async {
    await _store.delay();
    _ensureFixtures();
    return _store
        .list<Payment>('payments')
        .where((p) => p.collaborationId == collaborationId)
        .toList();
  }

  @override
  Future<Payment> release(String paymentId) async {
    await _store.delay();
    _ensureFixtures();

    final p = _store.findWhere<Payment>('payments', (x) => x.id == paymentId);
    if (p == null) {
      throw NotFoundFailure('Payment not found: $paymentId');
    }
    if (!p.canRelease && p.status != 'funded') {
      throw ConflictFailure(
        'Payment cannot be released from status ${p.status}',
        errorCode: 'INVALID_PAYMENT_STATE',
      );
    }

    final released = _copyPayment(p, status: 'released');
    _replacePayment(released);

    // Credit creator available earnings.
    final earnings = _earningsMap();
    final profileId = MockIds.influencer1;
    final current = earnings[profileId];
    final payout = p.payoutMinor ?? (p.amountMinor - (p.commissionMinor ?? 0));
    if (current != null) {
      earnings[profileId] = Earnings(
        profileId: profileId,
        pendingMinor: (current.pendingMinor - payout).clamp(0, 1 << 62),
        availableMinor: current.availableMinor + payout,
        withdrawnMinor: current.withdrawnMinor,
        currency: current.currency,
      );
    }

    return released;
  }

  @override
  Future<Payment> refund(String paymentId, {int? amountMinor}) async {
    await _store.delay();
    _ensureFixtures();

    final p = _store.findWhere<Payment>('payments', (x) => x.id == paymentId);
    if (p == null) {
      throw NotFoundFailure('Payment not found: $paymentId');
    }
    if (p.status == 'refunded' || p.status == 'partially_refunded') {
      throw const ConflictFailure('Payment already refunded');
    }
    if (p.status == 'released' || p.status == 'paid_out') {
      throw const ConflictFailure(
        'Cannot refund a released payment',
        errorCode: 'ALREADY_RELEASED',
      );
    }

    final partial = amountMinor != null &&
        amountMinor > 0 &&
        amountMinor < p.amountMinor;
    return _replacePayment(
      _copyPayment(
        p,
        status: partial ? 'partially_refunded' : 'refunded',
      ),
    );
  }

  @override
  Future<Earnings> earnings(String profileId) async {
    await _store.delay();
    _ensureFixtures();
    return _earningsMap()[profileId] ??
        Earnings(
          profileId: profileId,
          pendingMinor: 0,
          availableMinor: 0,
          withdrawnMinor: 0,
          currency: 'INR',
        );
  }

  @override
  Future<PayoutRequest> requestPayout(
    String profileId, {
    required int amountMinor,
  }) async {
    await _store.delay();
    _ensureFixtures();

    if (amountMinor <= 0) {
      throw const ValidationFailure('amountMinor must be positive');
    }

    final e = await earnings(profileId);
    if (amountMinor > e.availableMinor) {
      throw const ValidationFailure(
        'Insufficient available balance',
        errorCode: 'INSUFFICIENT_BALANCE',
      );
    }

    final payout = PayoutRequest(
      id: 'payout-mock-${DateTime.now().microsecondsSinceEpoch}',
      status: 'owner_confirmation_pending',
      amountMinor: amountMinor,
      currency: e.currency,
      requiresOwnerConfirmation: true,
      confirmationToken: 'tok-mock-${DateTime.now().millisecondsSinceEpoch}',
    );

    // Store as map so we can track profileId (entity has no field).
    _store.add('payouts', {
      'profileId': profileId,
      'request': payout,
    });

    // Move available → reserved (pending).
    final map = _earningsMap();
    map[profileId] = Earnings(
      profileId: profileId,
      pendingMinor: e.pendingMinor + amountMinor,
      availableMinor: e.availableMinor - amountMinor,
      withdrawnMinor: e.withdrawnMinor,
      currency: e.currency,
    );

    return payout;
  }

  @override
  Future<void> confirmPayout(String payoutId, {String? token}) async {
    await _store.delay();
    _ensureFixtures();

    final rows = _store.list<Map>('payouts');
    Map? found;
    for (final row in rows) {
      final req = row['request'];
      if (req is PayoutRequest && req.id == payoutId) {
        found = row;
        break;
      }
    }
    if (found == null) {
      // Also search typed-less dynamic list.
      for (final raw in _store.collections['payouts'] ?? const []) {
        if (raw is Map && raw['request'] is PayoutRequest) {
          final req = raw['request'] as PayoutRequest;
          if (req.id == payoutId) {
            found = raw;
            break;
          }
        }
      }
    }
    if (found == null) {
      throw NotFoundFailure('Payout not found: $payoutId');
    }

    final req = found['request'] as PayoutRequest;
    if (req.requiresOwnerConfirmation &&
        token != null &&
        req.confirmationToken != null &&
        token != req.confirmationToken) {
      throw const ValidationFailure(
        'Invalid confirmation token',
        errorCode: 'INVALID_TOKEN',
      );
    }

    final confirmed = PayoutRequest(
      id: req.id,
      status: 'completed',
      amountMinor: req.amountMinor,
      currency: req.currency,
      requiresOwnerConfirmation: false,
      confirmationToken: req.confirmationToken,
    );
    found['request'] = confirmed;

    final profileId = found['profileId']?.toString() ?? MockIds.influencer1;
    final e = _earningsMap()[profileId];
    if (e != null) {
      _earningsMap()[profileId] = Earnings(
        profileId: profileId,
        pendingMinor: (e.pendingMinor - req.amountMinor).clamp(0, 1 << 62),
        availableMinor: e.availableMinor,
        withdrawnMinor: e.withdrawnMinor + req.amountMinor,
        currency: e.currency,
      );
    }
  }

  @override
  Future<List<Invoice>> listInvoices() async {
    await _store.delay();
    _ensureFixtures();
    return _store.list<Invoice>('invoices');
  }

  @override
  Future<Invoice> getInvoice(String id) async {
    await _store.delay();
    _ensureFixtures();
    final inv = _store.findWhere<Invoice>('invoices', (i) => i.id == id);
    if (inv == null) {
      throw NotFoundFailure('Invoice not found: $id');
    }
    return inv;
  }
}
