import 'package:dio/dio.dart';

import '../api_paths.dart';

class HealthApi {
  HealthApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> health() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiPaths.health);
    return res.data ?? const {};
  }

  Future<Map<String, dynamic>> ready() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiPaths.healthReady);
    return res.data ?? const {};
  }
}
