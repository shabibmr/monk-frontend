/// Business routes live under Nest global prefix `api/v1`.
/// Health/metrics stay at server root (no prefix).
abstract final class ApiPaths {
  static const v1 = '/api/v1';

  // Auth
  static const register = '$v1/auth/register';
  static const login = '$v1/auth/login';
  static const refresh = '$v1/auth/refresh';
  static const logout = '$v1/auth/logout';
  static const verifyEmail = '$v1/auth/verify-email';
  static const resendVerification = '$v1/auth/resend-verification';
  static const forgotPassword = '$v1/auth/password/forgot';
  static const resetPassword = '$v1/auth/password/reset';
  static const sessions = '$v1/auth/sessions';
  static String session(String id) => '$v1/auth/sessions/$id';

  // Users
  static const usersMe = '$v1/users/me';

  // Influencers / onboarding
  static const influencerProfiles = '$v1/influencer-profiles';
  static const influencerMe = '$v1/influencer-profiles/me';
  static const influencerOnboarding = '$v1/influencer-profiles/me/onboarding';
  static String platforms(String id) =>
      '$v1/influencer-profiles/$id/platform-declarations';
  static String categories(String id) =>
      '$v1/influencer-profiles/$id/categories-audience';
  static String pricing(String id) => '$v1/influencer-profiles/$id/pricing';
  static String portfolio(String id) =>
      '$v1/influencer-profiles/$id/portfolio';
  static String portfolioItem(String id, String itemId) =>
      '$v1/influencer-profiles/$id/portfolio/$itemId';
  static String onboardingComplete(String id) =>
      '$v1/influencer-profiles/$id/onboarding/complete';

  // Social
  static String oauthStart(String platform) =>
      '$v1/social-accounts/oauth/$platform/start';
  static String socialAccounts(String profileId) =>
      '$v1/profiles/$profileId/social-accounts';
  static String socialUnlink(String id) => '$v1/social-accounts/$id';
  static const socialManual = '$v1/social-accounts/manual-declaration';

  // Profile access (manager invite)
  static String profileAccess(String profileId) =>
      '$v1/profiles/$profileId/access';
  static String profileAccessMember(String profileId, String id) =>
      '$v1/profiles/$profileId/access/$id';
  static String managerInviteAccept(String token) =>
      '$v1/profile-access/invites/$token/accept';
  static String profileSettings(String profileId) =>
      '$v1/profiles/$profileId/settings';

  // Managers
  static const managersRoster = '$v1/managers/me/roster';
  static const managersEarnings = '$v1/managers/me/earnings';
  static const managersAnalytics = '$v1/managers/me/analytics';
  static const managersSwitchContext = '$v1/managers/me/switch-context';
  static const managersActAsCheck = '$v1/managers/me/act-as/check';
  static String managersProfileAccess(String profileId) =>
      '$v1/managers/me/profiles/$profileId/access';
  static const managersWithdrawalRequest = '$v1/managers/me/withdrawals/request';

  // Referrals
  static const referralInvites = '$v1/referrals/invites';

  // Brands
  static const brands = '$v1/brands';
  static const brandsMe = '$v1/brands/me';
  static String brand(String id) => '$v1/brands/$id';
  static String brandMembers(String brandId) => '$v1/brands/$brandId/members';
  static String brandMember(String brandId, String memberId) =>
      '$v1/brands/$brandId/members/$memberId';
  static String brandInviteAccept(String token) =>
      '$v1/brands/members/invites/$token/accept';

  // KYC + compliance
  static const kyc = '$v1/kyc';
  static const kycMe = '$v1/kyc/me';
  static const disclosureRules = '$v1/disclosure-rules';
  static const rejectionTemplates = '$v1/rejection-reason-templates';
  static const complianceUaeGate = '$v1/compliance/uae-gate';

  // Admin verification
  static const adminVerificationQueue = '$v1/admin/verification-queue';
  static String adminKycApprove(String id) =>
      '$v1/admin/verification-queue/$id/approve';
  static String adminKycReject(String id) =>
      '$v1/admin/verification-queue/$id/reject';
  static String adminLicenseVerify(String id) =>
      '$v1/admin/licenses/$id/verify';
  static String adminUserSuspend(String id) =>
      '$v1/admin/users/$id/suspend';
  static String adminUserReinstate(String id) =>
      '$v1/admin/users/$id/reinstate';

  // Managed briefs (T1.7)
  static const briefs = '$v1/briefs';
  static const briefsMe = '$v1/briefs/me';
  static const agencyBriefs = '$v1/agency/briefs';
  static String agencyBriefTriage(String id) =>
      '$v1/agency/briefs/$id/triage';
  static String agencyBriefConvert(String id) =>
      '$v1/agency/briefs/$id/convert';
  static String agencyAssignInfluencers(String campaignId) =>
      '$v1/agency/campaigns/$campaignId/assign-influencers';

