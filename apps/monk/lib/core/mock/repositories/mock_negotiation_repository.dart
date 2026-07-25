import '../../../features/marketplace/domain/entities/marketplace.dart';
import '../../../features/negotiations/domain/entities/negotiation.dart';
import '../../../features/negotiations/domain/repositories/negotiation_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// In-memory [NegotiationRepository].
///
/// Store keys:
/// - `negotiations` → `List<Negotiation>`
/// - `collaborations` → `List<CollaborationSnapshot>` (created on accept)
/// - `applications` → updated to `converted` on accept
class MockNegotiationRepository implements NegotiationRepository {
  MockNegotiationRepository(this._store);

  final MockSeedStore _store;

  void _ensureFixtures() {
    if (_store.list<Negotiation>('negotiations').isNotEmpty) return;

    final offer = NegotiationOffer(
      id: 'offer-demo-1',
      round: 1,
      offeredBy: 'influencer',
      collabType: 'paid',
      agreedPriceMinor: 1500000,
      currency: 'INR',
      status: 'pending',
      priceLines: const [
        OfferPriceLine(deliverableId: 'del-demo-1', priceMinor: 1500000),
      ],
      message: 'Happy to create a reel for this rate.',
    );

    _store.putAll('negotiations', [
      Negotiation(
        id: MockIds.negotiation1,
        applicationId: MockIds.application1,
        status: 'open',
        roundCount: 1,
        offers: [offer],
      ),
    ]);
  }

  Negotiation? _find(String id) =>
      _store.findWhere<Negotiation>('negotiations', (n) => n.id == id);

  Negotiation _replace(Negotiation n) {
    _store.replaceWhere<Negotiation>('negotiations', (x) => x.id == n.id, n);
    return n;
  }

  NegotiationOffer _offerFromBody(
    Map<String, dynamic> body, {
    required int round,
    required String offeredBy,
  }) {
    final collabType = (body['collabType'] as String?) ?? 'paid';
    final currency = (body['currency'] as String?) ?? 'INR';
    final message = body['message'] as String?;

    final rawLines = body['priceLines'] as List<dynamic>? ??
        body['prices'] as List<dynamic>? ??
        const [];
    final priceLines = rawLines.map((e) {
      final m = e is Map<String, dynamic>
          ? e
          : Map<String, dynamic>.from(e as Map);
      final p = m['priceMinor'];
      return OfferPriceLine(
        deliverableId: m['deliverableId']?.toString() ?? '',
        priceMinor: p is int
            ? p
            : p is num
                ? p.toInt()
                : int.tryParse('$p') ?? 0,
      );
    }).toList();

    final agreed = body['agreedPriceMinor'] is int
        ? body['agreedPriceMinor'] as int
        : body['agreedPriceMinor'] is num
            ? (body['agreedPriceMinor'] as num).toInt()
            : priceLines.fold<int>(0, (s, l) => s + l.priceMinor);

    final barterDesc = body['barterProductDescription'] as String?;
    final barterVal = body['barterDeclaredValueMinor'] is int
        ? body['barterDeclaredValueMinor'] as int
        : body['barterDeclaredValueMinor'] is num
            ? (body['barterDeclaredValueMinor'] as num).toInt()
            : null;

    return NegotiationOffer(
      id: 'offer-mock-${DateTime.now().microsecondsSinceEpoch}',
      round: round,
      offeredBy: offeredBy,
      collabType: collabType,
      agreedPriceMinor: agreed,
      currency: currency,
      status: 'pending',
      priceLines: priceLines,
      barterProductDescription: barterDesc,
      barterDeclaredValueMinor: barterVal,
      message: message,
    );
  }

  List<NegotiationOffer> _supersedePending(List<NegotiationOffer> offers) {
    return offers
        .map(
          (o) => o.isPending
              ? NegotiationOffer(
                  id: o.id,
                  round: o.round,
                  offeredBy: o.offeredBy,
                  collabType: o.collabType,
                  agreedPriceMinor: o.agreedPriceMinor,
                  currency: o.currency,
                  status: 'superseded',
                  priceLines: o.priceLines,
                  barterProductDescription: o.barterProductDescription,
                  barterDeclaredValueMinor: o.barterDeclaredValueMinor,
                  message: o.message,
                )
              : o,
        )
        .toList();
  }

