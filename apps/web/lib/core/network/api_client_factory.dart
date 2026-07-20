import 'package:api_client/api_client.dart';

import '../session/session_cubit.dart';
import '../session/token_store.dart';
import 'auth_interceptor.dart';
import 'context_headers.dart';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    this.environment = 'local',
    this.enableAi = true,
  });

  final String apiBaseUrl;
  final String environment;
  final bool enableAi;

  static AppConfig fromEnvironment() {
    const base = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000',
    );
    const env = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'local',
    );
    const enableAiFlag = bool.fromEnvironment(
      'ENABLE_AI',
      defaultValue: true,
    );
    return const AppConfig(
      apiBaseUrl: base,
      environment: env,
      enableAi: enableAiFlag,
    );
  }
}

class ApiClientFactory {
  static MonkApiClient create({
    required AppConfig config,
    required TokenStore tokenStore,
    required SessionCubit sessionCubit,
    required void Function() onSessionInvalid,
  }) {
    // Clean Dio for refresh + retries (no auth interceptor recursion).
    final bare = MonkApiClient.createDio(baseUrl: config.apiBaseUrl);

    final dio = MonkApiClient.createDio(baseUrl: config.apiBaseUrl);
    dio.interceptors.insert(
      0,
      AuthInterceptor(
        tokenStore: tokenStore,
        sessionCubit: sessionCubit,
        refreshDio: bare,
        onSessionInvalid: onSessionInvalid,
      ),
    );
    dio.interceptors.insert(1, ContextHeadersInterceptor(sessionCubit));

    return MonkApiClient(dio: dio);
  }
}