  // Campaigns
  static const campaigns = '$v1/campaigns';
  static String campaign(String id) => '$v1/campaigns/$id';
  static String campaignTransitions(String id) =>
      '$v1/campaigns/$id/transitions';
  static String campaignDeliverables(String id) =>
      '$v1/campaigns/$id/deliverables';
  static String campaignDeliverable(String id, String dId) =>
      '$v1/campaigns/$id/deliverables/$dId';

  // Marketplace + applications (T1.8)
  static const marketplaceCampaigns = '$v1/marketplace/campaigns';
  static String marketplaceCampaign(String id) =>
      '$v1/marketplace/campaigns/$id';
  static String campaignApplications(String campaignId) =>
      '$v1/campaigns/$campaignId/applications';
  static String campaignInvites(String campaignId) =>
      '$v1/campaigns/$campaignId/invites';
  static const applicationsMe = '$v1/applications/me';
  static String brandApplications(String brandId) =>
      '$v1/brands/$brandId/applications';
  static String applicationShortlist(String id) =>
      '$v1/applications/$id/shortlist';
  static String applicationReject(String id) =>
      '$v1/applications/$id/reject';
  static String applicationWithdraw(String id) =>
      '$v1/applications/$id/withdraw';
  static String applicationAcceptInvite(String id) =>
      '$v1/applications/$id/accept-invite';
  static String applicationDeclineInvite(String id) =>
      '$v1/applications/$id/decline-invite';

  // Negotiations (T1.9)
  static String applicationNegotiations(String applicationId) =>
      '$v1/applications/$applicationId/negotiations';
  static String negotiation(String id) => '$v1/negotiations/$id';
  static String negotiationOffers(String id) =>
      '$v1/negotiations/$id/offers';
  static String negotiationAcceptOffer(String id, String offerId) =>
      '$v1/negotiations/$id/offers/$offerId/accept';
  static String negotiationDeclineOffer(String id, String offerId) =>
      '$v1/negotiations/$id/offers/$offerId/decline';
  static String negotiationCancel(String id) =>
      '$v1/negotiations/$id/cancel';

  // Contracts (T1.10)
  static String collaborationContract(String collaborationId) =>
      '$v1/collaborations/$collaborationId/contract';
  static String collaborationContractAccept(String collaborationId) =>
      '$v1/collaborations/$collaborationId/contract/accept';
  static String collaborationContractGenerate(String collaborationId) =>
      '$v1/collaborations/$collaborationId/contract/generate';

  // Barter fulfillment (T1.11)
  static String collaborationBarter(String collaborationId) =>
      '$v1/collaborations/$collaborationId/barter';
  static String collaborationBarterShip(String collaborationId) =>
      '$v1/collaborations/$collaborationId/barter/ship';
  static String collaborationBarterReceive(String collaborationId) =>
      '$v1/collaborations/$collaborationId/barter/receive';
  static String collaborationBarterEvidence(String collaborationId) =>
      '$v1/collaborations/$collaborationId/barter/evidence';
  static String collaborationContentOpen(String collaborationId) =>
      '$v1/collaborations/$collaborationId/content/open';

  // Content workflow (T1.12)
  static String collaborationSubmissions(String collaborationId) =>
      '$v1/collaborations/$collaborationId/submissions';
  static String collaborationDeliverableVersions(
    String collaborationId,
    String deliverableId,
  ) =>
      '$v1/collaborations/$collaborationId/deliverables/$deliverableId/versions';
  static String contentVersion(String id) => '$v1/content-versions/$id';
  static String contentVersionSubmit(String id) =>
      '$v1/content-versions/$id/submit';
  static String contentVersionReview(String id) =>
      '$v1/content-versions/$id/review';
  static String contentVersionComments(String id) =>
      '$v1/content-versions/$id/comments';

  // Manual publish (T1.13)
  static String publishedPost(String collaborationId, String deliverableId) =>
      '$v1/collaborations/$collaborationId/deliverables/$deliverableId/published-post';
  static String collaborationPublishedPosts(String collaborationId) =>
      '$v1/collaborations/$collaborationId/published-posts';
  static String publishedPostManualConfirm(String id) =>
      '$v1/published-posts/$id/manual-confirm';

  // Payments + ledger (T1.14)
  static String collaborationFunding(String collaborationId) =>
      '$v1/collaborations/$collaborationId/funding';
  static String collaborationPayments(String collaborationId) =>
      '$v1/collaborations/$collaborationId/payments';
  static String paymentRelease(String id) => '$v1/payments/$id/release';
  static String paymentRefund(String id) => '$v1/payments/$id/refund';
  static String profileEarnings(String profileId) =>
      '$v1/profiles/$profileId/earnings';
  static String profilePayouts(String profileId) =>
      '$v1/profiles/$profileId/payouts';
  static String payoutConfirm(String id) => '$v1/payouts/$id/confirm';
  static const invoices = '$v1/invoices';
  static String invoice(String id) => '$v1/invoices/$id';

