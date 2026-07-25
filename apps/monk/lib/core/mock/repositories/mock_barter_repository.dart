import '../../../features/barter/domain/entities/barter.dart';
import '../../../features/barter/domain/repositories/barter_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [BarterRepository].
class MockBarterRepository implements BarterRepository {
  MockBarterRepository(this.store);

  final MockSeedStore store;

  static const _key = 'barters';

  void _ensureSeeded() {
    if (store.list<BarterStatus>(_key).isNotEmpty) return;
    store.putAll(_key, [
      BarterStatus(
        collaborationId: MockIds.collab1,
        collabType: 'barter',
        collabStatus: 'terms_accepted',
        requiresFulfillment: true,
        skipsProductStates: false,
        returnsSupported: false,
        fulfillment: BarterFulfillment(
          id: 'barter-ful-demo-1',
          collaborationId: MockIds.collab1,
          productDescription: 'Summer skincare sample kit (serum + cleanser)',
          status: 'pending_shipment',
          declaredValueMinor: 450000,
          notes: 'Ship within 3 business days of terms accept.',
        ),
      ),
    ]);
  }

  BarterStatus _require(String collaborationId) {
    final status = store.findWhere<BarterStatus>(
      _key,
      (s) => s.collaborationId == collaborationId,
    );
    if (status == null) {
      // Auto-create a pending barter path for unknown collabs so demo stays usable.
      final created = BarterStatus(
        collaborationId: collaborationId,
        collabType: 'barter',
        collabStatus: 'terms_accepted',
        requiresFulfillment: true,
        skipsProductStates: false,
        returnsSupported: false,
        fulfillment: BarterFulfillment(
          id: 'barter-ful-$collaborationId',
          collaborationId: collaborationId,
          productDescription: 'Demo product package',
          status: 'pending_shipment',
          declaredValueMinor: 100000,
        ),
      );
      store.add(_key, created);
      return created;
    }
    return status;
  }

  void _save(BarterStatus status) {
    store.replaceWhere<BarterStatus>(
      _key,
      (s) => s.collaborationId == status.collaborationId,
      status,
    );
  }

  @override
  Future<BarterStatus> get(String collaborationId) async {
    await store.delay();
    _ensureSeeded();
    return _require(collaborationId);
  }

  @override
  Future<BarterStatus> ship({
    required String collaborationId,
    required String trackingRef,
    String? shippingCarrier,
    String? notes,
    List<String>? evidenceFileIds,
  }) async {
    await store.delay();
    _ensureSeeded();
    if (trackingRef.trim().isEmpty) {
      throw const ValidationFailure('Tracking reference is required to ship.');
    }
    final current = _require(collaborationId);
    final ful = current.fulfillment;
    if (ful == null) {
      throw const ConflictFailure('No fulfillment record for this collaboration.');
    }
    final now = DateTime.now().toIso8601String();
    final updatedFul = BarterFulfillment(
      id: ful.id,
      collaborationId: ful.collaborationId,
      productDescription: ful.productDescription,
      status: 'shipped',
      declaredValueMinor: ful.declaredValueMinor,
      shippingCarrier: shippingCarrier ?? ful.shippingCarrier ?? 'DemoExpress',
      trackingRef: trackingRef,
      shippedAt: now,
      receivedConfirmedAt: ful.receivedConfirmedAt,
      evidenceFileIds: [
        ...ful.evidenceFileIds,
        ...?evidenceFileIds,
      ],
      notes: notes ?? ful.notes,
    );
    final updated = BarterStatus(
      collaborationId: current.collaborationId,
      collabType: current.collabType,
      collabStatus: 'product_shipped',
      requiresFulfillment: current.requiresFulfillment,
      skipsProductStates: current.skipsProductStates,
      returnsSupported: current.returnsSupported,
      fulfillment: updatedFul,
    );
    _save(updated);
    return updated;
  }

  @override
  Future<BarterStatus> receive({
    required String collaborationId,
    String? notes,
    List<String>? evidenceFileIds,
  }) async {
    await store.delay();
    _ensureSeeded();
    final current = _require(collaborationId);
    final ful = current.fulfillment;
    if (ful == null || !ful.isShipped) {
      throw const ConflictFailure(
        'Product must be shipped before it can be marked received.',
      );
    }
    final now = DateTime.now().toIso8601String();
    final updatedFul = BarterFulfillment(
      id: ful.id,
      collaborationId: ful.collaborationId,
      productDescription: ful.productDescription,
      status: 'received',
      declaredValueMinor: ful.declaredValueMinor,
      shippingCarrier: ful.shippingCarrier,
      trackingRef: ful.trackingRef,
      shippedAt: ful.shippedAt,
      receivedConfirmedAt: now,
      evidenceFileIds: [
        ...ful.evidenceFileIds,
        ...?evidenceFileIds,
      ],
      notes: notes ?? ful.notes,
    );
    final updated = BarterStatus(
      collaborationId: current.collaborationId,
      collabType: current.collabType,
      collabStatus: 'product_received',
      requiresFulfillment: current.requiresFulfillment,
      skipsProductStates: current.skipsProductStates,
      returnsSupported: current.returnsSupported,
      fulfillment: updatedFul,
    );
    _save(updated);
    return updated;
  }

  @override
  Future<BarterStatus> addEvidence({
    required String collaborationId,
    required List<String> fileIds,
  }) async {
    await store.delay();
    _ensureSeeded();
    if (fileIds.isEmpty) {
      throw const ValidationFailure('At least one evidence file id is required.');
    }
    final current = _require(collaborationId);
    final ful = current.fulfillment;
    if (ful == null) {
      throw const ConflictFailure('No fulfillment record for this collaboration.');
    }
    final updatedFul = BarterFulfillment(
      id: ful.id,
      collaborationId: ful.collaborationId,
      productDescription: ful.productDescription,
      status: ful.status,
      declaredValueMinor: ful.declaredValueMinor,
      shippingCarrier: ful.shippingCarrier,
      trackingRef: ful.trackingRef,
      shippedAt: ful.shippedAt,
      receivedConfirmedAt: ful.receivedConfirmedAt,
      evidenceFileIds: [...ful.evidenceFileIds, ...fileIds],
      notes: ful.notes,
    );
    final updated = BarterStatus(
      collaborationId: current.collaborationId,
      collabType: current.collabType,
      collabStatus: current.collabStatus,
      requiresFulfillment: current.requiresFulfillment,
      skipsProductStates: current.skipsProductStates,
      returnsSupported: current.returnsSupported,
      fulfillment: updatedFul,
    );
    _save(updated);
    return updated;
  }

  @override
  Future<BarterStatus> openContent(String collaborationId) async {
    await store.delay();
    _ensureSeeded();
    final current = _require(collaborationId);
    if (current.requiresFulfillment) {
      final ful = current.fulfillment;
      if (ful == null || !ful.isReceived) {
        throw const ConflictFailure(
          'Content submission is locked until the product is marked received.',
        );
      }
    }
    final updated = BarterStatus(
      collaborationId: current.collaborationId,
      collabType: current.collabType,
      collabStatus: 'content_pending',
      requiresFulfillment: current.requiresFulfillment,
      skipsProductStates: current.skipsProductStates,
      returnsSupported: current.returnsSupported,
      fulfillment: current.fulfillment,
    );
    _save(updated);
    return updated;
  }
}
