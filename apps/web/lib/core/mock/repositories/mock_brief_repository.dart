import '../../../features/briefs/domain/entities/brief.dart';
import '../../../features/briefs/domain/repositories/brief_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [BriefRepository].
class MockBriefRepository implements BriefRepository {
  MockBriefRepository(this.store);

  final MockSeedStore store;

  static const _key = 'briefs';

  void _ensureSeeded() {
    if (store.list<Brief>(_key).isNotEmpty) return;
    store.putAll(_key, [
      Brief(
        id: MockIds.brief1,
        brandId: MockIds.brandOrg1,
        goals: 'Launch summer skincare awareness with authentic UGC reels.',
        status: 'submitted',
        budgetMinor: 250000,
        currency: 'INR',
        productDescription: 'Glow serum starter kit',
        notes: 'Prefer micro-creators in beauty vertical.',
        managedFeeMode: 'none',
      ),
      Brief(
        id: 'brief-demo-2',
        brandId: MockIds.brandOrg1,
        goals: 'Hybrid barter collab for fitness accessories unboxing.',
        status: 'triaged',
        budgetMinor: 150000,
        currency: 'INR',
        productDescription: 'Resistance band set',
        notes: 'Agency triaged — matching in progress.',
        managedFeeMode: 'pct',
        agencyFeeMinor: 15000,
      ),
      Brief(
        id: 'brief-demo-3',
        brandId: MockIds.brandOrg2,
        goals: 'Convert managed brief into campaign for festive drop.',
        status: 'in_build',
        budgetMinor: 500000,
        currency: 'INR',
        productDescription: 'Festive apparel sample pack',
        managedFeeMode: 'flat',
        agencyFeeMinor: 50000,
      ),
    ]);
  }

  @override
  Future<SubmitBriefResult> submit(Map<String, dynamic> body) async {
    await store.delay();
    _ensureSeeded();
    final goals = (body['goals'] as String?)?.trim() ?? '';
    if (goals.isEmpty) {
      throw const ValidationFailure('Brief goals are required.');
    }
    final brandId = body['brandId'] as String? ??
        store.primaryBrandId;
    final budgetMinor = body['budgetMinor'] as int? ??
        (body['budget'] is num ? (body['budget'] as num).toInt() : null);
    final brief = Brief(
      id: 'brief-mock-${DateTime.now().millisecondsSinceEpoch}',
      brandId: brandId,
      goals: goals,
      status: 'submitted',
      budgetMinor: budgetMinor,
      currency: body['currency'] as String? ?? 'INR',
      productDescription: body['productDescription'] as String?,
      notes: body['notes'] as String?,
      managedFeeMode: body['managedFeeMode'] as String? ?? 'none',
      agencyFeeMinor: body['agencyFeeMinor'] as int?,
    );
    store.add(_key, brief);
    return SubmitBriefResult(
      brief: brief,
      managedFeeMode: brief.managedFeeMode,
      agencyFeeMinor: brief.agencyFeeMinor,
    );
  }

  @override
  Future<List<Brief>> listMine() async {
    await store.delay();
    _ensureSeeded();
    final brandId = store.primaryBrandId;
    return store
        .list<Brief>(_key)
        .where((b) => b.brandId == brandId)
        .toList();
  }

  @override
  Future<List<Brief>> agencyList({String? status}) async {
    await store.delay();
    _ensureSeeded();
    final all = store.list<Brief>(_key);
    if (status == null || status.isEmpty) return all;
    return all.where((b) => b.status == status).toList();
  }

  @override
  Future<Brief> triage(String id, {String? notes}) async {
    await store.delay();
    _ensureSeeded();
    final existing = store.findWhere<Brief>(_key, (b) => b.id == id);
    if (existing == null) {
      throw NotFoundFailure('Brief not found: $id');
    }
    final updated = Brief(
      id: existing.id,
      brandId: existing.brandId,
      campaignId: existing.campaignId,
      goals: existing.goals,
      status: 'triaged',
      budgetMinor: existing.budgetMinor,
      currency: existing.currency,
      productDescription: existing.productDescription,
      notes: notes ?? existing.notes,
      managedFeeMode: existing.managedFeeMode,
      agencyFeeMinor: existing.agencyFeeMinor,
    );
    store.replaceWhere<Brief>(_key, (b) => b.id == id, updated);
    return updated;
  }

  @override
  Future<SubmitBriefResult> convert(String id) async {
    await store.delay();
    _ensureSeeded();
    final existing = store.findWhere<Brief>(_key, (b) => b.id == id);
    if (existing == null) {
      throw NotFoundFailure('Brief not found: $id');
    }
    if (existing.status == 'converted') {
      throw const ConflictFailure('Brief already converted to a campaign.');
    }
    final campaignId =
        existing.campaignId ?? 'camp-from-brief-${existing.id}';
    final updated = Brief(
      id: existing.id,
      brandId: existing.brandId,
      campaignId: campaignId,
      goals: existing.goals,
      status: 'converted',
      budgetMinor: existing.budgetMinor,
      currency: existing.currency,
      productDescription: existing.productDescription,
      notes: existing.notes,
      managedFeeMode: existing.managedFeeMode,
      agencyFeeMinor: existing.agencyFeeMinor,
    );
    store.replaceWhere<Brief>(_key, (b) => b.id == id, updated);
    return SubmitBriefResult(
      brief: updated,
      campaignId: campaignId,
      managedFeeMode: updated.managedFeeMode,
      agencyFeeMinor: updated.agencyFeeMinor,
    );
  }

  @override
  Future<void> assignInfluencers({
    required String campaignId,
    required List<String> profileIds,
  }) async {
    await store.delay();
    if (campaignId.isEmpty) {
      throw const ValidationFailure('campaignId is required.');
    }
    if (profileIds.isEmpty) {
      throw const ValidationFailure('At least one profileId is required.');
    }
    // Demo: record assignment side-effect for inspection.
    store.add(
      'brief_assignments',
      {
        'campaignId': campaignId,
        'profileIds': List<String>.from(profileIds),
        'assignedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
