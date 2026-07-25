import '../../../features/campaigns/domain/entities/campaign.dart';
import '../../../features/marketplace/domain/entities/marketplace.dart';
import '../../../features/marketplace/domain/repositories/marketplace_repository.dart';
import '../../../features/onboarding_brand/domain/entities/brand.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// In-memory [MarketplaceRepository].
///
/// Store keys:
/// - `applications` → `List<Application>`
/// - `campaigns` → `List<Campaign>` (browse derives marketplace view)
/// - `marketplace_campaigns` → optional `List<MarketplaceCampaign>` override
/// - singles `campaign_deliverables` → `Map<String, List<Deliverable>>`
/// - `brands` → `List<Brand>` (for marketplace brand card)
class MockMarketplaceRepository implements MarketplaceRepository {
  MockMarketplaceRepository(this._store);

  final MockSeedStore _store;

  static const _browseable = {
    'published',
    'applications_open',
    'shortlisting',
    'in_progress',
  };

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

  void _ensureFixtures() {
    if (_store.list<MarketplaceCampaign>('marketplace_campaigns').isNotEmpty ||
        _store.list<Campaign>('campaigns').isNotEmpty) {
      if (_store.list<Application>('applications').isEmpty) {
        _store.add(
          'applications',
          Application(
            id: MockIds.application1,
            campaignId: MockIds.campaign1,
            influencerProfileId: MockIds.influencer1,
            origin: 'applied',
            status: 'submitted',
            pitch: 'Excited to collaborate on this launch!',
            proposedCollabType: 'paid',
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
      }
      return;
    }

    final brand = MarketplaceBrand(
      id: MockIds.brandOrg1,
      companyName: 'Demo Brand Co',
      country: 'IN',
      industry: 'Beauty',
    );
    final del = const MarketplaceDeliverable(
      id: 'del-demo-1',
      platform: 'instagram',
      deliverableType: 'instagram_reel',
      disclosureTags: ['#ad', '#sponsored'],
      captionGuidelines: 'Mention product benefits naturally.',
    );

    _store.putAll('marketplace_campaigns', [
      MarketplaceCampaign(
        id: MockIds.campaign1,
        name: 'Summer Glow Launch',
        code: 'SGL-001',
        status: 'applications_open',
        mode: 'self_serve',
        objective: 'awareness',
        currency: 'INR',
        budgetTotalMinor: 50000000,
        permittedCollabTypes: const ['paid', 'barter', 'hybrid'],
        brand: brand,
        deliverables: [del],
      ),
      MarketplaceCampaign(
        id: MockIds.campaign2,
        name: 'Collab In Progress',
        code: 'CIP-001',
        status: 'in_progress',
        mode: 'self_serve',
        objective: 'consideration',
        currency: 'INR',
        budgetTotalMinor: 30000000,
        permittedCollabTypes: const ['paid'],
        brand: brand,
        deliverables: const [
          MarketplaceDeliverable(
            id: 'del-demo-2',
            platform: 'youtube',
            deliverableType: 'youtube_short',
            disclosureTags: ['#ad'],
          ),
        ],
      ),
    ]);

    // Keep campaigns in sync for brand-side list / inbox filtering.
    _store.putAll('campaigns', [
      Campaign(
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
      ),
      Campaign(
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
      ),
    ]);

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

    _store.putAll('applications', [
      Application(
        id: MockIds.application1,
        campaignId: MockIds.campaign1,
        influencerProfileId: MockIds.influencer1,
        origin: 'applied',
        status: 'submitted',
        pitch: 'Excited to collaborate on this launch!',
        proposedCollabType: 'paid',
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    ]);
  }

  MarketplaceCampaign _fromCampaign(Campaign c) {
    final brand = _store.findWhere<Brand>('brands', (b) => b.id == c.brandId);
    final dels = _deliverablesMap()[c.id] ?? const <Deliverable>[];
    return MarketplaceCampaign(
      id: c.id,
      name: c.name,
      code: c.code,
      status: c.status,
      mode: c.mode,
      objective: c.objective,
      currency: c.currency,
      budgetTotalMinor: c.budgetTotalMinor,
      permittedCollabTypes: const ['paid', 'barter', 'hybrid'],
      brand: brand == null
          ? MarketplaceBrand(
              id: c.brandId,
              companyName: 'Demo Brand',
              country: 'IN',
            )
          : MarketplaceBrand(
              id: brand.id,
              companyName: brand.companyName,
              country: brand.country,
              industry: brand.industry,
            ),
      deliverables: dels
          .map(
            (d) => MarketplaceDeliverable(
              id: d.id,
              platform: d.platform,
              deliverableType: d.deliverableType,
              disclosureTags: d.disclosureTags,
              captionGuidelines: d.captionGuidelines,
            ),
          )
          .toList(),
    );
  }

  List<MarketplaceCampaign> _allMarketplace() {
    final direct = _store.list<MarketplaceCampaign>('marketplace_campaigns');
    if (direct.isNotEmpty) return direct;
    return _store
        .list<Campaign>('campaigns')
        .where((c) => _browseable.contains(c.status))
        .map(_fromCampaign)
        .toList();
  }

  MarketplaceCampaign? _lookupCampaign(String id) {
    final direct = _store.findWhere<MarketplaceCampaign>(
      'marketplace_campaigns',
      (c) => c.id == id,
    );
    if (direct != null) return direct;
    final campaign = _store.findWhere<Campaign>('campaigns', (c) => c.id == id);
    if (campaign != null) return _fromCampaign(campaign);
    return null;
  }

  Application? _app(String id) =>
      _store.findWhere<Application>('applications', (a) => a.id == id);

  Application _replaceApp(Application updated) {
    _store.replaceWhere<Application>(
      'applications',
      (a) => a.id == updated.id,
      updated,
    );
    return updated;
  }

  Application _copyApp(
    Application a, {
    String? status,
    String? rejectionReason,
    String? origin,
  }) =>
      Application(
        id: a.id,
        campaignId: a.campaignId,
        influencerProfileId: a.influencerProfileId,
        origin: origin ?? a.origin,
        status: status ?? a.status,
        pitch: a.pitch,
        proposedCollabType: a.proposedCollabType,
        rejectionReason: rejectionReason ?? a.rejectionReason,
        createdAt: a.createdAt,
      );

  @override
  Future<({List<MarketplaceCampaign> items, String? nextCursor})> browse({
    String? platform,
    String? objective,
    String? collabType,
    String? cursor,
  }) async {
    await _store.delay();
    _ensureFixtures();

    var items = _allMarketplace()
        .where((c) => _browseable.contains(c.status))
        .toList();

    if (objective != null && objective.isNotEmpty) {
      items = items.where((c) => c.objective == objective).toList();
    }
    if (collabType != null && collabType.isNotEmpty) {
      items = items
          .where((c) => c.permittedCollabTypes.contains(collabType))
          .toList();
    }
    if (platform != null && platform.isNotEmpty) {
      items = items
          .where(
            (c) => c.deliverables.any((d) => d.platform == platform),
          )
          .toList();
    }

    // Simple cursor: skip index encoded as integer string.
    var start = 0;
    if (cursor != null && cursor.isNotEmpty) {
      start = int.tryParse(cursor) ?? 0;
    }
    const pageSize = 20;
    final page = items.skip(start).take(pageSize).toList();
    final next =
        start + pageSize < items.length ? '${start + pageSize}' : null;
    return (items: page, nextCursor: next);
  }

  @override
  Future<MarketplaceCampaign> getCampaign(String id) async {
    await _store.delay();
    _ensureFixtures();

    final found = _lookupCampaign(id);
    if (found != null) return found;
    throw NotFoundFailure('Marketplace campaign not found: $id');
  }

  @override
  Future<Application> apply({
    required String campaignId,
    required String profileId,
    required String proposedCollabType,
    String? pitch,
    List<Map<String, dynamic>>? proposedPrices,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final mc = _lookupCampaign(campaignId);
    if (mc == null) {
      throw NotFoundFailure('Marketplace campaign not found: $campaignId');
    }
    if (mc.status != 'applications_open' && mc.status != 'published') {
      throw const ConflictFailure(
        'Campaign is not accepting applications',
        errorCode: 'CAMPAIGN_CLOSED',
      );
    }
    if (!mc.applyCollabOptions.contains(proposedCollabType)) {
      throw ValidationFailure(
        'Collab type not permitted: $proposedCollabType',
      );
    }

    final existing = _store.list<Application>('applications').where(
          (a) =>
              a.campaignId == campaignId &&
              a.influencerProfileId == profileId &&
              a.status != 'withdrawn' &&
              a.status != 'rejected',
        );
    if (existing.isNotEmpty) {
      throw const ConflictFailure(
        'Already applied to this campaign',
        errorCode: 'DUPLICATE_APPLICATION',
      );
    }

    final useStable = campaignId == MockIds.campaign1 &&
        profileId == MockIds.influencer1 &&
        _app(MockIds.application1) == null;

    final app = Application(
      id: useStable
          ? MockIds.application1
          : 'app-mock-${DateTime.now().microsecondsSinceEpoch}',
      campaignId: campaignId,
      influencerProfileId: profileId,
      origin: 'applied',
      status: 'submitted',
      pitch: pitch,
      proposedCollabType: proposedCollabType,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    _store.add('applications', app);
    return app;
  }

  @override
  Future<List<Application>> listMine(String profileId) async {
    await _store.delay();
    _ensureFixtures();
    return _store
        .list<Application>('applications')
        .where((a) => a.influencerProfileId == profileId)
        .toList();
  }

  @override
  Future<List<Application>> brandInbox(
    String brandId, {
    String? campaignId,
    String? status,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final campIds = _store
        .list<Campaign>('campaigns')
        .where((c) => c.brandId == brandId)
        .map((c) => c.id)
        .toSet();

    // Also include marketplace_campaigns whose brand matches.
    for (final mc in _store.list<MarketplaceCampaign>('marketplace_campaigns')) {
      if (mc.brand?.id == brandId) campIds.add(mc.id);
    }

    var apps = _store
        .list<Application>('applications')
        .where((a) => campIds.contains(a.campaignId));
    if (campaignId != null && campaignId.isNotEmpty) {
      apps = apps.where((a) => a.campaignId == campaignId);
    }
    if (status != null && status.isNotEmpty) {
      apps = apps.where((a) => a.status == status);
    }
    return apps.toList();
  }

  @override
  Future<Application> shortlist(String applicationId) async {
    await _store.delay();
    _ensureFixtures();
    final app = _app(applicationId);
    if (app == null) {
      throw NotFoundFailure('Application not found: $applicationId');
    }
    if (!app.canBrandShortlist) {
      throw ConflictFailure(
        'Cannot shortlist application in status ${app.status}',
      );
    }
    return _replaceApp(_copyApp(app, status: 'shortlisted'));
  }

  @override
  Future<Application> reject(
    String applicationId, {
    required String reason,
  }) async {
    await _store.delay();
    _ensureFixtures();
    final app = _app(applicationId);
    if (app == null) {
      throw NotFoundFailure('Application not found: $applicationId');
    }
    if (!app.canBrandReject) {
      throw ConflictFailure(
        'Cannot reject application in status ${app.status}',
      );
    }
    if (reason.trim().isEmpty) {
      throw const ValidationFailure('Rejection reason is required');
    }
    return _replaceApp(
      _copyApp(app, status: 'rejected', rejectionReason: reason.trim()),
    );
  }

  @override
  Future<Application> withdraw(String applicationId) async {
    await _store.delay();
    _ensureFixtures();
    final app = _app(applicationId);
    if (app == null) {
      throw NotFoundFailure('Application not found: $applicationId');
    }
    if (!app.canWithdraw) {
      throw ConflictFailure(
        'Cannot withdraw application in status ${app.status}',
      );
    }
    return _replaceApp(_copyApp(app, status: 'withdrawn'));
  }

  @override
  Future<Application> invite({
    required String campaignId,
    required String profileId,
    String? message,
  }) async {
    await _store.delay();
    _ensureFixtures();

    final app = Application(
      id: 'app-inv-${DateTime.now().microsecondsSinceEpoch}',
      campaignId: campaignId,
      influencerProfileId: profileId,
      origin: 'invited',
      status: 'submitted',
      pitch: message,
      proposedCollabType: 'paid',
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    _store.add('applications', app);
    return app;
  }

  @override
  Future<Application> acceptInvite(String applicationId) async {
    await _store.delay();
    _ensureFixtures();
    final app = _app(applicationId);
    if (app == null) {
      throw NotFoundFailure('Application not found: $applicationId');
    }
    if (!app.isPendingInvite) {
      throw const ConflictFailure('Application is not a pending invite');
    }
    // Accept invite → treated as shortlisted applied.
    return _replaceApp(
      _copyApp(app, status: 'shortlisted', origin: 'invited'),
    );
  }

  @override
  Future<Application> declineInvite(String applicationId) async {
    await _store.delay();
    _ensureFixtures();
    final app = _app(applicationId);
    if (app == null) {
      throw NotFoundFailure('Application not found: $applicationId');
    }
    if (!app.isPendingInvite) {
      throw const ConflictFailure('Application is not a pending invite');
    }
    return _replaceApp(_copyApp(app, status: 'withdrawn'));
  }
}
