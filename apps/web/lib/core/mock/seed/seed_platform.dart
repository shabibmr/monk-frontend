import '../../../features/agency/domain/entities/agency_asset.dart';
import '../../../features/agency/domain/entities/agency_kanban_card.dart';
import '../../../features/agency/domain/entities/agency_kanban_column.dart';
import '../../../features/agency/domain/entities/agency_operator_report.dart';
import '../../../features/ai/domain/entities/ai_assist_result.dart';
import '../../../features/ai/domain/entities/brief_assist.dart';
import '../../../features/ai/domain/entities/caption_assist.dart';
import '../../../features/analytics/domain/entities/analytics_metric.dart';
import '../../../features/billing/domain/entities/billing_invoice.dart';
import '../../../features/billing/domain/entities/subscription_details.dart';
import '../../../features/billing/domain/entities/subscription_plan.dart';
import '../../../features/briefs/domain/entities/brief.dart';
import '../../../features/chat/domain/entities/chat_message.dart';
import '../../../features/chat/domain/entities/chat_thread.dart';
import '../../../features/disputes/domain/entities/data_erasure_request.dart';
import '../../../features/disputes/domain/entities/dispute.dart';
import '../../../features/fraud/domain/entities/fraud_risk_report.dart';
import '../../../features/kyc/domain/entities/kyc.dart';
import '../../../features/licensing/domain/entities/licensing_grant.dart';
import '../../../features/notifications/domain/entities/notification_preferences.dart';
import '../../../features/recommendations/domain/entities/recommendation.dart';
import '../../../features/referrals/domain/entities/referral_reward.dart';
import '../../../features/reviews/domain/entities/review.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// KYC, chat, agency, disputes, billing, referrals, analytics, AI, fraud, etc.
void seedPlatform(MockSeedStore store) {
  // --- KYC ---
  store.putAll('kyc_records', [
    const KycRecord(
      id: MockIds.kyc1,
      status: 'pending',
      influencerProfileId: MockIds.influencer3,
      identityDocFileId: 'file-kyc-id-3',
      gstRegistered: false,
      panMasked: 'XXXXXX1234',
      accountMasked: 'XXXX4521',
    ),
    const KycRecord(
      id: 'kyc-demo-2',
      status: 'approved',
      influencerProfileId: MockIds.influencer1,
      identityDocFileId: 'file-kyc-id-1',
      gstRegistered: true,
      panMasked: 'XXXXXX9876',
      gstMasked: '29XXXXX0000X1Z5',
      accountMasked: 'XXXX8890',
    ),
    const KycRecord(
      id: 'kyc-demo-3',
      status: 'rejected',
      influencerProfileId: MockIds.influencer2,
      identityDocFileId: 'file-kyc-id-2',
      gstRegistered: false,
      panMasked: 'XXXXXX5555',
      rejectionReason: 'Identity document expired — please re-upload.',
    ),
  ]);

  store.putAll('kyc_queue', [
    const QueueInfluencer(
      id: MockIds.influencer3,
      displayName: 'Dev Tech Reviews',
      country: 'IN',
      verificationStatus: 'pending',
    ),
    const QueueInfluencer(
      id: 'inf-demo-4',
      displayName: 'Kira Skincare',
      country: 'IN',
      verificationStatus: 'pending',
    ),
    const QueueInfluencer(
      id: MockIds.influencer1,
      displayName: 'Arjun Creates',
      country: 'IN',
      verificationStatus: 'approved',
    ),
  ]);

  store.putAll('media_licenses', [
    MediaLicense(
      id: 'lic-media-1',
      licenseNumber: 'UAE-ML-2026-001',
      status: 'valid',
      expiryDate: DateTime.utc(2027, 3, 1),
      issuingAuthority: 'UAE Media Council (demo)',
    ),
    MediaLicense(
      id: 'lic-media-2',
      licenseNumber: 'UAE-ML-2025-044',
      status: 'expiring',
      expiryDate: DateTime.utc(2026, 8, 15),
      issuingAuthority: 'UAE Media Council (demo)',
    ),
  ]);

  store.putAll('rejection_templates', [
    const RejectionTemplate(
      key: 'doc_expired',
      category: 'kyc',
      body: 'Identity document expired — please re-upload a valid ID.',
    ),
    const RejectionTemplate(
      key: 'blurry_scan',
      category: 'kyc',
      body: 'Document image is unreadable. Upload a clear scan or photo.',
    ),
    const RejectionTemplate(
      key: 'name_mismatch',
      category: 'kyc',
      body: 'Name on document does not match profile legal name.',
    ),
  ]);

  // --- Chat ---
  store.putAll('chat_threads', [
    const ChatThread(
      id: MockIds.chatThread1,
      title: 'Summer Launch — Arjun',
      participantName: 'Arjun Creates',
      participantRole: 'influencer',
      lastMessageText: 'Uploaded v2 of the reel for review.',
      lastMessageTime: '11:42 AM',
      unreadCount: 1,
      isVoiceAllowed: true,
    ),
    const ChatThread(
      id: 'chat-demo-2',
      title: 'Agency ops — Glow brief',
      participantName: 'Alex Agency',
      participantRole: 'agency_operator',
      lastMessageText: 'Kanban card moved to content review.',
      lastMessageTime: 'Yesterday',
      unreadCount: 0,
      isVoiceAllowed: true,
    ),
  ]);

  store.putAll('chat_messages', [
    const ChatMessage(
      id: 'msg-demo-1',
      threadId: MockIds.chatThread1,
      senderId: MockIds.brand1,
      senderName: 'Priya Brand',
      text: 'Hi Arjun — excited to collab on Summer Launch. Draft due Friday?',
      createdAt: '10:05 AM',
      isMine: false,
    ),
    const ChatMessage(
      id: 'msg-demo-2',
      threadId: MockIds.chatThread1,
      senderId: MockIds.creator1,
      senderName: 'Arjun Creates',
      text: 'Works for me. I will share a storyboard today.',
      createdAt: '10:18 AM',
      isMine: true,
    ),
    const ChatMessage(
      id: 'msg-demo-3',
      threadId: MockIds.chatThread1,
      senderId: MockIds.creator1,
      senderName: 'Arjun Creates',
      text: 'Uploaded v2 of the reel for review.',
      createdAt: '11:42 AM',
      isMine: true,
    ),
    const ChatMessage(
      id: 'msg-demo-4',
      threadId: MockIds.chatThread1,
      senderId: MockIds.brand1,
      senderName: 'Priya Brand',
      text: 'Voice note on caption tone:',
      createdAt: '11:50 AM',
      isMine: false,
      mediaType: 'voice',
      mediaUrl: 'https://cdn.demo.influencersmonk.local/audio/voice_demo_1.mp3',
      voiceDurationSeconds: 28,
    ),
  ]);

  // --- Agency kanban (3+ columns with cards) ---
  const card101 = AgencyKanbanCard(
    id: 'card-101',
    title: 'Summer Skincare Reel Launch',
    brandName: 'Glow Beauty',
    creatorName: 'Unassigned',
    stage: 'unassigned',
    dueDate: '2026-08-05',
    assetCount: 1,
    pendingApprovalsCount: 1,
    budgetMinor: 25000000,
    currency: 'INR',
  );
  const card102 = AgencyKanbanCard(
    id: 'card-102',
    title: 'Fitness Supplement Unboxing',
    brandName: 'Pulse Fit',
    creatorName: 'Omar Fitness',
    stage: 'in_briefing',
    dueDate: '2026-08-08',
    assetCount: 2,
    pendingApprovalsCount: 0,
    budgetMinor: 18000000,
    currency: 'INR',
  );
  const card103 = AgencyKanbanCard(
    id: 'card-103',
    title: 'Tech Gadget Hands-On Video',
    brandName: 'Monk Demo Brand',
    creatorName: 'Arjun Creates',
    stage: 'content_in_review',
    dueDate: '2026-07-28',
    assetCount: 3,
    pendingApprovalsCount: 2,
    budgetMinor: 40000000,
    currency: 'INR',
  );
  const card104 = AgencyKanbanCard(
    id: 'card-104',
    title: 'Eco Fashion Lookbook Post',
    brandName: 'Verde Wear',
    creatorName: 'Lina Eco',
    stage: 'ready_to_publish',
    dueDate: '2026-07-24',
    assetCount: 2,
    pendingApprovalsCount: 0,
    budgetMinor: 12000000,
    currency: 'INR',
  );

  store.putAll('agency_columns', [
    const AgencyKanbanColumn(
      id: 'unassigned',
      title: 'Unassigned Briefs',
      wipLimit: 10,
      cards: [card101],
    ),
    const AgencyKanbanColumn(
      id: 'in_briefing',
      title: 'In Briefing / Matching',
      wipLimit: 8,
      cards: [card102],
    ),
    const AgencyKanbanColumn(
      id: 'content_in_review',
      title: 'Content Review & Approval',
      wipLimit: 5,
      cards: [card103],
    ),
    const AgencyKanbanColumn(
      id: 'ready_to_publish',
      title: 'Ready for Publish',
      cards: [card104],
    ),
  ]);

  store.putAll('agency_cards', [card101, card102, card103, card104]);

  store.putAll('agency_assets', [
    const AgencyAsset(
      id: 'asset-1',
      cardId: 'card-103',
      title: 'Draft Reel Video (v1).mp4',
      fileUrl: 'https://cdn.demo.influencersmonk.local/assets/draft_v1.mp4',
      fileType: 'video/mp4',
      status: 'pending',
      uploadedBy: 'Arjun Creates',
      uploadedAt: '2026-07-18T10:00:00Z',
      notes: 'Needs brand logo end-card',
    ),
    const AgencyAsset(
      id: 'asset-2',
      cardId: 'card-103',
      title: 'Thumbnail concepts.zip',
      fileUrl: 'https://cdn.demo.influencersmonk.local/assets/thumbs.zip',
      fileType: 'application/zip',
      status: 'approved',
      uploadedBy: 'Alex Agency',
      uploadedAt: '2026-07-17T15:30:00Z',
    ),
    const AgencyAsset(
      id: 'asset-3',
      cardId: 'card-102',
      title: 'Brief PDF',
      fileUrl: 'https://cdn.demo.influencersmonk.local/assets/brief_pulse.pdf',
      fileType: 'application/pdf',
      status: 'approved',
      uploadedBy: 'Alex Agency',
      uploadedAt: '2026-07-16T09:00:00Z',
    ),
  ]);

  store.singles['agency_report'] = const AgencyOperatorReport(
    totalActiveBriefs: 4,
    deliveredOnTimeCount: 12,
    pendingApprovalAssetsCount: 3,
    avgTurnaroundDays: 4.5,
    operators: [
      OperatorMetrics(
        operatorId: MockIds.agency1,
        name: 'Alex Agency',
        activeBriefs: 3,
        completedCampaigns: 8,
        onTimeDeliveryRatePct: 92,
      ),
      OperatorMetrics(
        operatorId: 'ops-demo-2',
        name: 'Jordan Ops',
        activeBriefs: 1,
        completedCampaigns: 5,
        onTimeDeliveryRatePct: 88,
      ),
    ],
  );
  // Also expose as collection for list-style repos.
  store.putAll('agency_report', [store.singles['agency_report']]);

  // --- Disputes & erasure ---
  store.putAll('disputes', [
    const Dispute(
      id: MockIds.dispute1,
      collaborationId: MockIds.collab1,
      raisedBy: MockIds.brand1,
      reason: 'content_quality',
      description:
          'Final cut missed agreed product close-up; requesting revision or partial refund.',
      status: 'open',
      paymentId: MockIds.payment1,
      evidenceUrls: [
        'https://cdn.demo.influencersmonk.local/evidence/dispute1-frame.png',
      ],
      createdAt: '2026-07-19T08:00:00Z',
    ),
    const Dispute(
      id: 'dispute-demo-2',
      collaborationId: 'collab-barter-demo',
      raisedBy: MockIds.creator1,
      reason: 'product_not_received',
      description: 'Tracking stuck for 5 days; cannot shoot without product.',
      status: 'under_review',
      createdAt: '2026-07-14T12:00:00Z',
      adminNotes: 'Carrier contacted — update pending.',
    ),
  ]);

  store.putAll('erasure_requests', [
    const DataErasureRequest(
      id: 'erasure-demo-1',
      userId: MockIds.creatorFresh,
      status: 'pending',
      reason: 'No longer using the platform (test account).',
      userEmail: MockIds.emailCreatorFresh,
      requestedAt: '2026-07-20T07:00:00Z',
    ),
  ]);

  // --- Billing ---
  const proPlan = SubscriptionPlan(
    id: 'plan_pro',
    name: 'Pro Plan',
    tier: 'Pro',
    priceMinorUnits: 499900,
    currency: 'INR',
    features: [
      'Unlimited campaigns',
      'AI assist',
      'Priority support',
      'Team seats (5)',
    ],
    billingInterval: 'monthly',
    isRecommended: true,
  );
  const freePlan = SubscriptionPlan(
    id: 'plan_free',
    name: 'Starter',
    tier: 'Free',
    priceMinorUnits: 0,
    currency: 'INR',
    features: ['1 active campaign', 'Basic discovery'],
    billingInterval: 'monthly',
  );
  const enterprisePlan = SubscriptionPlan(
    id: 'plan_enterprise',
    name: 'Enterprise',
    tier: 'Enterprise',
    priceMinorUnits: 2499900,
    currency: 'INR',
    features: [
      'SSO',
      'Dedicated success manager',
      'Custom contracts',
      'Unlimited seats',
    ],
    billingInterval: 'monthly',
  );

  store.putAll('billing_plans', [freePlan, proPlan, enterprisePlan]);

  store.singles['subscription'] = const SubscriptionDetails(
    id: 'sub-demo-brand1',
    status: 'active',
    currentPlan: proPlan,
    renewsAt: '2026-08-01',
    currency: 'INR',
    activeCampaignCount: 4,
    campaignLimit: 50,
    cancelAtPeriodEnd: false,
  );

  store.putAll('billing_invoices', [
    const BillingInvoice(
      id: 'bill-inv-1',
      invoiceNumber: 'BILL-2026-07',
      issueDate: '2026-07-01',
      status: 'paid',
      amountMinorUnits: 499900,
      currency: 'INR',
      pdfUrl: 'https://cdn.demo.influencersmonk.local/billing/bill-2026-07.pdf',
    ),
    const BillingInvoice(
      id: 'bill-inv-2',
      invoiceNumber: 'BILL-2026-06',
      issueDate: '2026-06-01',
      status: 'paid',
      amountMinorUnits: 499900,
      currency: 'INR',
    ),
  ]);

  // --- Referrals ---
  store.putAll('referral_summary', [
    const ReferralSummary(
      totalEarnedMinor: 150000,
      pendingRewardsMinor: 50000,
      totalReferralsCount: 3,
      currency: 'INR',
      attributionBreakdown: {
        'user_signup': 2,
        'first_deal': 1,
      },
    ),
  ]);

  store.putAll('referral_rewards', [
    ReferralReward(
      id: MockIds.referralReward1,
      referrerId: MockIds.creator1,
      referredUserId: MockIds.creatorFresh,
      referredUserLabel: MockIds.emailCreatorFresh,
      rewardAmountMinor: 50000,
      currency: 'INR',
      status: 'pending',
      attributionType: 'user_signup',
      createdAt: DateTime.utc(2026, 7, 18),
    ),
    ReferralReward(
      id: 'ref-reward-demo-2',
      referrerId: MockIds.creator1,
      referredUserId: MockIds.influencer2,
      referredUserLabel: 'Nisha Vlogs',
      rewardAmountMinor: 100000,
      currency: 'INR',
      status: 'approved',
      attributionType: 'first_deal',
      createdAt: DateTime.utc(2026, 6, 1),
      reviewedAt: DateTime.utc(2026, 6, 5),
    ),
  ]);

  store.putAll('referrals_admin', [
    ReferralReward(
      id: MockIds.referralReward1,
      referrerId: MockIds.creator1,
      referredUserId: MockIds.creatorFresh,
      referredUserLabel: MockIds.emailCreatorFresh,
      rewardAmountMinor: 50000,
      currency: 'INR',
      status: 'pending',
      attributionType: 'user_signup',
      createdAt: DateTime.utc(2026, 7, 18),
    ),
  ]);

  // --- Analytics ---
  final chartSeries = [
    MetricDataPoint(
      timestamp: DateTime.utc(2026, 7, 1),
      label: 'Jul 1',
      value: 12000,
      secondaryValue: 800,
    ),
    MetricDataPoint(
      timestamp: DateTime.utc(2026, 7, 8),
      label: 'Jul 8',
      value: 18500,
      secondaryValue: 1200,
    ),
    MetricDataPoint(
      timestamp: DateTime.utc(2026, 7, 15),
      label: 'Jul 15',
      value: 24000,
      secondaryValue: 1900,
    ),
  ];

  final utmLinks = [
    const UtmLinkMetric(
      id: 'utm-demo-1',
      code: 'summer_arjun',
      targetUrl: 'https://demo.influencersmonk.local/p/summer',
      fullUtmUrl:
          'https://demo.influencersmonk.local/p/summer?utm_source=ig&utm_medium=reel&utm_campaign=summer_arjun',
      clicks: 1840,
      conversions: 92,
      revenueMinor: 460000,
      campaignId: MockIds.campaign1,
    ),
    const UtmLinkMetric(
      id: 'utm-demo-2',
      code: 'tech_yt',
      targetUrl: 'https://demo.influencersmonk.local/p/tech',
      fullUtmUrl:
          'https://demo.influencersmonk.local/p/tech?utm_source=yt&utm_medium=video&utm_campaign=tech_yt',
      clicks: 920,
      conversions: 41,
      revenueMinor: 205000,
      campaignId: MockIds.campaign3,
    ),
  ];

  store.putAll('utm_links', utmLinks);

  store.putAll('analytics_report', [
    AnalyticsReport(
      id: 'analytics-demo-1',
      title: 'Summer Launch performance',
      campaignId: MockIds.campaign1,
      startDate: DateTime.utc(2026, 7, 1),
      endDate: DateTime.utc(2026, 7, 20),
      totalReach: 420000,
      totalImpressions: 980000,
      totalEngagement: 36400,
      totalSpendMinor: 2500000,
      currency: 'INR',
      metricsComparison: const [
        MetricComparisonItem(
          metricName: 'Reach',
          currentValue: 420000,
          previousValue: 310000,
          changePercentage: 35.5,
          isPositive: true,
        ),
        MetricComparisonItem(
          metricName: 'Engagement',
          currentValue: 36400,
          previousValue: 29800,
          changePercentage: 22.1,
          isPositive: true,
        ),
      ],
      utmLinks: utmLinks,
      chartSeries: chartSeries,
    ),
  ]);

  store.putAll('export_jobs', [
    ExportJobStatus(
      jobId: 'export-demo-1',
      reportType: 'campaign_performance',
      format: 'csv',
      status: 'completed',
      progressPercent: 100,
      downloadUrl:
          'https://cdn.demo.influencersmonk.local/exports/summer_perf.csv',
      createdAt: DateTime.utc(2026, 7, 19, 16, 0),
    ),
    ExportJobStatus(
      jobId: 'export-demo-2',
      reportType: 'utm_performance',
      format: 'xlsx',
      status: 'processing',
      progressPercent: 45,
      createdAt: DateTime.utc(2026, 7, 21, 9, 0),
    ),
  ]);

  store.putAll('automated_metrics', [
    AutomatedPostMetrics(
      id: 'auto-met-1',
      publishedPostId: MockIds.published1,
      platform: 'instagram',
      reach: 52000,
      impressions: 78000,
      views: 61000,
      likes: 4200,
      comments: 310,
      shares: 180,
      clicks: 640,
      engagementRateBps: 680,
      lastSyncedAt: DateTime.utc(2026, 7, 20, 6, 0),
      history: chartSeries,
      isSyncing: false,
    ),
  ]);

  // --- AI assist canned results ---
  store.putAll('ai_assist', [
    const AiAssistResult(
      assistType: 'caption',
      rawOutput: 'Caption draft for Summer Launch reel',
      captionAssist: CaptionAssist(
        captionText:
            'Heat check: this gear survived my 40°C commute ☀️ Honest first impressions inside.',
        disclosureTags: ['#ad', '#sponsored'],
        suggestedHashtags: ['#summertech', '#unboxing', '#monkdemo'],
        tone: 'casual',
      ),
    ),
    const AiAssistResult(
      assistType: 'brief',
      rawOutput: 'Brief outline',
      briefAssist: BriefAssist(
        generatedBriefText:
            'Goal: drive awareness for Summer Launch among 18–34 urban India. '
            'Primary deliverable: 1 Instagram Reel (15–30s) + 2 Stories with link sticker. '
            'Tone: authentic, non-hard-sell, disclose #ad.',
        campaignObjectives: ['awareness', 'traffic'],
        deliverableRequirements: [
          '1x Instagram Reel',
          '2x Instagram Stories',
        ],
        doAndDonts: [
          'Do show product in first 3 seconds',
          'Do not make medical claims',
        ],
      ),
    ),
  ]);

  // --- Fraud ---
  store.putAll('fraud_reports', [
    const FraudRiskReport(
      entityId: MockIds.influencer1,
      riskScore: 0.12,
      isDuplicate: false,
      flaggedReasons: [],
      recommendation: 'Proceed with standard workflow.',
      riskLevel: 'low',
    ),
    const FraudRiskReport(
      entityId: 'inf-demo-7',
      riskScore: 0.62,
      isDuplicate: false,
      flaggedReasons: ['elevated_fake_follower_score', 'rapid_follower_spike'],
      recommendation: 'Request additional verification before shortlist.',
      riskLevel: 'medium',
    ),
  ]);

  // --- Recommendations ---
  store.putAll('recommendations', [
    const Recommendation(
      id: 'rec-demo-1',
      type: RecommendationType.creator,
      title: 'Arjun Creates',
      subtitle: 'Strong match for electronics awareness reels',
      matchScore: 0.91,
      targetId: MockIds.influencer1,
      tags: ['instagram', 'tech', 'lifestyle'],
      estimatedBudget: 25000,
      currency: 'INR',
    ),
    const Recommendation(
      id: 'rec-demo-2',
      type: RecommendationType.creator,
      title: 'Dev Tech Reviews',
      subtitle: 'YouTube depth for consideration stage',
      matchScore: 0.87,
      targetId: MockIds.influencer3,
      tags: ['youtube', 'gadgets'],
      estimatedBudget: 45000,
      currency: 'INR',
    ),
    const Recommendation(
      id: 'rec-demo-3',
      type: RecommendationType.campaign,
      title: 'Summer Launch Reels',
      subtitle: 'Open applications — good fit for your niche',
      matchScore: 0.84,
      targetId: MockIds.campaign1,
      tags: ['applications_open', 'paid'],
      estimatedBudget: 150000,
      currency: 'INR',
    ),
  ]);

  // --- Licensing ---
  store.putAll('licensing_grants', [
    const LicensingGrant(
      id: 'lic-grant-demo-1',
      collaborationId: MockIds.collab1,
      assetUrl:
          'https://cdn.demo.influencersmonk.local/assets/arjun_summer_reel.mp4',
      token: 'lic-tok-demo-1',
      scope: 'digital_only',
      territory: 'IN',
      durationDays: 180,
      fee: 15000,
      status: 'active',
      deliverableId: 'deliv-demo-1',
      createdAt: '2026-07-16T00:00:00Z',
      expiresAt: '2027-01-12T00:00:00Z',
    ),
  ]);

  // --- Notification preferences ---
  store.putAll('notification_prefs', [
    const NotificationPreferences(
      fcmWebPushEnabled: true,
      smsOptIn: false,
      smsPhoneNumber: '',
      emailEnabled: true,
      quietHoursEnabled: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '08:00',
      campaignUpdates: true,
      paymentAlerts: true,
      chatMessagesAlert: true,
    ),
  ]);

  // --- Briefs ---
  store.putAll('briefs', [
    const Brief(
      id: MockIds.brief1,
      brandId: MockIds.brandOrg1,
      campaignId: MockIds.campaign1,
      goals:
          'Drive awareness for Summer Launch among metro India 18–34 with authentic reels.',
      status: 'converted',
      budgetMinor: 15000000,
      currency: 'INR',
      productDescription: 'Monk Demo wireless earbuds',
      notes: 'Prefer creators with tech + lifestyle crossover.',
      managedFeeMode: 'none',
    ),
    const Brief(
      id: 'brief-demo-2',
      brandId: MockIds.brandOrg1,
      goals: 'Managed campaign for festive gifting SKUs.',
      status: 'submitted',
      budgetMinor: 8000000,
      currency: 'INR',
      productDescription: 'Gift bundles',
      managedFeeMode: 'fixed',
      agencyFeeMinor: 500000,
    ),
  ]);

  // --- Reviews ---
  store.putAll('reviews', [
    const Review(
      id: 'review-demo-1',
      collaborationId: MockIds.collab1,
      reviewerSide: 'brand',
      visible: true,
      rating: 5,
      body: 'Arjun delivered on time with strong creative direction.',
    ),
    const Review(
      id: 'review-demo-2',
      collaborationId: MockIds.collab1,
      reviewerSide: 'influencer',
      visible: true,
      rating: 4,
      body: 'Clear brief and fast feedback from the brand team.',
    ),
  ]);
}
