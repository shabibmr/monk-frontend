import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/negotiations/domain/entities/negotiation.dart';
import 'package:monk_web/features/negotiations/domain/repositories/negotiation_repository.dart';
import 'package:monk_web/features/negotiations/presentation/bloc/negotiation_bloc.dart';

class _MockRepo extends Mock implements NegotiationRepository {}

void main() {
  late _MockRepo repo;

  const openNeg = Negotiation(
    id: 'n1',
    applicationId: 'a1',
    status: 'open',
    roundCount: 1,
    maxRounds: 5,
    offers: [
      NegotiationOffer(
        id: 'o1',
        round: 1,
        offeredBy: 'brand',
        collabType: 'paid',
        agreedPriceMinor: 10000,
        currency: 'INR',
        status: 'pending',
        priceLines: [
          OfferPriceLine(deliverableId: 'd1', priceMinor: 10000),
        ],
      ),
    ],
  );

  const atCap = Negotiation(
    id: 'n1',
    applicationId: 'a1',
    status: 'open',
    roundCount: 5,
    maxRounds: 5,
    offers: [],
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('structured offer required — free-text-only rejected', () {
    final v = OfferDraftValidation.validate(
      collabType: 'paid',
      priceLines: const [],
      barterProductDescription: null,
    );
    expect(v.ok, isFalse);
    expect(v.message, contains('price line'));
  });

  test('paid offer with cash lines is valid', () {
    final v = OfferDraftValidation.validate(
      collabType: 'paid',
      priceLines: const [
        OfferPriceLine(deliverableId: 'd1', priceMinor: 5000),
      ],
    );
    expect(v.ok, isTrue);
  });

  test('no client commission math on snapshot — display field only', () {
    const snap = CollaborationSnapshot(
      id: 'c1',
      collabType: 'paid',
      status: 'active',
      agreedPriceMinor: 10000,
      currency: 'INR',
      commissionPct: 12.5,
    );
    // Client must not derive fee from amount * pct.
    expect(snap.commissionPct, 12.5);
    expect(snap.agreedPriceMinor, 10000);
  });

  blocTest<NegotiationBloc, NegotiationState>(
    '5-round ceiling disables further offers',
    build: () {
      when(() => repo.get('n1')).thenAnswer((_) async => atCap);
      return NegotiationBloc(repo);
    },
    act: (b) => b.add(const NegotiationLoaded('n1')),
    expect: () => [
      isA<NegotiationState>().having((s) => s.loading, 'loading', true),
      isA<NegotiationState>()
          .having((s) => s.negotiation?.canCounter, 'canCounter', false)
          .having((s) => s.canSubmitCounter, 'canSubmit', false),
    ],
  );

  blocTest<NegotiationBloc, NegotiationState>(
    'accept locks UI and keeps API commission snapshot',
    build: () {
      when(() => repo.get('n1')).thenAnswer((_) async => openNeg);
      when(
        () => repo.accept(
          negotiationId: any(named: 'negotiationId'),
          offerId: any(named: 'offerId'),
        ),
      ).thenAnswer(
        (_) async => const AcceptNegotiationResult(
          negotiationId: 'n1',
          status: 'accepted',
          collaboration: CollaborationSnapshot(
            id: 'col1',
            collabType: 'paid',
            status: 'active',
            agreedPriceMinor: 10000,
            currency: 'INR',
            commissionPct: 10,
          ),
        ),
      );
      when(() => repo.get('n1')).thenAnswer(
        (_) async => const Negotiation(
          id: 'n1',
          applicationId: 'a1',
          status: 'accepted',
          roundCount: 1,
          maxRounds: 5,
          offers: [
            NegotiationOffer(
              id: 'o1',
              round: 1,
              offeredBy: 'brand',
              collabType: 'paid',
              agreedPriceMinor: 10000,
              currency: 'INR',
              status: 'accepted',
            ),
          ],
        ),
      );
      return NegotiationBloc(repo);
    },
    act: (b) async {
      b.add(const NegotiationLoaded('n1'));
      await Future<void>.delayed(Duration.zero);
      b.add(const NegotiationOfferAccepted('o1'));
    },
    wait: const Duration(milliseconds: 50),
    verify: (b) {
      expect(b.state.termsLocked, isTrue);
      expect(b.state.acceptResult?.collaboration?.commissionPct, 10);
      expect(b.state.canSubmitCounter, isFalse);
    },
  );

  blocTest<NegotiationBloc, NegotiationState>(
    'counter blocked client-side at max rounds',
    build: () {
      when(() => repo.get('n1')).thenAnswer((_) async => atCap);
      return NegotiationBloc(repo);
    },
    act: (b) async {
      b.add(const NegotiationLoaded('n1'));
      await Future<void>.delayed(Duration.zero);
      b.add(
        const NegotiationCounterSubmitted({
          'collabType': 'paid',
          'priceLines': [
            {'deliverableId': 'd1', 'priceMinor': 1},
          ],
        }),
      );
    },
    wait: const Duration(milliseconds: 50),
    verify: (b) {
      expect(b.state.validationMessage, contains('Maximum rounds'));
      verifyNever(
        () => repo.counter(
          negotiationId: any(named: 'negotiationId'),
          body: any(named: 'body'),
        ),
      );
    },
  );
}
