import '../../../features/disputes/domain/entities/data_erasure_request.dart';
import '../../../features/disputes/domain/entities/dispute.dart';
import '../../../features/disputes/domain/repositories/dispute_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [DisputeRepository].
class MockDisputeRepository implements DisputeRepository {
  MockDisputeRepository(this.store);

  final MockSeedStore store;

  static const _disputesKey = 'disputes';
  static const _erasureKey = 'erasure_requests';

  void _ensureSeeded() {
    if (store.list<Dispute>(_disputesKey).isNotEmpty) return;
    final now = DateTime.now();
    store.putAll(_disputesKey, [
      Dispute(
        id: MockIds.dispute1,
        collaborationId: MockIds.collab1,
        raisedBy: MockIds.brand1,
        reason: 'content_quality',
        description:
            'Deliverable did not match approved brief tone and product placement.',
        status: 'open',
        paymentId: MockIds.payment1,
        evidenceUrls: const [
          'https://cdn.monk.local/evidence/dispute1-frame.png',
        ],
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
      ),
      Dispute(
        id: 'dispute-demo-2',
        collaborationId: MockIds.collab1,
        raisedBy: MockIds.creator1,
        reason: 'payment_delay',
        description: 'Release delayed past agreed SLA after publish confirm.',
        status: 'under_review',
        paymentId: MockIds.payment1,
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        adminNotes: 'Escalated to payments ops.',
      ),
    ]);

    store.putAll(_erasureKey, [
      DataErasureRequest(
        id: 'erasure-demo-1',
        userId: MockIds.creatorFresh,
        status: 'pending',
        reason: 'Closing personal brand account.',
        userEmail: MockIds.emailCreatorFresh,
        requestedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
      ),
    ]);
  }

  @override
  Future<List<Dispute>> getDisputes({String? collaborationId}) async {
    await store.delay();
    _ensureSeeded();
    final all = store.list<Dispute>(_disputesKey);
    if (collaborationId == null || collaborationId.isEmpty) return all;
    return all.where((d) => d.collaborationId == collaborationId).toList();
  }

  @override
  Future<Dispute> getDispute(String id) async {
    await store.delay();
    _ensureSeeded();
    final dispute =
        store.findWhere<Dispute>(_disputesKey, (d) => d.id == id);
    if (dispute == null) {
      throw NotFoundFailure('Dispute not found: $id');
    }
    return dispute;
  }

  @override
  Future<Dispute> fileDispute({
    required String collaborationId,
    required String reason,
    required String description,
    String? paymentId,
    List<String> evidenceUrls = const [],
  }) async {
    await store.delay();
    _ensureSeeded();
    if (collaborationId.isEmpty) {
      throw const ValidationFailure('collaborationId is required.');
    }
    if (reason.trim().isEmpty || description.trim().isEmpty) {
      throw const ValidationFailure('reason and description are required.');
    }
    final dispute = Dispute(
      id: 'dispute-mock-${DateTime.now().millisecondsSinceEpoch}',
      collaborationId: collaborationId,
      raisedBy: store.currentUserId ?? MockIds.brand1,
      reason: reason,
      description: description,
      status: 'open',
      paymentId: paymentId,
      evidenceUrls: evidenceUrls,
      createdAt: DateTime.now().toIso8601String(),
    );
    store.add(_disputesKey, dispute);
    return dispute;
  }

  @override
  Future<List<Dispute>> getAdminDisputes() async {
    await store.delay();
    _ensureSeeded();
    return store.list<Dispute>(_disputesKey);
  }

  @override
  Future<Dispute> resolveDispute({
    required String disputeId,
    required String resolution,
    String? notes,
  }) async {
    await store.delay();
    _ensureSeeded();
    final allowed = {'resolved_refund', 'resolved_release', 'closed'};
    if (!allowed.contains(resolution)) {
      throw ValidationFailure(
        'Invalid resolution "$resolution". '
        'Allowed: resolved_refund, resolved_release, closed',
      );
    }
    final existing =
        store.findWhere<Dispute>(_disputesKey, (d) => d.id == disputeId);
    if (existing == null) {
      throw NotFoundFailure('Dispute not found: $disputeId');
    }
    if (existing.isResolved) {
      throw const ConflictFailure('Dispute is already resolved.');
    }
    final updated = Dispute(
      id: existing.id,
      collaborationId: existing.collaborationId,
      raisedBy: existing.raisedBy,
      reason: existing.reason,
      description: existing.description,
      status: resolution,
      paymentId: existing.paymentId,
      evidenceUrls: existing.evidenceUrls,
      adminNotes: notes ?? existing.adminNotes,
      createdAt: existing.createdAt,
      resolvedAt: DateTime.now().toIso8601String(),
    );
    store.replaceWhere<Dispute>(
      _disputesKey,
      (d) => d.id == disputeId,
      updated,
    );
    return updated;
  }

  @override
  Future<List<DataErasureRequest>> getDataErasureRequests() async {
    await store.delay();
    _ensureSeeded();
    return store.list<DataErasureRequest>(_erasureKey);
  }

  @override
  Future<DataErasureRequest> submitDataErasureRequest(String reason) async {
    await store.delay();
    _ensureSeeded();
    if (reason.trim().isEmpty) {
      throw const ValidationFailure('Reason is required for data erasure.');
    }
    final userId = store.currentUserId ?? MockIds.creator1;
    final account = store.findAccountById(userId);
    final request = DataErasureRequest(
      id: 'erasure-mock-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      status: 'pending',
      reason: reason,
      userEmail: account?.user.email,
      requestedAt: DateTime.now().toIso8601String(),
    );
    store.add(_erasureKey, request);
    return request;
  }
}