  @override
  Future<Negotiation> open({
    required String applicationId,
    required Map<String, dynamic> body,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final existing = _store.findWhere<Negotiation>(
      'negotiations',
      (n) => n.applicationId == applicationId && n.isOpen,
    );
    if (existing != null) {
      throw ConflictFailure(
        'Open negotiation already exists: ${existing.id}',
        errorCode: 'NEGOTIATION_EXISTS',
      );
    }

    final app = _store.findWhere<Application>(
      'applications',
      (a) => a.id == applicationId,
    );
    if (app == null && applicationId != MockIds.application1) {
      throw NotFoundFailure('Application not found: $applicationId');
    }
    if (app != null &&
        app.status != 'shortlisted' &&
        app.status != 'submitted') {
      throw ConflictFailure(
        'Cannot open negotiation for application status ${app.status}',
      );
    }

    final useStable = applicationId == MockIds.application1 &&
        _find(MockIds.negotiation1) == null;

    final offer = _offerFromBody(body, round: 1, offeredBy: 'brand');
    final negotiation = Negotiation(
      id: useStable
          ? MockIds.negotiation1
          : 'neg-mock-${DateTime.now().microsecondsSinceEpoch}',
      applicationId: applicationId,
      status: 'open',
      roundCount: 1,
      offers: [offer],
    );
    _store.add('negotiations', negotiation);

    // Shortlist application if still submitted.
    if (app != null && app.status == 'submitted') {
      _store.replaceWhere<Application>(
        'applications',
        (a) => a.id == app.id,
        Application(
          id: app.id,
          campaignId: app.campaignId,
          influencerProfileId: app.influencerProfileId,
          origin: app.origin,
          status: 'shortlisted',
          pitch: app.pitch,
          proposedCollabType: app.proposedCollabType,
          rejectionReason: app.rejectionReason,
          createdAt: app.createdAt,
        ),
      );
    }

    return negotiation;
  }

  @override
  Future<Negotiation> get(String id) async {
    await _store.delay();
    _ensureFixtures();
    final n = _find(id);
    if (n == null) {
      throw NotFoundFailure('Negotiation not found: $id');
    }
    return n;
  }

  @override
  Future<Negotiation> counter({
    required String negotiationId,
    required Map<String, dynamic> body,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final n = _find(negotiationId);
    if (n == null) {
      throw NotFoundFailure('Negotiation not found: $negotiationId');
    }
    if (!n.isOpen) {
      throw const ConflictFailure('Negotiation is locked');
    }
    if (!n.canCounter) {
      throw const ConflictFailure(
        'Maximum negotiation rounds reached',
        errorCode: 'MAX_ROUNDS',
      );
    }

    final offeredBy = (body['offeredBy'] as String?) ??
        (n.pendingOffer?.isBrand == true ? 'influencer' : 'brand');
    final nextRound = n.roundCount + 1;
    final offers = _supersedePending(n.offers);
    offers.add(_offerFromBody(body, round: nextRound, offeredBy: offeredBy));

    return _replace(
      Negotiation(
        id: n.id,
        applicationId: n.applicationId,
        status: 'open',
        roundCount: nextRound,
        maxRounds: n.maxRounds,
        offers: offers,
      ),
    );
  }

  @override
  Future<AcceptNegotiationResult> accept({
    required String negotiationId,
    required String offerId,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final n = _find(negotiationId);
    if (n == null) {
      throw NotFoundFailure('Negotiation not found: $negotiationId');
    }
    if (!n.isOpen) {
      throw const ConflictFailure('Negotiation is not open');
    }

    NegotiationOffer? target;
    for (final o in n.offers) {
      if (o.id == offerId) target = o;
    }
    if (target == null) {
      throw NotFoundFailure('Offer not found: $offerId');
    }
    if (!target.isPending) {
      throw const ConflictFailure('Offer is not pending');
    }

    final updatedOffers = n.offers
        .map(
          (o) => NegotiationOffer(
            id: o.id,
            round: o.round,
            offeredBy: o.offeredBy,
            collabType: o.collabType,
            agreedPriceMinor: o.agreedPriceMinor,
            currency: o.currency,
            status: o.id == offerId
                ? 'accepted'
                : (o.isPending ? 'superseded' : o.status),
            priceLines: o.priceLines,
            barterProductDescription: o.barterProductDescription,
            barterDeclaredValueMinor: o.barterDeclaredValueMinor,
            message: o.message,
          ),
        )
        .toList();

    _replace(
      Negotiation(
        id: n.id,
        applicationId: n.applicationId,
        status: 'accepted',
        roundCount: n.roundCount,
        maxRounds: n.maxRounds,
        offers: updatedOffers,
      ),
    );

    final useStableCollab = negotiationId == MockIds.negotiation1;
    final collabId = useStableCollab
        ? MockIds.collab1
        : 'collab-mock-${DateTime.now().microsecondsSinceEpoch}';

    final collab = CollaborationSnapshot(
      id: collabId,
      collabType: target.collabType,
      status: 'active',
      agreedPriceMinor: target.agreedPriceMinor,
      currency: target.currency,
      commissionPct: 15.0,
      barterDeclaredValueMinor: target.barterDeclaredValueMinor,
      barterProductDescription: target.barterProductDescription,
    );

    final existingCollab = _store.findWhere<CollaborationSnapshot>(
      'collaborations',
      (c) => c.id == collabId,
    );
    if (existingCollab == null) {
      _store.add('collaborations', collab);
    } else {
      _store.replaceWhere<CollaborationSnapshot>(
        'collaborations',
        (c) => c.id == collabId,
        collab,
      );
    }

    // Mark application converted.
    final app = _store.findWhere<Application>(
      'applications',
      (a) => a.id == n.applicationId,
    );
    if (app != null) {
      _store.replaceWhere<Application>(
        'applications',
        (a) => a.id == app.id,
        Application(
          id: app.id,
          campaignId: app.campaignId,
          influencerProfileId: app.influencerProfileId,
          origin: app.origin,
          status: 'converted',
          pitch: app.pitch,
          proposedCollabType: app.proposedCollabType,
          rejectionReason: app.rejectionReason,
          createdAt: app.createdAt,
        ),
      );
    }

    return AcceptNegotiationResult(
      negotiationId: n.id,
      status: 'accepted',
      collaboration: collab,
    );
  }

  @override
  Future<Negotiation> decline({
    required String negotiationId,
    required String offerId,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final n = _find(negotiationId);
    if (n == null) {
      throw NotFoundFailure('Negotiation not found: $negotiationId');
    }
    if (!n.isOpen) {
      throw const ConflictFailure('Negotiation is not open');
    }

    final hasOffer = n.offers.any((o) => o.id == offerId);
    if (!hasOffer) {
      throw NotFoundFailure('Offer not found: $offerId');
    }

    final offers = n.offers
        .map(
          (o) => NegotiationOffer(
            id: o.id,
            round: o.round,
            offeredBy: o.offeredBy,
            collabType: o.collabType,
            agreedPriceMinor: o.agreedPriceMinor,
            currency: o.currency,
            status: o.id == offerId
                ? 'declined'
                : (o.isPending ? 'superseded' : o.status),
            priceLines: o.priceLines,
            barterProductDescription: o.barterProductDescription,
            barterDeclaredValueMinor: o.barterDeclaredValueMinor,
            message: o.message,
          ),
        )
        .toList();

    return _replace(
      Negotiation(
        id: n.id,
        applicationId: n.applicationId,
        status: 'declined',
        roundCount: n.roundCount,
        maxRounds: n.maxRounds,
        offers: offers,
      ),
    );
  }

  @override
  Future<Negotiation> cancel(String negotiationId) async {
    await _store.delay();
    _ensureFixtures();

    final n = _find(negotiationId);
    if (n == null) {
      throw NotFoundFailure('Negotiation not found: $negotiationId');
    }
    if (!n.isOpen) {
      throw const ConflictFailure('Negotiation is already locked');
    }

    final offers = _supersedePending(n.offers);
    return _replace(
      Negotiation(
        id: n.id,
        applicationId: n.applicationId,
        status: 'cancelled',
        roundCount: n.roundCount,
        maxRounds: n.maxRounds,
        offers: offers,
      ),
    );
  }
}
