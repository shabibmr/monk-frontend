import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/negotiation.dart';
import '../../domain/repositories/negotiation_repository.dart';

class NegotiationRepositoryImpl implements NegotiationRepository {
  NegotiationRepositoryImpl(this._client);
  final MonkApiClient _client;

  OfferPriceLine _mapLine(Map<String, dynamic> m) {
    final p = m['priceMinor'];
    return OfferPriceLine(
      deliverableId: m['deliverableId']?.toString() ?? '',
      priceMinor: p is int
          ? p
          : p is num
              ? p.toInt()
              : int.tryParse('$p') ?? 0,
    );
  }

  NegotiationOffer _mapOffer(NegotiationOfferDto d) => NegotiationOffer(
        id: d.id,
        round: d.round,
        offeredBy: d.offeredBy,
        collabType: d.collabType,
        agreedPriceMinor: d.agreedPriceMinor,
        currency: d.currency,
        status: d.status,
        priceLines: d.priceLines.map(_mapLine).toList(),
        barterProductDescription: d.barterProductDescription,
        barterDeclaredValueMinor: d.barterDeclaredValueMinor,
        message: d.message,
      );

  Negotiation _map(NegotiationDto d) => Negotiation(
        id: d.id,
        applicationId: d.applicationId,
        status: d.status,
        roundCount: d.roundCount,
        maxRounds: d.maxRounds,
        offers: d.offers.map(_mapOffer).toList(),
      );

  CollaborationSnapshot? _mapCollab(CollaborationSnapshotDto? d) {
    if (d == null) return null;
    return CollaborationSnapshot(
      id: d.id,
      collabType: d.collabType,
      status: d.status,
      agreedPriceMinor: d.agreedPriceMinor,
      currency: d.currency,
      commissionPct: d.commissionPct,
      barterDeclaredValueMinor: d.barterDeclaredValueMinor,
      barterProductDescription: d.barterProductDescription,
    );
  }

  @override
  Future<Negotiation> open({
    required String applicationId,
    required Map<String, dynamic> body,
  }) async {
    try {
      return _map(await _client.negotiations.open(applicationId, body));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Negotiation> get(String id) async {
    try {
      return _map(await _client.negotiations.get(id));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Negotiation> counter({
    required String negotiationId,
    required Map<String, dynamic> body,
  }) async {
    try {
      return _map(await _client.negotiations.counter(negotiationId, body));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<AcceptNegotiationResult> accept({
    required String negotiationId,
    required String offerId,
  }) async {
    try {
      final r = await _client.negotiations.accept(negotiationId, offerId);
      return AcceptNegotiationResult(
        negotiationId: r.negotiationId,
        status: r.status,
        collaboration: _mapCollab(r.collaboration),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Negotiation> decline({
    required String negotiationId,
    required String offerId,
  }) async {
    try {
      return _map(
        await _client.negotiations.decline(negotiationId, offerId),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Negotiation> cancel(String negotiationId) async {
    try {
      return _map(await _client.negotiations.cancel(negotiationId));
    } catch (e) {
      throw mapError(e);
    }
  }
}
