import '../../../features/auth/domain/entities/user.dart';
import '../../../features/dashboards/domain/entities/dashboard.dart';
import '../../../features/discovery/domain/entities/discovery.dart';
import '../../../features/manager/domain/entities/roster.dart';
import '../../../features/onboarding_brand/domain/entities/brand.dart';
import '../../../features/onboarding_influencer/domain/entities/onboarding.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Brands, discovery influencers, onboarding, manager roster, dashboards.
void seedProfiles(MockSeedStore store) {
  // --- Brands ---
  store.putAll('brands', [
    const Brand(
      id: MockIds.brandOrg1,
      companyName: 'Monk Demo Brand',
      website: 'https://demo.influencersmonk.local',
      industry: 'Consumer Electronics',
      gstVatNumber: '29AAAAA0000A1Z5',
      country: 'IN',
      timezone: 'Asia/Kolkata',
      address: 'Koramangala, Bengaluru, KA 560034',
      contactPerson: 'Priya Brand',
      contactEmail: MockIds.contactEmailBrand1,
      contactPhone: '+91 98765 43210',
      verificationStatus: 'verified',
    ),
    const Brand(
      id: MockIds.brandOrg2,
      companyName: 'Pulse Fit Co',
      website: 'https://pulsefit.example',
      industry: 'Health & Fitness',
      country: 'IN',
      timezone: 'Asia/Kolkata',
      contactPerson: 'Ops Lead',
      contactEmail: 'ops@pulsefit.example',
      verificationStatus: 'pending',
    ),
  ]);

  store.putAll('brand_members', [
    BrandMember(
      id: 'bm-${MockIds.brand1}',
      email: MockIds.contactEmailBrand1,
      memberRole: 'owner',
      permissions: const [
        'read',
        'write',
        'approve',
        'publish',
        'finance',
      ],
      inviteStatus: 'accepted',
    ),
    const BrandMember(
      id: 'bm-finance-1',
      email: MockIds.contactEmailBrandFinance,
      memberRole: 'finance',
      permissions: ['read', 'finance'],
      inviteStatus: 'accepted',
    ),
    const BrandMember(
      id: 'bm-invite-pending',
      email: 'reviewer@demo.influencersmonk.local',
      memberRole: 'content_reviewer',
      permissions: ['read', 'approve'],
      inviteStatus: 'pending',
    ),
  ]);

  // --- Discovery influencers (~12) ---
  final influencers = <DiscoveryInfluencer>[
    const DiscoveryInfluencer(
      id: MockIds.influencer1,
      displayName: 'Arjun Creates',
      biography:
          'Lifestyle & tech creator. 250k+ across IG/YT. Open to paid & hybrid collabs.',
      country: 'IN',
      city: 'Bengaluru',
      primaryPlatform: 'instagram',
      openToBarter: true,
      followersCount: 182000,
      engagementRate: 4.2,
      minPriceMinor: 2500000,
      currency: 'INR',
      creatorScore: 88,
      fakeFollowerScore: 8,
      credibilityGrade: 'A',
    ),
    const DiscoveryInfluencer(
      id: MockIds.influencer2,
      displayName: 'Nisha Vlogs',
      biography: 'Food & travel Reels specialist.',
      country: 'IN',
      city: 'Mumbai',
      primaryPlatform: 'instagram',
      openToBarter: true,
      followersCount: 95000,
      engagementRate: 5.1,
      minPriceMinor: 1200000,
      currency: 'INR',
      creatorScore: 82,
      fakeFollowerScore: 12,
      credibilityGrade: 'A',
    ),
    const DiscoveryInfluencer(
      id: MockIds.influencer3,
      displayName: 'Dev Tech Reviews',
      biography: 'YouTube gadget reviews and unboxings.',
      country: 'IN',
      city: 'Hyderabad',
      primaryPlatform: 'youtube',
      openToBarter: false,
      followersCount: 310000,
      engagementRate: 3.4,
      minPriceMinor: 4500000,
      currency: 'INR',
      creatorScore: 91,
      fakeFollowerScore: 5,
      credibilityGrade: 'A+',
    ),
    const DiscoveryInfluencer(
      id: 'inf-demo-4',
      displayName: 'Kira Skincare',
      biography: 'Beauty routines and honest product tests.',
      country: 'IN',
      city: 'Delhi',
      primaryPlatform: 'instagram',
      openToBarter: true,
      followersCount: 67000,
      engagementRate: 6.0,
      minPriceMinor: 800000,
      currency: 'INR',
      creatorScore: 79,
      fakeFollowerScore: 15,
      credibilityGrade: 'B+',
    ),
    const DiscoveryInfluencer(
      id: 'inf-demo-5',
      displayName: 'Omar Fitness',
      biography: 'Strength training tips for busy professionals.',
      country: 'AE',
      city: 'Dubai',
      primaryPlatform: 'instagram',
      openToBarter: false,
      followersCount: 140000,
      engagementRate: 3.9,
      minPriceMinor: 3500000,
      currency: 'INR',
      creatorScore: 85,
      fakeFollowerScore: 10,
      credibilityGrade: 'A',
    ),
    const DiscoveryInfluencer(
      id: 'inf-demo-6',
      displayName: 'Lina Eco',
      biography: 'Sustainable fashion and thrift finds.',
      country: 'IN',
      city: 'Pune',
      primaryPlatform: 'instagram',
      openToBarter: true,
      followersCount: 42000,
      engagementRate: 7.2,
      minPriceMinor: 500000,
      currency: 'INR',
      creatorScore: 76,
      fakeFollowerScore: 18,
      credibilityGrade: 'B',
    ),
    const DiscoveryInfluencer(
      id: 'inf-demo-7',
      displayName: 'Ravi Shorts',
      biography: 'Comedy YouTube Shorts & memes.',
      country: 'IN',
      city: 'Jaipur',
      primaryPlatform: 'youtube',
      openToBarter: true,
      followersCount: 520000,
      engagementRate: 2.8,
      minPriceMinor: 2000000,
      currency: 'INR',
      creatorScore: 74,
      fakeFollowerScore: 22,
      credibilityGrade: 'B',
    ),
    const DiscoveryInfluencer(
      id: 'inf-demo-8',
      displayName: 'Sofia Parenting',
      biography: 'Parenting hacks and family product reviews.',
      country: 'IN',
      city: 'Chennai',
      primaryPlatform: 'instagram',
      openToBarter: false,
      followersCount: 88000,
      engagementRate: 4.8,
      minPriceMinor: 1500000,
      currency: 'INR',
      creatorScore: 80,
      fakeFollowerScore: 11,
      credibilityGrade: 'A-',
    ),
    const DiscoveryInfluencer(
      id: 'inf-demo-9',
      displayName: 'Chen Gaming',
      biography: 'Mobile & PC gaming streams highlights.',
      country: 'IN',
      city: 'Kolkata',
      primaryPlatform: 'youtube',
      openToBarter: true,
      followersCount: 210000,
      engagementRate: 3.1,
      minPriceMinor: 2800000,
      currency: 'INR',
      creatorScore: 83,
      fakeFollowerScore: 9,
      credibilityGrade: 'A',
    ),
    const DiscoveryInfluencer(
      id: 'inf-demo-10',
      displayName: 'Aisha Finance',
      biography: 'Personal finance literacy for Gen Z.',
      country: 'IN',
      city: 'Ahmedabad',
      primaryPlatform: 'linkedin',
      openToBarter: false,
      followersCount: 56000,
      engagementRate: 2.5,
      minPriceMinor: 1800000,
      currency: 'INR',
      creatorScore: 87,
      fakeFollowerScore: 4,
      credibilityGrade: 'A',
    ),
    const DiscoveryInfluencer(
      id: 'inf-demo-11',
      displayName: 'Marco Travel',
      biography: 'Weekend getaways and hotel staycations.',
      country: 'IN',
      city: 'Goa',
      primaryPlatform: 'instagram',
      openToBarter: true,
      followersCount: 125000,
      engagementRate: 5.5,
      minPriceMinor: 2200000,
      currency: 'INR',
      creatorScore: 81,
      fakeFollowerScore: 14,
      credibilityGrade: 'A-',
    ),
    const DiscoveryInfluencer(
      id: 'inf-demo-12',
      displayName: 'Fresh Creator (incomplete)',
      biography: null,
      country: 'IN',
      city: null,
      primaryPlatform: null,
      openToBarter: null,
      followersCount: null,
      engagementRate: null,
      minPriceMinor: null,
      currency: 'INR',
      creatorScore: null,
      fakeFollowerScore: null,
      credibilityGrade: null,
    ),
  ];

  store.putAll('discovery_influencers', influencers);
  store.putAll('influencers', influencers);

  // --- Onboarding statuses ---
  store.putAll('onboarding_statuses', [
    const OnboardingStatus(
      profileId: MockIds.influencer1,
      progress: OnboardingProgress(
        step1: true,
        step2: true,
        step3: true,
        step4: true,
        step5: true,
        step6: true,
      ),
      nextStep: 7,
      completed: true,
      verificationStatus: 'approved',
    ),
    const OnboardingStatus(
      profileId: MockIds.influencer2,
      progress: OnboardingProgress(
        step1: true,
        step2: true,
        step3: true,
        step4: true,
        step5: true,
        step6: true,
      ),
      nextStep: 7,
      completed: true,
      verificationStatus: 'approved',
    ),
    const OnboardingStatus(
      profileId: MockIds.influencer3,
      progress: OnboardingProgress(
        step1: true,
        step2: true,
        step3: true,
        step4: true,
        step5: true,
        step6: true,
      ),
      nextStep: 7,
      completed: true,
      verificationStatus: 'pending',
    ),
    const OnboardingStatus(
      profileId: MockIds.creatorFresh,
      progress: OnboardingProgress(
        step1: true,
        step2: false,
        step3: false,
        step4: false,
        step5: false,
        step6: false,
      ),
      nextStep: 2,
      completed: false,
      verificationStatus: null,
    ),
  ]);

  // Social accounts for complete creator (used by influencer repo listSocial).
  store.putAll('social_accounts', [
    const SocialAccount(
      id: 'social-ig-1',
      platform: 'instagram',
      handle: '@arjuncreates',
      followersCount: 182000,
      declaredOnly: false,
    ),
    const SocialAccount(
      id: 'social-yt-1',
      platform: 'youtube',
      handle: 'Arjun Creates',
      followersCount: 94000,
      declaredOnly: false,
    ),
  ]);

  // Pricing lines for Arjun (optional catalog for mock repo).
  store.putAll('pricing_lines', [
    const PricingLine(
      deliverableType: 'instagram_reel',
      priceMinor: 2500000,
      currency: 'INR',
    ),
    const PricingLine(
      deliverableType: 'instagram_story',
      priceMinor: 800000,
      currency: 'INR',
    ),
    const PricingLine(
      deliverableType: 'youtube_video',
      priceMinor: 4500000,
      currency: 'INR',
    ),
  ]);

  // --- Manager roster: manager → creator1 ---
  store.putAll('manager_roster', [
    const RosterEntry(
      profileId: MockIds.influencer1,
      displayName: 'Arjun Creates',
      verificationStatus: 'approved',
      country: 'IN',
      permissions: [
        'view_earnings',
        'manage_applications',
        'manage_content',
      ],
      inviteStatus: 'accepted',
      openApplications: 2,
      contentDue: 1,
      payableMinor: 1850000,
      currency: 'INR',
    ),
  ]);

  // Profile access row for manager on creator1.
  store.putAll('profile_access', [
    ProfileAccessRow(
      id: 'access-manager-1',
      userId: MockIds.manager1,
      accessRole: 'manager',
      permissions: const [
        'view_earnings',
        'manage_applications',
        'manage_content',
      ],
      inviteStatus: 'accepted',
    ),
    ProfileAccessRow(
      id: 'access-owner-1',
      userId: MockIds.creator1,
      accessRole: 'owner',
      permissions: const [
        'view_earnings',
        'manage_applications',
        'manage_content',
        'withdraw',
      ],
      inviteStatus: 'accepted',
    ),
  ]);

  // --- Sessions ---
  store.putAll('sessions', [
    DeviceSession(
      id: MockIds.session1,
      current: true,
      userAgent: 'Chrome 131 / Windows',
      ipAddress: '203.0.113.10',
      createdAt: DateTime.utc(2026, 7, 20, 9, 30),
    ),
    DeviceSession(
      id: 'session-demo-2',
      current: false,
      userAgent: 'Safari / iPhone',
      ipAddress: '198.51.100.22',
      createdAt: DateTime.utc(2026, 7, 18, 14, 5),
    ),
  ]);

  // --- Dashboards (singles) ---
  store.singles['brand_dashboard'] = const BrandDashboard(
    brandId: MockIds.brandOrg1,
    campaigns: {
      'draft': 1,
      'applications_open': 1,
      'in_progress': 1,
      'completed': 1,
      'published': 1,
    },
    pendingApprovals: 2,
    spendMinor: 12500000,
    pendingPaymentsCount: 1,
    pendingPaymentsAmountMinor: 2500000,
    metrics: MetricTotals(
      reach: 420000,
      impressions: 980000,
      views: 310000,
      likes: 28000,
      comments: 2100,
      shares: 900,
      clicks: 5400,
      engagement: 36400,
      engagementRateBps: 370,
    ),
    managedCollaborationsActive: 1,
    upcomingPosts: 2,
    automatedSync: true,
  );

  store.singles['profile_dashboard'] = const ProfileDashboard(
    profileId: MockIds.influencer1,
    invitations: 1,
    pendingContent: 1,
    earningsPendingMinor: 1850000,
    earningsReleasedMinor: 7200000,
    deadlines: [
      {
        'label': 'Reel revision due',
        'dueAt': '2026-07-25',
        'collaborationId': MockIds.collab1,
      },
    ],
    metrics: MetricTotals(
      reach: 210000,
      impressions: 450000,
      views: 180000,
      likes: 15000,
      comments: 980,
      shares: 420,
      clicks: 2100,
      engagement: 18500,
      engagementRateBps: 420,
    ),
    automatedSync: true,
  );

  store.singles['manager_dashboard'] = const ManagerDashboard(
    rosterSize: 1,
    openTasks: 3,
    collaborations: 2,
    metrics: MetricTotals(
      reach: 210000,
      impressions: 450000,
      views: 180000,
      likes: 15000,
      comments: 980,
      shares: 420,
      clicks: 2100,
      engagement: 18500,
      engagementRateBps: 420,
    ),
    earningsRollupMinor: 1850000,
    rosterProfileIds: [MockIds.influencer1],
    automatedSync: true,
  );
}
