import '../entities/negotiation.dart';

abstract class NegotiationRepository {
  Future<Negotiation> open({
    required String applicationId,
    required Map<String, dynamic> body,
  });

  Future<Negotiation> get(String id);

  Future<Negotiation> counter({
    required String negotiationId,
    required Map<String, dynamic> body,
  });

  Future<AcceptNegotiationResult> accept({
    required String negotiationId,
    required String offerId,
  });

  Future<Negotiation> decline({
    required String negotiationId,
    required String offerId,
  });

  Future<Negotiation> cancel(String negotiationId);
}
