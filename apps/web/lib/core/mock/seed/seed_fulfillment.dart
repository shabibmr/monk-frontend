import '../../../features/barter/domain/entities/barter.dart';
import '../../../features/content/domain/entities/content.dart';
import '../../../features/contracts/domain/entities/contract.dart';
import '../../../features/contracts/domain/entities/contract_template.dart';
import '../../../features/publish/domain/entities/published_post.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Contracts, content review, published posts, barter fulfillment.
void seedFulfillment(MockSeedStore store) {
  const deliv1 = 'deliv-demo-1';
  const delivInProg = 'deliv-demo-ip-1';
  const version1 = 'cv-demo-1';
  const version2 = 'cv-demo-2';

  // --- Contract templates ---
  store.putAll('contract_templates', [
    const ContractTemplate(
      id: 'tmpl-standard-paid',
      key: 'standard_paid_v1',
      name: 'Standard Paid Collaboration',
      body:
          'This Agreement is between {{brand_name}} and {{creator_name}} for deliverables under campaign {{campaign_code}}. Compensation: {{agreed_price}} {{currency}}. Usage rights: organic reuse {{duration_days}} days, territory {{territory}}.',
      parameters: [
        'brand_name',
        'creator_name',
        'campaign_code',
        'agreed_price',
        'currency',
        'duration_days',
        'territory',
      ],
      version: '1.0',
      isActive: true,
      createdAt: '2026-01-15T00:00:00Z',
    ),
    const ContractTemplate(
      id: 'tmpl-hybrid',
      key: 'hybrid_barter_v1',
      name: 'Hybrid / Barter Collaboration',
      body:
          'Hybrid agreement: cash {{agreed_price}} {{currency}} plus product {{barter_description}} valued at {{barter_value}}.',
      parameters: [
        'agreed_price',
        'currency',
        'barter_description',
        'barter_value',
      ],
      version: '1.0',
      isActive: true,
      createdAt: '2026-01-15T00:00:00Z',
    ),
  ]);

  // --- Contract (accepted / mid-spine for collab-demo-1) ---
  store.putAll('contracts', [
    const Contract(
      id: MockIds.contract1,
      collaborationId: MockIds.collab1,
      status: 'accepted',
      contentHash: 'sha256:demo-contract-hash-001',
      templateKey: 'standard_paid_v1',
      templateVersion: '1.0',
      pdfUrl: 'https://cdn.demo.influencersmonk.local/contracts/contract-demo-1.pdf',
      usageRights: UsageRights(
        organicReuse: true,
        paidAmplification: false,
        durationDays: 90,
        territory: 'IN',
        channels: ['instagram', 'youtube'],
        exclusivityCategory: 'consumer_electronics',
        exclusivityDays: 30,
      ),
      acceptances: [
        ContractAcceptance(
          party: 'brand',
          acceptedByUserId: MockIds.brand1,
          contentHash: 'sha256:demo-contract-hash-001',
          acceptedAt: '2026-06-15T10:00:00Z',
        ),
        ContractAcceptance(
          party: 'influencer',
          acceptedByUserId: MockIds.creator1,
          contentHash: 'sha256:demo-contract-hash-001',
          acceptedAt: '2026-06-15T11:30:00Z',
        ),
      ],
      bothPartiesAccepted: true,
    ),
  ]);

  // --- Content submission mid-review ---
  final versions = [
    const ContentVersion(
      id: version1,
      submissionId: MockIds.content1,
      versionNumber: 1,
      status: 'revision_requested',
      caption:
          'Unboxing the new Monk gear — first impressions 🔥 #tech',
      hashtags: ['#tech', '#unboxing'],
      links: [],
      mediaFileIds: ['file-demo-v1'],
      immutable: true,
      reviewComment: 'Please add #ad disclosure and product close-up shot.',
      collaborationId: MockIds.collab1,
      campaignDeliverableId: delivInProg,
      disclosure: DisclosureInfo(
        passed: false,
        requiredTags: ['#ad', '#sponsored'],
        missingTags: ['#ad'],
        overrideRequired: false,
      ),
    ),
    const ContentVersion(
      id: version2,
      submissionId: MockIds.content1,
      versionNumber: 2,
      status: 'submitted',
      caption:
          'Honest unboxing of the Monk Demo device — setup in under 2 minutes. #ad #sponsored',
      hashtags: ['#ad', '#sponsored', '#tech', '#unboxing'],
      links: ['https://demo.influencersmonk.local/p/summer'],
      mediaFileIds: ['file-demo-v2'],
      immutable: true,
      collaborationId: MockIds.collab1,
      campaignDeliverableId: delivInProg,
      disclosure: DisclosureInfo(
        passed: true,
        requiredTags: ['#ad', '#sponsored'],
        missingTags: [],
        overrideRequired: false,
      ),
    ),
  ];

  store.putAll('content_versions', versions);

  store.putAll('content_submissions', [
    ContentSubmission(
      id: MockIds.content1,
      collaborationId: MockIds.collab1,
      campaignDeliverableId: delivInProg,
      status: 'in_review',
      currentVersionId: version2,
      versions: versions,
    ),
  ]);

  store.putAll('content_comments', [
    const ContentComment(
      id: 'cmt-demo-1',
      contentVersionId: version1,
      authorUserId: MockIds.brand1,
      body: 'Love the energy — please add required #ad tag and a product close-up.',
      createdAt: '2026-07-01T12:00:00Z',
    ),
    const ContentComment(
      id: 'cmt-demo-2',
      contentVersionId: version1,
      authorUserId: MockIds.creator1,
      body: 'Got it — uploading v2 with disclosure and close-up.',
      parentCommentId: 'cmt-demo-1',
      createdAt: '2026-07-01T14:20:00Z',
    ),
    const ContentComment(
      id: 'cmt-demo-3',
      contentVersionId: version2,
      authorUserId: MockIds.brand1,
      body: 'v2 looks good — reviewing full cut now.',
      createdAt: '2026-07-08T09:15:00Z',
    ),
  ]);

  // --- Published post (completed path sample) ---
  store.putAll('published_posts', [
    const PublishedPost(
      id: MockIds.published1,
      collaborationId: MockIds.collab1,
      campaignDeliverableId: deliv1,
      liveUrl: 'https://www.instagram.com/reel/demoArjunSummer001/',
      platform: 'instagram',
      ownershipVerified: true,
      verificationStatus: 'verified',
      verificationMethod: 'manual',
      verificationDetail: 'URL ownership confirmed by brand.',
      verifiedAt: '2026-07-15T18:00:00Z',
      autoPublish: false,
    ),
  ]);

  // --- Barter mid-flow (shipment shipped, awaiting receive) ---
  store.putAll('barters', [
    const BarterStatus(
      collaborationId: MockIds.collab1,
      collabType: 'paid',
      collabStatus: 'content_pending',
      requiresFulfillment: false,
      skipsProductStates: true,
      returnsSupported: false,
      fulfillment: null,
    ),
    const BarterStatus(
      collaborationId: 'collab-barter-demo',
      collabType: 'hybrid',
      collabStatus: 'product_shipped',
      requiresFulfillment: true,
      skipsProductStates: false,
      returnsSupported: false,
      fulfillment: BarterFulfillment(
        id: 'barter-ful-demo-1',
        collaborationId: 'collab-barter-demo',
        productDescription: 'Monk Demo earbuds sample kit (black)',
        status: 'shipped',
        declaredValueMinor: 499900,
        shippingCarrier: 'Delhivery',
        trackingRef: 'DLV-DEMO-998877',
        shippedAt: '2026-07-12T08:00:00Z',
        evidenceFileIds: ['ship-label-demo-1'],
        notes: 'Leave with security if not home.',
      ),
    ),
  ]);
}
