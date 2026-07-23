import 'package:dio/dio.dart';

import '../session/session_cubit.dart';

/// Attaches X-Brand-Id / X-Profile-Id from SessionCubit.
class ContextHeadersInterceptor extends Interceptor {
  ContextHeadersInterceptor(this._session);
  final SessionCubit _session;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final brandId = _session.state.activeBrandId;
    final profileId = _session.state.activeProfileId;
    if (brandId != null && brandId.isNotEmpty) {
      options.headers['X-Brand-Id'] = brandId;
    }
    if (profileId != null && profileId.isNotEmpty) {
      options.headers['X-Profile-Id'] = profileId;
    }
    handler.next(options);
  }
}
