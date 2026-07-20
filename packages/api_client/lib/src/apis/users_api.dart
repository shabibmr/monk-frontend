import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/auth_models.dart';

class UsersApi {
  UsersApi(this._dio);
  final Dio _dio;

  Future<PublicUserDto> me() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiPaths.usersMe);
    return PublicUserDto.fromJson(res.data!);
  }
}
