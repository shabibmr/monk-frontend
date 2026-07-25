import 'package:get_it/get_it.dart';

import '../../features/agency/data/repositories/agency_repository_impl.dart';
import '../../features/agency/domain/repositories/agency_repository.dart';
import '../../features/ai/data/datasources/ai_remote_datasource.dart';
import '../../features/ai/data/repositories/ai_repository_impl.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/barter/data/repositories/barter_repository_impl.dart';
import '../../features/barter/domain/repositories/barter_repository.dart';
import '../../features/billing/data/datasources/billing_remote_datasource.dart';
import '../../features/billing/data/repositories/billing_repository_impl.dart';
import '../../features/billing/domain/repositories/billing_repository.dart';
import '../../features/briefs/data/repositories/brief_repository_impl.dart';
import '../../features/briefs/domain/repositories/brief_repository.dart';
import '../../features/campaigns/data/repositories/campaign_repository_impl.dart';
import '../../features/campaigns/domain/repositories/campaign_repository.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/content/data/repositories/content_repository_impl.dart';
import '../../features/content/domain/repositories/content_repository.dart';
import '../../features/contracts/data/repositories/contract_repository_impl.dart';
import '../../features/contracts/domain/repositories/contract_repository.dart';
import '../../features/dashboards/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboards/domain/repositories/dashboard_repository.dart';
import '../../features/discovery/data/repositories/discovery_repository_impl.dart';
import '../../features/discovery/domain/repositories/discovery_repository.dart';
import '../../features/disputes/data/repositories/dispute_repository_impl.dart';
import '../../features/disputes/domain/repositories/dispute_repository.dart';
import '../../features/fraud/data/datasources/fraud_remote_datasource.dart';
import '../../features/fraud/data/repositories/fraud_repository_impl.dart';
import '../../features/fraud/domain/repositories/fraud_repository.dart';
import '../../features/kyc/data/repositories/kyc_repository_impl.dart';
import '../../features/kyc/domain/repositories/kyc_repository.dart';
import '../../features/licensing/data/repositories/licensing_repository_impl.dart';
import '../../features/licensing/domain/repositories/licensing_repository.dart';
import '../../features/manager/data/repositories/manager_repository_impl.dart';
import '../../features/manager/domain/repositories/manager_repository.dart';
import '../../features/marketplace/data/repositories/marketplace_repository_impl.dart';
import '../../features/marketplace/domain/repositories/marketplace_repository.dart';
import '../../features/negotiations/data/repositories/negotiation_repository_impl.dart';
import '../../features/negotiations/domain/repositories/negotiation_repository.dart';
import '../../features/notifications/data/repositories/notification_preferences_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_preferences_repository.dart';
import '../../features/onboarding_brand/data/repositories/brand_repository_impl.dart';
import '../../features/onboarding_brand/domain/repositories/brand_repository.dart';
import '../../features/onboarding_influencer/data/repositories/influencer_repository_impl.dart';
import '../../features/onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/publish/data/repositories/publish_repository_impl.dart';
import '../../features/publish/domain/repositories/publish_repository.dart';
import '../../features/recommendations/data/datasources/recommendations_remote_datasource.dart';
import '../../features/recommendations/data/repositories/recommendations_repository_impl.dart';
import '../../features/recommendations/domain/repositories/recommendations_repository.dart';
import '../../features/referrals/data/repositories/referrals_repository_impl.dart';
import '../../features/referrals/domain/repositories/referrals_repository.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';

/// Registers HTTP data sources and repository implementations (API mode).
void registerHttpRepositories(GetIt getIt) {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt(),
        tokenStore: getIt(),
        sessionCubit: getIt(),
      ),
    )
    ..registerLazySingleton<InfluencerRepository>(
      () => InfluencerRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<BrandRepository>(
      () => BrandRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<KycRepository>(
      () => KycRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ManagerRepository>(
      () => ManagerRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<DiscoveryRepository>(
      () => DiscoveryRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<CampaignRepository>(
      () => CampaignRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<BriefRepository>(
      () => BriefRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<MarketplaceRepository>(
      () => MarketplaceRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<NegotiationRepository>(
      () => NegotiationRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ContractRepository>(
      () => ContractRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<LicensingRepository>(
      () => LicensingRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<DisputeRepository>(
      () => DisputeRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<BarterRepository>(
      () => BarterRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ContentRepository>(
      () => ContentRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<PublishRepository>(
      () => PublishRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ReviewRepository>(
      () => ReviewRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<AgencyRepository>(
      () => AgencyRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<NotificationPreferencesRepository>(
      () => NotificationPreferencesRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<AiRemoteDataSource>(
      () => AiRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<AiRepository>(
      () => AiRepositoryImpl(remote: getIt(), config: getIt()),
    )
    ..registerLazySingleton<FraudRemoteDataSource>(
      () => FraudRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<FraudRepository>(
      () => FraudRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<BillingRemoteDataSource>(
      () => BillingRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<BillingRepository>(
      () => BillingRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<RecommendationsRemoteDataSource>(
      () => RecommendationsRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<RecommendationsRepository>(
      () => RecommendationsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<AnalyticsRemoteDataSource>(
      () => AnalyticsRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ReferralsRepository>(
      () => ReferralsRepositoryImpl(getIt()),
    );
}
