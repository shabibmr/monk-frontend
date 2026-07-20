import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/auth_models.dart';

class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  Future<RegisterResponseDto> register({
    required String email,
    required String password,
    required String role,
    required bool acceptTerms,
    String? fullName,
    String? phone,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.register,
      data: {
        'email': email,
        'password': password,
        'role': role,
        'acceptTerms': acceptTerms,
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
      },
    );
    return RegisterResponseDto.fromJson(res.data!);
  }

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.login,
      data: {'email': email, 'password': password},
    );
    return LoginResponseDto.fromJson(res.data!);
  }

  Future<TokenPairDto> refresh({required String refreshToken}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.refresh,
      data: {'refreshToken': refreshToken},
    );
    return TokenPairDto.fromJson(res.data!);
  }

  Future<void> logout() async {
    await _dio.post<void>(ApiPaths.logout);
  }

  Future<PublicUserDto> verifyEmail({required String token}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.verifyEmail,
      data: {'token': token},
    );
    return PublicUserDto.fromJson(res.data!);
  }

  Future<void> resendVerification({required String email}) async {
    await _dio.post<void>(
      ApiPaths.resendVerification,
      data: {'email': email},
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _dio.post<void>(
      ApiPaths.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _dio.post<void>(
      ApiPaths.resetPassword,
      data: {'token': token, 'password': password},
    );
  }

  Future<SessionsListDto> listSessions() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiPaths.sessions);
    return SessionsListDto.fromJson(res.data!);
  }

  Future<void> revokeSession(String sessionId) async {
    await _dio.delete<void>(ApiPaths.session(sessionId));
  }
}
