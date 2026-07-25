import 'package:get_it/get_it.dart';

import '../../features/agency/domain/repositories/agency_repository.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/barter/domain/repositories/barter_repository.dart';
import '../../features/billing/domain/repositories/billing_repository.dart';
import '../../features/briefs/domain/repositories/brief_repository.dart';
import '../../features/campaigns/domain/repositories/campaign_repository.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/content/domain/repositories/content_repository.dart';
import '../../features/contracts/domain/repositories/contract_repository.dart';
import '../../features/dashboards/domain/repositories/dashboard_repository.dart';
import '../../features/discovery/domain/repositories/discovery_repository.dart';
import '../../features/disputes/domain/repositories/dispute_repository.dart';
import '../../features/fraud/domain/repositories/fraud_repository.dart';
import '../../features/kyc/domain/repositories/kyc_repository.dart';
import '../../features/licensing/domain/repositories/licensing_repository.dart';
import '../../features/manager/domain/repositories/manager_repository.dart';
import '../../features/marketplace/domain/repositories/marketplace_repository.dart';
import '../../features/negotiations/domain/repositories/negotiation_repository.dart';
import '../../features/notifications/domain/repositories/notification_preferences_repository.dart';
import '../../features/onboarding_brand/domain/repositories/brand_repository.dart';
import '../../features/onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/publish/domain/repositories/publish_repository.dart';
import '../../features/recommendations/domain/repositories/recommendations_repository.dart';
import '../../features/referrals/domain/repositories/referrals_repository.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../mock/mock_seed_store.dart';
import '../mock/repositories/mock_agency_repository.dart';
import '../mock/repositories/mock_ai_repository.dart';
import '../mock/repositories/mock_analytics_repository.dart';
import '../mock/repositories/mock_auth_repository.dart';
import '../mock/repositories/mock_barter_repository.dart';
import '../mock/repositories/mock_billing_repository.dart';
import '../mock/repositories/mock_brand_repository.dart';
import '../mock/repositories/mock_brief_repository.dart';
import '../mock/repositories/mock_campaign_repository.dart';
import '../mock/repositories/mock_chat_repository.dart';
import '../mock/repositories/mock_content_repository.dart';
import '../mock/repositories/mock_contract_repository.dart';
import '../mock/repositories/mock_dashboard_repository.dart';
import '../mock/repositories/mock_discovery_repository.dart';
import '../mock/repositories/mock_dispute_repository.dart';
import '../mock/repositories/mock_fraud_repository.dart';
import '../mock/repositories/mock_influencer_repository.dart';
import '../mock/repositories/mock_kyc_repository.dart';
import '../mock/repositories/mock_licensing_repository.dart';
import '../mock/repositories/mock_manager_repository.dart';
import '../mock/repositories/mock_marketplace_repository.dart';
import '../mock/repositories/mock_negotiation_repository.dart';
import '../mock/repositories/mock_notification_preferences_repository.dart';
import '../mock/repositories/mock_payment_repository.dart';
import '../mock/repositories/mock_publish_repository.dart';
import '../mock/repositories/mock_recommendations_repository.dart';
import '../mock/repositories/mock_referrals_repository.dart';
import '../mock/repositories/mock_review_repository.dart';
import '../network/api_client_factory.dart';

/// Registers [MockSeedStore] and all 29 offline demo repositories.
void registerMockRepositories(
  GetIt getIt, {
  required MockSeedStore store,
  required AppConfig config,
}) {
  getIt
    ..registerSingleton<MockSeedStore>(store)
    ..registerLazySingleton<AuthRepository>(
      () => MockAuthRepository(
        store: store,
        tokenStore: getIt(),
        sessionCubit: getIt(),
      ),
    )
    ..registerLazySingleton<InfluencerRepository>(
      () => MockInfluencerRepository(store: store),
    )
    ..registerLazySingleton<BrandRepository>(
      () => MockBrandRepository(store: store),
    )
    ..registerLazySingleton<KycRepository>(
      () => MockKycRepository(store: store),
    )
    ..registerLazySingleton<ManagerRepository>(
      () => MockManagerRepository(store: store),
    )
    ..registerLazySingleton<DiscoveryRepository>(
      () => MockDiscoveryRepository(store),
    )
    ..registerLazySingleton<CampaignRepository>(
      () => MockCampaignRepository(store),
    )
    ..registerLazySingleton<BriefRepository>(
      () => MockBriefRepository(store),
    )
    ..registerLazySingleton<MarketplaceRepository>(
      () => MockMarketplaceRepository(store),
    )
    ..registerLazySingleton<NegotiationRepository>(
      () => MockNegotiationRepository(store),
    )
    ..registerLazySingleton<ContractRepository>(
      () => MockContractRepository(store),
    )
    ..registerLazySingleton<LicensingRepository>(
      () => MockLicensingRepository(store),
    )
    ..registerLazySingleton<DisputeRepository>(
      () => MockDisputeRepository(store),
    )
    ..registerLazySingleton<BarterRepository>(
      () => MockBarterRepository(store),
    )
    ..registerLazySingleton<ContentRepository>(
      () => MockContentRepository(store),
    )
    ..registerLazySingleton<PublishRepository>(
      () => MockPublishRepository(store),
    )
    ..registerLazySingleton<PaymentRepository>(
      () => MockPaymentRepository(store),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => MockDashboardRepository(store),
    )
    ..registerLazySingleton<ReviewRepository>(
      () => MockReviewRepository(store),
    )
    ..registerLazySingleton<AgencyRepository>(
      () => MockAgencyRepository(store),
    )
    ..registerLazySingleton<ChatRepository>(
      () => MockChatRepository(store),
    )
    ..registerLazySingleton<NotificationPreferencesRepository>(
      () => MockNotificationPreferencesRepository(store),
    )
    ..registerLazySingleton<AiRepository>(
      () => MockAiRepository(store: store, config: config),
    )
    ..registerLazySingleton<FraudRepository>(
      () => MockFraudRepository(store),
    )
    ..registerLazySingleton<BillingRepository>(
      () => MockBillingRepository(store),
    )
    ..registerLazySingleton<RecommendationsRepository>(
      () => MockRecommendationsRepository(store),
    )
    ..registerLazySingleton<ReferralsRepository>(
      () => MockReferralsRepository(store),
    )
    ..registerLazySingleton<AnalyticsRepository>(
      () => MockAnalyticsRepository(store),
    );
}
