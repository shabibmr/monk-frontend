import 'package:api_client/api_client.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/agency/presentation/bloc/agency_console_bloc.dart';
import '../../features/ai/presentation/bloc/ai_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/fraud/presentation/bloc/fraud_bloc.dart';
import '../../features/notifications/presentation/bloc/notification_preferences_bloc.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/publish/presentation/bloc/schedule_publish_bloc.dart';
import '../../features/recommendations/presentation/bloc/recommendations_bloc.dart';
import '../../features/referrals/presentation/bloc/referral_rewards_bloc.dart';
import '../mock/mock_seed_store.dart';
import '../network/api_client_factory.dart';
import '../session/session_cubit.dart';
import '../session/token_store.dart';
import 'register_http_repositories.dart';
import 'register_mock_repositories.dart';

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

  final client = ApiClientFactory.create(
    config: appConfig,
    tokenStore: tokenStore,
    sessionCubit: session,
    onSessionInvalid: session.clear,
  );
  getIt.registerSingleton<MonkApiClient>(client);

  if (appConfig.useMocks) {
    final store = MockSeedStore(latencyMs: appConfig.mockLatencyMs)
      ..initialize();
    registerMockRepositories(getIt, store: store, config: appConfig);
  } else {
    registerHttpRepositories(getIt);
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
