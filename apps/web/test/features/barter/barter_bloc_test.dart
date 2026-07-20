import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/barter/domain/entities/barter.dart';
import 'package:monk_web/features/barter/domain/repositories/barter_repository.dart';
import 'package:monk_web/features/barter/presentation/bloc/barter_bloc.dart';

class _MockRepo extends Mock implements BarterRepository {}

void main() {
  late _MockRepo repo;

  const pending = BarterStatus(
    collaborationId: 'col1',
    collabType: 'barter',
    collabStatus: 'terms_accepted',
    requiresFulfillment: true,
    skipsProductStates: false,
    returnsSupported: false,
    fulfillment: BarterFulfillment(
      id: 'f1',
      collaborationId: 'col1',
      productDescription: 'Sample kit',
      status: 'pending_shipment',
      declaredValueMinor: 50000,
    ),
  );

  const shipped = BarterStatus(
    collaborationId: 'col1',
    collabType: 'barter',
    collabStatus: 'product_shipped',
    requiresFulfillment: true,
    skipsProductStates: false,
    returnsSupported: false,
    fulfillment: BarterFulfillment(
      id: 'f1',
      collaborationId: 'col1',
      productDescription: 'Sample kit',
      status: 'shipped',
      trackingRef: 'TRK1',
    ),
  );

  const received = BarterStatus(
    collaborationId: 'col1',
    collabType: 'barter',
    collabStatus: 'content_pending',
    requiresFulfillment: true,
    skipsProductStates: false,
    returnsSupported: false,
    fulfillment: BarterFulfillment(
      id: 'f1',
      collaborationId: 'col1',
      productDescription: 'Sample kit',
      status: 'received',
      trackingRef: 'TRK1',
    ),
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('content locked pre-receive; unlocked after content_pending', () {
    expect(pending.contentLocked, isTrue);
    expect(pending.contentLockMessage, contains('locked'));
    expect(shipped.contentLocked, isTrue);
    expect(received.contentLocked, isFalse);
    expect(received.contentUnlocked, isTrue);
  });

  test('pure barter never shows cash charge UI', () {
    expect(pending.isPureBarter, isTrue);
    expect(pending.showCashChargeUi, isFalse);
  });

  test('no invented barter platform fees on entity', () {
    // Declared product value is display-only from API; no fee fields.
    expect(pending.fulfillment?.declaredValueMinor, 50000);
    expect(pending.showCashChargeUi, isFalse);
  });

  blocTest<BarterBloc, BarterState>(
    'ship → receive path',
    build: () {
      when(() => repo.get('col1')).thenAnswer((_) async => pending);
      when(
        () => repo.ship(
          collaborationId: any(named: 'collaborationId'),
          trackingRef: any(named: 'trackingRef'),
          shippingCarrier: any(named: 'shippingCarrier'),
          notes: any(named: 'notes'),
          evidenceFileIds: any(named: 'evidenceFileIds'),
        ),
      ).thenAnswer((_) async => shipped);
      when(
        () => repo.receive(
          collaborationId: any(named: 'collaborationId'),
          notes: any(named: 'notes'),
          evidenceFileIds: any(named: 'evidenceFileIds'),
        ),
      ).thenAnswer((_) async => received);
      return BarterBloc(repo);
    },
    act: (b) async {
      b.add(const BarterLoaded('col1'));
      await Future<void>.delayed(Duration.zero);
      b.add(const BarterShipSubmitted(trackingRef: 'TRK1'));
      await Future<void>.delayed(Duration.zero);
      b.add(const BarterReceiveSubmitted());
    },
    wait: const Duration(milliseconds: 80),
    verify: (b) {
      expect(b.state.status?.collabStatus, 'content_pending');
      expect(b.state.status?.contentUnlocked, isTrue);
      verify(
        () => repo.ship(
          collaborationId: 'col1',
          trackingRef: 'TRK1',
          shippingCarrier: any(named: 'shippingCarrier'),
          notes: any(named: 'notes'),
          evidenceFileIds: any(named: 'evidenceFileIds'),
        ),
      ).called(1);
      verify(
        () => repo.receive(
          collaborationId: 'col1',
          notes: any(named: 'notes'),
          evidenceFileIds: any(named: 'evidenceFileIds'),
        ),
      ).called(1);
    },
  );
}
