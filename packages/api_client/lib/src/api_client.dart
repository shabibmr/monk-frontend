import 'package:dio/dio.dart';

import 'apis/analytics_api.dart';
import 'apis/applications_api.dart';
import 'apis/auth_api.dart';
import 'apis/barter_api.dart';
import 'apis/brands_api.dart';
import 'apis/briefs_api.dart';
import 'apis/campaigns_api.dart';
import 'apis/content_api.dart';
import 'apis/contracts_api.dart';
import 'apis/discovery_api.dart';
import 'apis/health_api.dart';
import 'apis/influencers_api.dart';
import 'apis/kyc_api.dart';
import 'apis/managers_api.dart';
import 'apis/negotiations_api.dart';
import 'apis/payments_api.dart';
import 'apis/publish_api.dart';
import 'apis/recommendations_api.dart';
import 'apis/reviews_api.dart';
import 'apis/users_api.dart';
import 'models/error_envelope.dart';
import 'models/recommendation_models.dart';

/// Factory for the interim Dio-based API client.
/// Swap transport for OpenAPI generator output when backend T0.6 completes.
class MonkApiClient {
  MonkApiClient({
    required Dio dio,
  })  : _dio = dio,
        auth = AuthApi(dio),
        health = HealthApi(dio),
        users = UsersApi(dio),
        influencers = InfluencersApi(dio),
        brands = BrandsApi(dio),
        kyc = KycApi(dio),
        managers = ManagersApi(dio),
        discovery = DiscoveryApi(dio),
        campaigns = CampaignsApi(dio),
        briefs = BriefsApi(dio),
        applications = ApplicationsApi(dio),
        negotiations = NegotiationsApi(dio),
        contracts = ContractsApi(dio),
        barter = BarterApi(dio),
        content = ContentApi(dio),
        publish = PublishApi(dio),
        payments = PaymentsApi(dio),
        analytics = AnalyticsApi(dio),
        reviews = ReviewsApi(dio),
        recommendations = RecommendationsApi(dio);

  final Dio _dio;
  final AuthApi auth;
  final HealthApi health;
  final UsersApi users;
  final InfluencersApi influencers;
  final BrandsApi brands;
  final KycApi kyc;
  final ManagersApi managers;
  final DiscoveryApi discovery;
  final CampaignsApi campaigns;
  final BriefsApi briefs;
  final ApplicationsApi applications;
  final NegotiationsApi negotiations;
  final ContractsApi contracts;
  final BarterApi barter;
  final ContentApi content;
  final PublishApi publish;
  final PaymentsApi payments;
  final AnalyticsApi analytics;
  final ReviewsApi reviews;
  final RecommendationsApi recommendations;

  Dio get dio => _dio;

  static Dio createDio({
    required String baseUrl,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.addAll(interceptors);
    dio.interceptors.add(_ErrorEnvelopeInterceptor());
    return dio;
  }
}

class _ErrorEnvelopeInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('errorCode')) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: ApiException(ErrorEnvelope.fromJson(data)),
          message: data['message'] as String?,
        ),
      );
      return;
    }
    handler.next(err);
  }
}
