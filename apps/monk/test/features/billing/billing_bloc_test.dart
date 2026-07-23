import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/billing/domain/entities/billing_invoice.dart';
import 'package:monk_web/features/billing/domain/entities/subscription_details.dart';
import 'package:monk_web/features/billing/domain/entities/subscription_plan.dart';
import 'package:monk_web/features/billing/domain/repositories/billing_repository.dart';
import 'package:monk_web/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:monk_web/features/billing/presentation/bloc/billing_event.dart';
import 'package:monk_web/features/billing/presentation/bloc/billing_state.dart';

class _MockBillingRepository extends Mock implements BillingRepository {}

void main() {
  late _MockBillingRepository repository;

  const samplePlan = SubscriptionPlan(
    id: 'plan_pro',
    name: 'Growth Pro',
    tier: 'Pro',
    priceMinorUnits: 4900,
    currency: 'USD',
    features: ['Multi-currency display', '10 Campaigns'],
    billingInterval: 'monthly',
  );

  const sampleSub = SubscriptionDetails(
    id: 'sub_101',
    status: 'active',
    currentPlan: samplePlan,
    renewsAt: '2026-08-15',
    currency: 'USD',
    activeCampaignCount: 3,
    campaignLimit: 10,
  );

  const sampleInvoice = BillingInvoice(
    id: 'inv_100',
    invoiceNumber: 'INV-2026-001',
    issueDate: '2026-07-01',
    status: 'paid',
    amountMinorUnits: 4900,
    currency: 'USD',
  );

  setUp(() {
    repository = _MockBillingRepository();
  });

  group('BillingBloc Unit Tests', () {
    test('initial state has BillingPhase.initial', () {
      final bloc = BillingBloc(repository);
      expect(bloc.state.phase, equals(BillingPhase.initial));
    });

    blocTest<BillingBloc, BillingState>(
      'emits [loading, ready] when FetchBillingDetailsStarted succeeds',
      build: () {
        when(() => repository.getCurrentSubscription()).thenAnswer((_) async => sampleSub);
        when(() => repository.getAvailablePlans()).thenAnswer((_) async => [samplePlan]);
        when(() => repository.getInvoiceHistory()).thenAnswer((_) async => [sampleInvoice]);
        return BillingBloc(repository);
      },
      act: (bloc) => bloc.add(const FetchBillingDetailsStarted()),
      expect: () => [
        isA<BillingState>()
            .having((s) => s.phase, 'phase', BillingPhase.loading),
        isA<BillingState>()
            .having((s) => s.phase, 'phase', BillingPhase.ready)
            .having((s) => s.subscription, 'subscription', sampleSub)
            .having((s) => s.availablePlans.length, 'availablePlans.length', 1)
            .having((s) => s.invoices.length, 'invoices.length', 1),
      ],
    );

    blocTest<BillingBloc, BillingState>(
      'emits [loading, failure] when FetchBillingDetailsStarted throws',
      build: () {
        when(() => repository.getCurrentSubscription())
            .thenThrow(const ServerFailure('Failed to load subscription'));
        return BillingBloc(repository);
      },
      act: (bloc) => bloc.add(const FetchBillingDetailsStarted()),
      expect: () => [
        isA<BillingState>()
            .having((s) => s.phase, 'phase', BillingPhase.loading),
        isA<BillingState>()
            .having((s) => s.phase, 'phase', BillingPhase.failure)
            .having((s) => s.failure?.message, 'message', 'Failed to load subscription'),
      ],
    );

    blocTest<BillingBloc, BillingState>(
      'emits [isUpgrading: true, updated state] on UpgradePlanRequested success',
      build: () {
        const upgradedPlan = SubscriptionPlan(
          id: 'plan_enterprise',
          name: 'Scale Enterprise',
          tier: 'Enterprise',
          priceMinorUnits: 14900,
          currency: 'USD',
          features: ['Unlimited Campaigns'],
          billingInterval: 'monthly',
        );

        const upgradedSub = SubscriptionDetails(
          id: 'sub_101',
          status: 'active',
          currentPlan: upgradedPlan,
          renewsAt: '2026-08-21',
          currency: 'USD',
          activeCampaignCount: 3,
          campaignLimit: 999,
        );

        when(() => repository.subscribeToPlan('plan_enterprise'))
            .thenAnswer((_) async => upgradedSub);
        return BillingBloc(repository);
      },
      act: (bloc) => bloc.add(const UpgradePlanRequested('plan_enterprise')),
      expect: () => [
        isA<BillingState>().having((s) => s.isUpgrading, 'isUpgrading', true),
        isA<BillingState>()
            .having((s) => s.isUpgrading, 'isUpgrading', false)
            .having((s) => s.subscription?.currentPlan.id, 'plan.id', 'plan_enterprise')
            .having(
              (s) => s.actionSuccessMessage,
              'actionSuccessMessage',
              contains('Scale Enterprise'),
            ),
      ],
      verify: (_) {
        verify(() => repository.subscribeToPlan('plan_enterprise')).called(1);
      },
    );

    blocTest<BillingBloc, BillingState>(
      'emits failure on UpgradePlanRequested error',
      build: () {
        when(() => repository.subscribeToPlan('plan_invalid'))
            .thenThrow(const ServerFailure('Plan not found'));
        return BillingBloc(repository);
      },
      act: (bloc) => bloc.add(const UpgradePlanRequested('plan_invalid')),
      expect: () => [
        isA<BillingState>().having((s) => s.isUpgrading, 'isUpgrading', true),
        isA<BillingState>()
            .having((s) => s.isUpgrading, 'isUpgrading', false)
            .having((s) => s.failure?.message, 'failure.message', 'Plan not found'),
      ],
    );
  });
}
