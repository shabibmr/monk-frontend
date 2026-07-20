import '../entities/barter.dart';

abstract class BarterRepository {
  Future<BarterStatus> get(String collaborationId);

  Future<BarterStatus> ship({
    required String collaborationId,
    required String trackingRef,
    String? shippingCarrier,
    String? notes,
    List<String>? evidenceFileIds,
  });

  Future<BarterStatus> receive({
    required String collaborationId,
    String? notes,
    List<String>? evidenceFileIds,
  });

  Future<BarterStatus> addEvidence({
    required String collaborationId,
    required List<String> fileIds,
  });

  Future<BarterStatus> openContent(String collaborationId);
}
