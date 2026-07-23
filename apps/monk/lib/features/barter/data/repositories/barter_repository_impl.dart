import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/barter.dart';
import '../../domain/repositories/barter_repository.dart';

class BarterRepositoryImpl implements BarterRepository {
  BarterRepositoryImpl(this._client);
  final MonkApiClient _client;

  BarterFulfillment? _mapFulfillment(BarterFulfillmentDto? d) {
    if (d == null) return null;
    return BarterFulfillment(
      id: d.id,
      collaborationId: d.collaborationId,
      productDescription: d.productDescription,
      status: d.status,
      declaredValueMinor: d.declaredValueMinor,
      shippingCarrier: d.shippingCarrier,
      trackingRef: d.trackingRef,
      shippedAt: d.shippedAt,
      receivedConfirmedAt: d.receivedConfirmedAt,
      evidenceFileIds: d.evidenceFileIds,
      notes: d.notes,
    );
  }

  BarterStatus _map(BarterStatusDto d) => BarterStatus(
        collaborationId: d.collaborationId,
        collabType: d.collabType,
        collabStatus: d.collabStatus,
        requiresFulfillment: d.requiresFulfillment,
        skipsProductStates: d.skipsProductStates,
        returnsSupported: d.returnsSupported,
        fulfillment: _mapFulfillment(d.fulfillment),
      );

  @override
  Future<BarterStatus> get(String collaborationId) async {
    try {
      return _map(await _client.barter.get(collaborationId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<BarterStatus> ship({
    required String collaborationId,
    required String trackingRef,
    String? shippingCarrier,
    String? notes,
    List<String>? evidenceFileIds,
  }) async {
    try {
      return _map(
        await _client.barter.ship(
          collaborationId,
          trackingRef: trackingRef,
          shippingCarrier: shippingCarrier,
          notes: notes,
          evidenceFileIds: evidenceFileIds,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<BarterStatus> receive({
    required String collaborationId,
    String? notes,
    List<String>? evidenceFileIds,
  }) async {
    try {
      return _map(
        await _client.barter.receive(
          collaborationId,
          notes: notes,
          evidenceFileIds: evidenceFileIds,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<BarterStatus> addEvidence({
    required String collaborationId,
    required List<String> fileIds,
  }) async {
    try {
      return _map(
        await _client.barter.addEvidence(
          collaborationId,
          fileIds: fileIds,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<BarterStatus> openContent(String collaborationId) async {
    try {
      return _map(await _client.barter.openContent(collaborationId));
    } catch (e) {
      throw mapError(e);
    }
  }
}
