import 'package:api_client/api_client.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/agency/data/repositories/agency_repository_impl.dart';
import '../../features/agency/domain/repositories/agency_repository.dart';
import '../../features/agency/presentation/bloc/agency_console_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/barter/data/repositories/barter_repository_impl.dart';
import '../../features/barter/domain/repositories/barter_repository.dart';
import '../../features/briefs/data/repositories/brief_repository_impl.dart';
import '../../features/briefs/domain/repositories/brief_repository.dart';
import '../../features/campaigns/data/repositories/campaign_repository_impl.dart';
import '../../features/campaigns/domain/repositories/campaign_repository.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
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
import '../../features/notifications/presentation/bloc/notification_preferences_bloc.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/onboarding_brand/data/repositories/brand_repository_impl.dart';
import '../../features/onboarding_brand/domain/repositories/brand_repository.dart';
import '../../features/onboarding_influencer/data/repositories/influencer_repository_impl.dart';
import '../../features/onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/publish/data/repositories/publish_repository_impl.dart';
import '../../features/publish/domain/repositories/publish_repository.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../../features/referrals/data/repositories/referrals_repository_impl.dart';
import '../../features/referrals/domain/repositories/referrals_repository.dart';
import '../../features/referrals/presentation/bloc/referral_rewards_bloc.dart';
import '../../features/billing/data/datasources/billing_remote_datasource.dart';
import '../../features/billing/data/repositories/billing_repository_impl.dart';
import '../../features/billing/domain/repositories/billing_repository.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
import '../../features/ai/data/datasources/ai_remote_datasource.dart';
import '../../features/ai/data/repositories/ai_repository_impl.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';
import '../../features/ai/presentation/bloc/ai_bloc.dart';
import '../../features/fraud/data/datasources/fraud_remote_datasource.dart';
import '../../features/fraud/data/repositories/fraud_repository_impl.dart';
import '../../features/fraud/domain/repositories/fraud_repository.dart';
import '../../features/fraud/presentation/bloc/fraud_bloc.dart';
import '../../features/recommendations/data/datasources/recommendations_remote_datasource.dart';
import '../../features/recommendations/data/repositories/recommendations_repository_impl.dart';
import '../../features/recommendations/domain/repositories/recommendations_repository.dart';
import '../../features/recommendations/presentation/bloc/recommendations_bloc.dart';
import '../../features/publish/presentation/bloc/schedule_publish_bloc.dart';
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
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
import '../session/session_cubit.dart';
import '../session/token_store.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({AppConfig? config}) async {
  final appConfig = config ?? AppConfig.fromEnvironment();
  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerSingleton<AppConfig>(appConfig)
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<TokenStore>(TokenStore(prefs))
    ..registerSingleton<SessionCubit>(SessionCubit(getIt()))
    ..registerSingleton<NotificationsCubit>(NotificationsCubit());

  final session = getIt<SessionCubit>();
  final tokenStore = getIt<TokenStore>();

  late final MonkApiClient client;
  client = ApiClientFactory.create(
    config: appConfig,
    tokenStore: tokenStore,
    sessionCubit: session,
    onSessionInvalid: () {
      session.clear();
    },
  );

  getIt.registerSingleton<MonkApiClient>(client);

  if (appConfig.useMocks) {
    final store = MockSeedStore(latencyMs: appConfig.mockLatencyMs)..initialize();
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
        () => MockAiRepository(store: store, config: appConfig),
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
  } else {
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

  getIt
    ..registerFactory<AgencyConsoleBloc>(
      () => AgencyConsoleBloc(getIt()),
    )
    ..registerFactory<ChatBloc>(
      () => ChatBloc(getIt()),
    )
    ..registerFactory<NotificationPreferencesBloc>(
      () => NotificationPreferencesBloc(getIt()),
    )
    ..registerFactory<AiBloc>(
      () => AiBloc(getIt()),
    )
    ..registerFactory<FraudBloc>(
      () => FraudBloc(getIt()),
    )
    ..registerFactory<BillingBloc>(
      () => BillingBloc(getIt()),
    )
    ..registerFactory<RecommendationsBloc>(
      () => RecommendationsBloc(getIt()),
    )
    ..registerFactory<ReferralRewardsBloc>(
      () => ReferralRewardsBloc(getIt()),
    )
    ..registerFactory<SchedulePublishBloc>(
      () => SchedulePublishBloc(getIt()),
    )
    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        authRepository: getIt(),
        sessionCubit: getIt(),
        influencerRepository: getIt(),
        brandRepository: getIt(),
      ),
    );

  await session.hydrate();
}
