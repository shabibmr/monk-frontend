import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_shared/monk_shared.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/payments/domain/entities/payment.dart';
import 'package:monk_web/features/payments/domain/repositories/payment_repository.dart';
import 'package:monk_web/features/payments/presentation/cubit/earnings_cubit.dart';
import 'package:monk_web/features/payments/presentation/cubit/payment_cubit.dart';

class _MockRepo extends Mock implements PaymentRepository {}

void main() {
  late _MockRepo repo;

  const held = Payment(
    id: 'pay1',
    collaborationId: 'col1',
    brandId: 'b1',
    amountMinor: 100000,
    currency: 'INR',
    status: 'held',
    commissionPct: 10,
    commissionMinor: 10000,
    payoutMinor: 90000,
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('no client commission math — breakdown uses API amounts only', () {
    final lines = held.apiFeeBreakdown;
    expect(lines.map((l) => l.amountMinor).toList(), [100000, 10000, 90000]);
    // Must not invent fee as amount * pct / 100 on client for display authority.
    expect(held.commissionMinor, 10000);
    expect(held.commissionPct, 10);
  });

  test('manager cannot confirm payout; owner can', () {
    expect(
      canConfirmPayoutAsOwner(role: UserRole.manager, isProfileOwner: false),
      isFalse,
    );
    expect(
      canConfirmPayoutAsOwner(role: UserRole.influencer, isProfileOwner: true),
      isTrue,
    );
    expect(
      canConfirmPayoutAsOwner(role: UserRole.admin, isProfileOwner: false),
      isTrue,
    );
  });

  blocTest<PaymentCubit, PaymentState>(
    'release dialog fixture uses API breakdown fields',
    build: () {
      var released = false;
      when(() => repo.listPayments('col1')).thenAnswer((_) async {
        if (released) {
          return [
            const Payment(
              id: 'pay1',
              collaborationId: 'col1',
              brandId: 'b1',
              amountMinor: 100000,
              currency: 'INR',
              status: 'released',
              commissionPct: 10,
              commissionMinor: 10000,
              payoutMinor: 90000,
            ),
          ];
        }
        return [held];
      });
      when(() => repo.release('pay1')).thenAnswer((_) async {
        released = true;
        return const Payment(
          id: 'pay1',
          collaborationId: 'col1',
          brandId: 'b1',
          amountMinor: 100000,
          currency: 'INR',
          status: 'released',
          commissionPct: 10,
          commissionMinor: 10000,
          payoutMinor: 90000,
        );
      });
      return PaymentCubit(repo, 'col1');
    },
    act: (c) async {
      await c.load();
      expect(c.state.payments.single.apiFeeBreakdown.length, 3);
      await c.release('pay1');
    },
    verify: (c) {
      expect(c.state.payments.single.status, 'released');
      verify(() => repo.release('pay1')).called(1);
    },
  );

  blocTest<PaymentCubit, PaymentState>(
    'fund double-submit guard + barter hides cash path',
    build: () {
      when(() => repo.listPayments('col1')).thenAnswer((_) async => []);
      when(() => repo.fund('col1')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        throw const ValidationFailure(
          'Pure barter creates no payment rows',
          errorCode: 'BARTER_NO_FUNDING',
        );
      });
      return PaymentCubit(repo, 'col1');
    },
    act: (c) async {
      final f1 = c.fund();
      final f2 = c.fund(); // second should no-op while first in flight
      await Future.wait([f1, f2]);
    },
    verify: (c) {
      expect(c.state.barterOnly, isTrue);
      verify(() => repo.fund('col1')).called(1);
    },
  );

  blocTest<EarningsCubit, EarningsState>(
    'manager confirm payout blocked on cubit',
    build: () {
      when(() => repo.earnings(any())).thenAnswer(
        (_) async => const Earnings(
          profileId: 'p1',
          pendingMinor: 0,
          availableMinor: 5000,
          withdrawnMinor: 0,
          currency: 'INR',
        ),
      );
      return EarningsCubit(
        repo,
        profileId: 'p1',
        role: UserRole.manager,
        isProfileOwner: false,
      );
    },
    act: (c) async {
      await c.load();
      await c.confirmPayout('po1');
    },
    verify: (c) {
      expect(c.state.failure, isA<ForbiddenFailure>());
      verifyNever(
        () => repo.confirmPayout(any(), token: any(named: 'token')),
      );
    },
  );
}