  // Analytics dashboards (T1.15)
  static String brandDashboard(String brandId) =>
      '$v1/brands/$brandId/dashboard';
  static String profileDashboard(String profileId) =>
      '$v1/profiles/$profileId/dashboard';
  static const managerDashboard = '$v1/managers/me/dashboard';
  static String publishedPostMetrics(String publishedPostId) =>
      '$v1/published-posts/$publishedPostId/metrics';

  // Reviews (T1.16)
  static String collaborationReviews(String collaborationId) =>
      '$v1/collaborations/$collaborationId/reviews';
  static String profileReviews(String profileId) =>
      '$v1/profiles/$profileId/reviews';
  static String brandReviews(String brandId) =>
      '$v1/brands/$brandId/reviews';
  static String reviewHide(String id) => '$v1/reviews/$id/hide';

  // Discovery + shortlists
  static const discoveryInfluencers = '$v1/discovery/influencers';
  static String brandShortlists(String brandId) =>
      '$v1/brands/$brandId/shortlists';
  static String brandShortlist(String brandId, String id) =>
      '$v1/brands/$brandId/shortlists/$id';
  static String brandShortlistItems(String brandId, String id) =>
      '$v1/brands/$brandId/shortlists/$id/items';
  static String brandShortlistItem(
    String brandId,
    String id,
    String itemId,
  ) =>
      '$v1/brands/$brandId/shortlists/$id/items/$itemId';

  // Phase 2 - Metrics & Analytics (T2.1, T2.2)
  static String publishedPostAutomatedMetrics(String id) =>
      '$v1/published-posts/$id/automated-metrics';
  static const analyticsReports = '$v1/analytics/reports';
  static const analyticsExport = '$v1/analytics/export';
  static const utmLinks = '$v1/utm-links';

  // Phase 2 - Contracts v2 & Licensing (T2.3, T2.8)
  static const contractTemplates = '$v1/contract-templates';
  static String contractAmendments(String id) =>
      '$v1/contracts/$id/amendments';
  static const licensingGrants = '$v1/licensing-grants';
  static String licensingGrant(String id) => '$v1/licensing-grants/$id';

  // Phase 2 - Agency Console (T2.4)
  static const agencyAssets = '$v1/agency/assets';
  static const agencyKanban = '$v1/agency/kanban';

  // Phase 2 - Chat & Preferences (T2.5)
  static const chatThreads = '$v1/chat/threads';
  static String chatThreadMessages(String id) => '$v1/chat/threads/$id/messages';
  static const notificationPreferences = '$v1/notification-preferences';

  // Phase 2 - Discovery Scores & Demographics (T2.6)
  static const discoveryScores = '$v1/discovery/scores';
  static const influencerDemographics = '$v1/influencer-demographics';

  // Phase 2 - Referral Rewards (T2.7)
  static const referralRewards = '$v1/referrals/rewards';
  static const adminReferralRewards = '$v1/admin/referral-rewards';

  // Phase 2 - Disputes & Data Erasure (T2.9)
  static const disputes = '$v1/disputes';
  static String dispute(String id) => '$v1/disputes/$id';
  static const adminDisputes = '$v1/admin/disputes';
  static const dataErasureRequests = '$v1/data-erasure-requests';

  // Phase 3 - AI & Fraud Risk (T3.1, T3.3)
  static const aiAssist = '$v1/ai/assist';
  static const fraudCheck = '$v1/fraud/check';
  static String fraudCheckEntity(String id) => '$v1/fraud/check/$id';

  // Phase 3 - Multi-currency & Billing (T3.6)
  static const billingSubscriptions = '$v1/billing/subscriptions';
  static const billingInvoices = '$v1/billing/invoices';
  static const billingPlans = '$v1/billing/plans';
  static String billingSubscribe(String planId) => '$v1/billing/subscribe/$planId';

  // Phase 3 - Recommendations & Publishing (T3.2, T3.4)
  static const recommendations = '$v1/recommendations';
  static String campaignRecommendations(String campaignId) =>
      '$v1/campaigns/$campaignId/recommendations';
  static String publishSchedule(String deliverableId) =>
      '$v1/deliverables/$deliverableId/publish-schedule';
  static const publishSchedules = '$v1/publish-schedules';
  static String publishScheduleCancel(String scheduleId) =>
      '$v1/publish-schedules/$scheduleId/cancel';

  // Health (root)
  static const health = '/health';
  static const healthReady = '/health/ready';
}
