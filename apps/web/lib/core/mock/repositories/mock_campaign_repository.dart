import '../../../features/campaigns/domain/entities/campaign.dart';
import '../../../features/campaigns/domain/repositories/campaign_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// In-memory [CampaignRepository].
///
/// Store keys:
/// - `campaigns` → `List<Campaign>`
/// - singles `campaign_deliverables` → `Map<String, List<Deliverable>>` (campaignId → dels)
class MockCampaignRepository implements CampaignRepository {
  MockCampaignRepository(this._store);

  final MockSeedStore _store;

  Map<String, List<Deliverable>> _deliverablesMap() {
    final raw = _store.singles['campaign_deliverables'];
    if (raw is Map<String, List<Deliverable>>) return raw;
    if (raw is Map) {
      final converted = <String, List<Deliverable>>{};
      raw.forEach((k, v) {
        if (v is List<Deliverable>) {
          converted[k.toString()] = v;
        } else if (v is List) {
          converted[k.toString()] = v.whereType<Deliverable>().toList();
        }
      });
      _store.singles['campaign_deliverables'] = converted;
      return converted;
    }
    final map = <String, List<Deliverable>>{};
    _store.singles['campaign_deliverables'] = map;
    return map;
  }

  List<Deliverable> _delsFor(String campaignId) =>
      List<Deliverable>.from(_deliverablesMap()[campaignId] ?? const []);

  Campaign _withCount(Campaign c, int count) => Campaign(
        id: c.id,
        brandId: c.brandId,
        name: c.name,
        code: c.code,
        status: c.status,
        mode: c.mode,
        objective: c.objective,
        currency: c.currency,
        budgetTotalMinor: c.budgetTotalMinor,
        deliverableCount: count,
      );

  Campaign _withStatus(Campaign c, String status) => Campaign(
        id: c.id,
        brandId: c.brandId,
        name: c.name,
        code: c.code,
        status: status,
        mode: c.mode,
        objective: c.objective,
        currency: c.currency,
        budgetTotalMinor: c.budgetTotalMinor,
        deliverableCount: c.deliverableCount,
      );

  void _ensureFixtures() {
    if (_store.list<Campaign>('campaigns').isNotEmpty) return;

    final open = Campaign(
      id: MockIds.campaign1,
      brandId: MockIds.brandOrg1,
      name: 'Summer Glow Launch',
      code: 'SGL-001',
      status: 'applications_open',
      mode: 'self_serve',
      objective: 'awareness',
      currency: 'INR',
      budgetTotalMinor: 50000000,
      deliverableCount: 1,
    );
    final draft = Campaign(
      id: MockIds.campaignDraft,
      brandId: MockIds.brandOrg1,
      name: 'Draft Promo',
      code: 'DRF-001',
      status: 'draft',
      mode: 'self_serve',
      objective: 'engagement',
      currency: 'INR',
      budgetTotalMinor: 10000000,
      deliverableCount: 0,
    );
    final done = Campaign(
      id: MockIds.campaignDone,
      brandId: MockIds.brandOrg1,
      name: 'Winter Wrap-Up',
      code: 'WWU-001',
      status: 'completed',
      mode: 'self_serve',
      objective: 'conversion',
      currency: 'INR',
      budgetTotalMinor: 25000000,
      deliverableCount: 2,
    );
    final inProg = Campaign(
      id: MockIds.campaign2,
      brandId: MockIds.brandOrg1,
      name: 'Collab In Progress',
      code: 'CIP-001',
      status: 'in_progress',
      mode: 'self_serve',
      objective: 'consideration',
      currency: 'INR',
      budgetTotalMinor: 30000000,
      deliverableCount: 1,
    );

    _store.putAll('campaigns', [open, draft, done, inProg]);

    final dels = _deliverablesMap();
    dels[MockIds.campaign1] = [
      const Deliverable(
        id: 'del-demo-1',
        platform: 'instagram',
        deliverableType: 'instagram_reel',
        disclosureTags: ['#ad', '#sponsored'],
        captionGuidelines: 'Mention product benefits naturally.',
      ),
    ];
    dels[MockIds.campaign2] = [
      const Deliverable(
        id: 'del-demo-2',
        platform: 'youtube',
        deliverableType: 'youtube_short',
        disclosureTags: ['#ad'],
      ),
    ];
    dels[MockIds.campaignDone] = [
      const Deliverable(
        id: 'del-demo-3',
        platform: 'instagram',
        deliverableType: 'instagram_post',
      ),
      const Deliverable(
        id: 'del-demo-4',
        platform: 'instagram',
        deliverableType: 'instagram_story',
      ),
    ];
  }

  @override
  Future<List<Campaign>> list(String brandId) async {
    await _store.delay();
    _ensureFixtures();
    return _store
        .list<Campaign>('campaigns')
        .where((c) => c.brandId == brandId)
        .map((c) => _withCount(c, _delsFor(c.id).length))
        .toList();
  }

