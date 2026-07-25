import '../../../features/campaigns/domain/entities/campaign.dart';
import '../../../features/discovery/domain/entities/discovery.dart';
import '../../../features/marketplace/domain/entities/marketplace.dart';
import '../../../features/negotiations/domain/entities/negotiation.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Campaigns, applications, negotiations, shortlists (marketplace spine).
void seedMarketplace(MockSeedStore store) {
  const deliv1 = 'deliv-demo-1';
  const deliv2 = 'deliv-demo-2';
  const delivDraft = 'deliv-demo-draft';
  const delivInProg = 'deliv-demo-ip-1';
  const delivDone = 'deliv-demo-done-1';

  // --- Campaigns (mixed statuses) ---
  final campOpen = const Campaign(
    id: MockIds.campaign1,
    brandId: MockIds.brandOrg1,
    name: 'Summer Launch Reels',
    code: 'SUMMER-2026',
    status: 'applications_open',
    mode: 'self_serve',
    objective: 'awareness',
    currency: 'INR',
    budgetTotalMinor: 15000000,
    deliverableCount: 2,
  );

  final campPublished = const Campaign(
    id: MockIds.campaign2,
    brandId: MockIds.brandOrg1,
    name: 'Monsoon Story Pack',
    code: 'MONSOON-26',
    status: 'published',
    mode: 'self_serve',
    objective: 'engagement',
    currency: 'INR',
    budgetTotalMinor: 5000000,
    deliverableCount: 1,
  );

  final campInProgress = const Campaign(
    id: MockIds.campaign3,
    brandId: MockIds.brandOrg1,
    name: 'Tech Unboxing Series',
    code: 'TECH-UBX',
    status: 'in_progress',
    mode: 'self_serve',
    objective: 'consideration',
    currency: 'INR',
    budgetTotalMinor: 20000000,
    deliverableCount: 1,
  );

  final campDraft = const Campaign(
    id: MockIds.campaignDraft,
    brandId: MockIds.brandOrg1,
    name: 'Festive Gift Guide (Draft)',
    code: 'FESTIVE-DRAFT',
    status: 'draft',
    mode: 'self_serve',
    objective: 'conversion',
    currency: 'INR',
    budgetTotalMinor: 8000000,
    deliverableCount: 1,
  );

  final campDone = const Campaign(
    id: MockIds.campaignDone,
    brandId: MockIds.brandOrg1,
    name: 'Spring Collab Wrap',
    code: 'SPRING-DONE',
    status: 'completed',
    mode: 'self_serve',
    objective: 'awareness',
    currency: 'INR',
    budgetTotalMinor: 10000000,
    deliverableCount: 1,
  );

  store.putAll('campaigns', [
    campOpen,
    campPublished,
    campInProgress,
    campDraft,
    campDone,
  ]);

  final openDeliverables = [
    const Deliverable(
      id: deliv1,
      platform: 'instagram',
      deliverableType: 'instagram_reel',
      disclosureTags: ['#ad', '#sponsored'],
      captionGuidelines: 'Highlight product USP in first 3s. Use #ad.',
    ),
    const Deliverable(
      id: deliv2,
      platform: 'instagram',
      deliverableType: 'instagram_story',
      disclosureTags: ['#ad'],
      captionGuidelines: 'Swipe-up / link sticker to product page.',
    ),
  ];

  store.putAll('deliverables', [
    ...openDeliverables,
    const Deliverable(
      id: delivDraft,
      platform: 'instagram',
      deliverableType: 'instagram_post',
      disclosureTags: ['#ad'],
    ),
    const Deliverable(
      id: delivInProg,
      platform: 'youtube',
      deliverableType: 'youtube_video',
      disclosureTags: ['#ad', '#sponsored'],
      captionGuidelines: 'Full unboxing with honest first impressions.',
    ),
    const Deliverable(
      id: delivDone,
      platform: 'instagram',
      deliverableType: 'instagram_reel',
      disclosureTags: ['#ad'],
    ),
  ]);

  store.putAll('campaign_details', [
    CampaignDetail(campaign: campOpen, deliverables: openDeliverables),
    CampaignDetail(
      campaign: campPublished,
      deliverables: const [
        Deliverable(
          id: 'deliv-demo-pub-1',
          platform: 'instagram',
          deliverableType: 'instagram_story',
          disclosureTags: ['#ad'],
        ),
      ],
    ),
    CampaignDetail(
      campaign: campInProgress,
      deliverables: const [
        Deliverable(
          id: delivInProg,
          platform: 'youtube',
          deliverableType: 'youtube_video',
          disclosureTags: ['#ad', '#sponsored'],
          captionGuidelines: 'Full unboxing with honest first impressions.',
        ),
      ],
    ),
    CampaignDetail(
      campaign: campDraft,
      deliverables: const [
        Deliverable(
          id: delivDraft,
          platform: 'instagram',
          deliverableType: 'instagram_post',
          disclosureTags: ['#ad'],
        ),
      ],
    ),
    CampaignDetail(
      campaign: campDone,
      deliverables: const [
        Deliverable(
          id: delivDone,
          platform: 'instagram',
          deliverableType: 'instagram_reel',
          disclosureTags: ['#ad'],
        ),
      ],
    ),
  ]);

  // Marketplace listings (creator browse) — mirror open/published campaigns.
  const monkBrand = MarketplaceBrand(
    id: MockIds.brandOrg1,
    companyName: 'Monk Demo Brand',
    country: 'IN',
    industry: 'Consumer Electronics',
  );

  store.putAll('marketplace_campaigns', [
    MarketplaceCampaign(
      id: MockIds.campaign1,
      name: campOpen.name,
      code: campOpen.code,
      status: campOpen.status,
      mode: campOpen.mode,
      objective: campOpen.objective,
      currency: campOpen.currency,
      budgetTotalMinor: campOpen.budgetTotalMinor,
      permittedCollabTypes: const ['paid', 'barter', 'hybrid'],
      brand: monkBrand,
      deliverables: openDeliverables
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
    ),
    MarketplaceCampaign(
      id: MockIds.campaign2,
      name: campPublished.name,
      code: campPublished.code,
      status: campPublished.status,
      mode: campPublished.mode,
      objective: campPublished.objective,
      currency: campPublished.currency,
      budgetTotalMinor: campPublished.budgetTotalMinor,
      permittedCollabTypes: const ['paid'],
      brand: monkBrand,
      deliverables: const [
        MarketplaceDeliverable(
          id: 'deliv-demo-pub-1',
          platform: 'instagram',
          deliverableType: 'instagram_story',
          disclosureTags: ['#ad'],
        ),
      ],
    ),
  ]);

  // --- Applications (mixed statuses) ---
  store.putAll('applications', [
    const Application(
      id: MockIds.application1,
      campaignId: MockIds.campaign1,
      influencerProfileId: MockIds.influencer1,
      origin: 'applied',
      status: 'shortlisted',
      pitch:
          'I love the Summer Launch brief — my audience is 18–34 lifestyle buyers in metro India. Can deliver reel + story pack within 10 days.',
      proposedCollabType: 'paid',
      createdAt: '2026-07-10T10:00:00Z',
    ),
    const Application(
      id: 'app-demo-2',
      campaignId: MockIds.campaign1,
      influencerProfileId: MockIds.influencer2,
      origin: 'applied',
      status: 'submitted',
      pitch: 'Food/travel crossover angle for summer product.',
      proposedCollabType: 'hybrid',
      createdAt: '2026-07-12T08:30:00Z',
    ),
    const Application(
      id: 'app-demo-3',
      campaignId: MockIds.campaign1,
      influencerProfileId: MockIds.influencer3,
      origin: 'invited',
      status: 'submitted',
      pitch: null,
      proposedCollabType: 'paid',
      createdAt: '2026-07-11T14:00:00Z',
    ),
    const Application(
      id: 'app-demo-4',
      campaignId: MockIds.campaign1,
      influencerProfileId: 'inf-demo-4',
      origin: 'applied',
      status: 'rejected',
      pitch: 'Skincare angle may not fit electronics — still interested.',
      proposedCollabType: 'barter',
      rejectionReason: 'Audience mismatch for electronics launch.',
      createdAt: '2026-07-09T16:20:00Z',
    ),
    const Application(
      id: 'app-demo-5',
      campaignId: MockIds.campaign3,
      influencerProfileId: MockIds.influencer1,
      origin: 'applied',
      status: 'converted',
      pitch: 'Happy to lead the unboxing series.',
      proposedCollabType: 'paid',
      createdAt: '2026-06-01T09:00:00Z',
    ),
    const Application(
      id: 'app-demo-6',
      campaignId: MockIds.campaign2,
      influencerProfileId: MockIds.influencer2,
      origin: 'applied',
      status: 'withdrawn',
      pitch: 'Schedule conflict — withdrawing.',
      proposedCollabType: 'paid',
      createdAt: '2026-07-05T11:00:00Z',
    ),
  ]);

  // --- Negotiation with offers ---
  store.putAll('negotiations', [
    const Negotiation(
      id: MockIds.negotiation1,
      applicationId: MockIds.application1,
      status: 'open',
      roundCount: 2,
      maxRounds: maxNegotiationRounds,
      offers: [
        NegotiationOffer(
          id: 'offer-demo-1',
          round: 1,
          offeredBy: 'influencer',
          collabType: 'paid',
          agreedPriceMinor: 3000000,
          currency: 'INR',
          status: 'countered',
          priceLines: [
            OfferPriceLine(deliverableId: deliv1, priceMinor: 2500000),
            OfferPriceLine(deliverableId: deliv2, priceMinor: 500000),
          ],
          message: 'Standard reel + story rate for this campaign.',
        ),
        NegotiationOffer(
          id: 'offer-demo-2',
          round: 2,
          offeredBy: 'brand',
          collabType: 'paid',
          agreedPriceMinor: 2500000,
          currency: 'INR',
          status: 'pending',
          priceLines: [
            OfferPriceLine(deliverableId: deliv1, priceMinor: 2000000),
            OfferPriceLine(deliverableId: deliv2, priceMinor: 500000),
          ],
          message: 'Counter at ₹25,000 total — fits our summer budget.',
        ),
      ],
    ),
  ]);

  // Collaboration snapshot for converted app (in-progress campaign).
  store.putAll('collaborations', [
    const CollaborationSnapshot(
      id: MockIds.collab1,
      collabType: 'paid',
      status: 'content_pending',
      agreedPriceMinor: 2500000,
      currency: 'INR',
      commissionPct: 15,
    ),
  ]);

  // --- Shortlists ---
  store.putAll('shortlists', [
    const Shortlist(id: MockIds.shortlist1, name: 'Summer shortlist'),
    const Shortlist(id: 'shortlist-demo-2', name: 'Tech reviewers'),
  ]);

  store.putAll('shortlist_items', [
    const ShortlistItem(
      id: 'sli-1',
      influencerProfileId: MockIds.influencer1,
      note: 'Top pick for reel',
      displayName: 'Arjun Creates',
    ),
    const ShortlistItem(
      id: 'sli-2',
      influencerProfileId: MockIds.influencer2,
      note: 'Backup story pack',
      displayName: 'Nisha Vlogs',
    ),
    const ShortlistItem(
      id: 'sli-3',
      influencerProfileId: MockIds.influencer3,
      note: 'YouTube depth',
      displayName: 'Dev Tech Reviews',
    ),
  ]);
}
