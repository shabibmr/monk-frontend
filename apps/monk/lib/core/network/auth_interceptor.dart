import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';

import '../session/session_cubit.dart';
import '../session/token_store.dart';

/// Bearer attach + single-flight refresh queue.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStore tokenStore,
    required SessionCubit sessionCubit,
    required Dio refreshDio,
    required void Function() onSessionInvalid,
  })  : _tokenStore = tokenStore,
        _sessionCubit = sessionCubit,
        _refreshDio = refreshDio,
        _onSessionInvalid = onSessionInvalid;

  // ignore: prefer_initializing_formals — named ctor params keep DI readable
  final TokenStore _tokenStore;
  final SessionCubit _sessionCubit;
  final Dio _refreshDio;
  final void Function() _onSessionInvalid;

  Completer<bool>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    final isAuthPublic = path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/verify-email') ||
        path.contains('/auth/resend-verification') ||
        path.contains('/auth/password/');

    if (!isAuthPublic) {
      final token = _tokenStore.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final path = err.requestOptions.path;
    if (path.contains('/auth/refresh') || path.contains('/auth/login')) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshTokens();
    if (!refreshed) {
      _onSessionInvalid();
      handler.next(err);
      return;
    }

    try {
      final token = _tokenStore.accessToken;
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $token';
      final response = await _refreshDio.fetch(opts);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _refreshTokens() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refresh = _tokenStore.refreshToken;
      if (refresh == null || refresh.isEmpty) {
        completer.complete(false);
        return false;
      }

      final api = AuthApi(_refreshDio);
      final pair = await api.refresh(refreshToken: refresh);
      await _tokenStore.saveTokens(
        accessToken: pair.accessToken,
        refreshToken: pair.refreshToken,
      );
      completer.complete(true);
      return true;
    } catch (_) {
      await _sessionCubit.clear();
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