  @override
  Future<Campaign> create(Map<String, dynamic> body) async {
    await _store.delay();
    _ensureFixtures();

    final name = (body['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      throw const ValidationFailure('Campaign name is required');
    }

    final brandId =
        (body['brandId'] as String?)?.trim() ?? MockIds.brandOrg1;
    final mode = (body['mode'] as String?)?.trim() ?? 'self_serve';
    if (!campaignModes.contains(mode)) {
      throw ValidationFailure('Invalid campaign mode: $mode');
    }

    final id = 'camp-mock-${DateTime.now().microsecondsSinceEpoch}';
    final code = (body['code'] as String?)?.trim().isNotEmpty == true
        ? body['code'] as String
        : 'CMP-${id.substring(id.length - 6).toUpperCase()}';

    final campaign = Campaign(
      id: id,
      brandId: brandId,
      name: name,
      code: code,
      status: 'draft',
      mode: mode,
      objective: body['objective'] as String?,
      currency: (body['currency'] as String?) ?? 'INR',
      budgetTotalMinor: body['budgetTotalMinor'] is int
          ? body['budgetTotalMinor'] as int
          : body['budgetTotalMinor'] is num
              ? (body['budgetTotalMinor'] as num).toInt()
              : null,
      deliverableCount: 0,
    );
    _store.add('campaigns', campaign);
    _deliverablesMap().putIfAbsent(id, () => <Deliverable>[]);
    return campaign;
  }

  @override
  Future<CampaignDetail> get(String id) async {
    await _store.delay();
    _ensureFixtures();

    final campaign = _store.findWhere<Campaign>('campaigns', (c) => c.id == id);
    if (campaign == null) {
      throw NotFoundFailure('Campaign not found: $id');
    }
    final dels = _delsFor(id);
    return CampaignDetail(
      campaign: _withCount(campaign, dels.length),
      deliverables: dels,
    );
  }

  @override
  Future<Campaign> transition(
    String id, {
    required String to,
    String? reason,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final campaign = _store.findWhere<Campaign>('campaigns', (c) => c.id == id);
    if (campaign == null) {
      throw NotFoundFailure('Campaign not found: $id');
    }

    final dels = _delsFor(id);
    final allowed = allowedBrandTransitions(
      status: campaign.status,
      mode: campaign.mode,
      deliverableCount: dels.length,
    );
    if (!allowed.contains(to)) {
      throw ConflictFailure(
        'Cannot transition campaign from ${campaign.status} to $to',
        errorCode: 'ILLEGAL_TRANSITION',
      );
    }

    final updated = _withCount(_withStatus(campaign, to), dels.length);
    _store.replaceWhere<Campaign>('campaigns', (c) => c.id == id, updated);
    return updated;
  }

  @override
  Future<Deliverable> addDeliverable(
    String campaignId,
    Map<String, dynamic> body,
  ) async {
    await _store.delay();
    _ensureFixtures();

    final campaign =
        _store.findWhere<Campaign>('campaigns', (c) => c.id == campaignId);
    if (campaign == null) {
      throw NotFoundFailure('Campaign not found: $campaignId');
    }
    if (campaign.status != 'draft' && campaign.status != 'brief_submitted') {
      throw const ConflictFailure(
        'Deliverables can only be added while campaign is draft',
        errorCode: 'CAMPAIGN_LOCKED',
      );
    }

    final platform = (body['platform'] as String?)?.trim() ?? '';
    final type = (body['deliverableType'] as String?)?.trim() ?? '';
    if (platform.isEmpty || type.isEmpty) {
      throw const ValidationFailure('platform and deliverableType are required');
    }

    final del = Deliverable(
      id: 'del-mock-${DateTime.now().microsecondsSinceEpoch}',
      platform: platform,
      deliverableType: type,
      disclosureTags: (body['disclosureTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      captionGuidelines: body['captionGuidelines'] as String?,
    );

    final map = _deliverablesMap();
    final list = List<Deliverable>.from(map[campaignId] ?? const []);
    list.add(del);
    map[campaignId] = list;

    final updated = _withCount(campaign, list.length);
    _store.replaceWhere<Campaign>(
      'campaigns',
      (c) => c.id == campaignId,
      updated,
    );
    return del;
  }

  @override
  Future<void> deleteDeliverable(
    String campaignId,
    String deliverableId,
  ) async {
    await _store.delay();
    _ensureFixtures();

    final campaign =
        _store.findWhere<Campaign>('campaigns', (c) => c.id == campaignId);
    if (campaign == null) {
      throw NotFoundFailure('Campaign not found: $campaignId');
    }

    final map = _deliverablesMap();
    final list = List<Deliverable>.from(map[campaignId] ?? const []);
    final before = list.length;
    list.removeWhere((d) => d.id == deliverableId);
    if (list.length == before) {
      throw NotFoundFailure('Deliverable not found: $deliverableId');
    }
    map[campaignId] = list;

    final updated = _withCount(campaign, list.length);
    _store.replaceWhere<Campaign>(
      'campaigns',
      (c) => c.id == campaignId,
      updated,
    );
  }
}
