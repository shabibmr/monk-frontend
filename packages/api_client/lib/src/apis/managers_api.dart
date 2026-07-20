import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/manager_models.dart';

class ManagersApi {
  ManagersApi(this._dio);
  final Dio _dio;

  Future<List<RosterEntryDto>> roster() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiPaths.managersRoster);
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => RosterEntryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ManagerEarningsDto> earnings() async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiPaths.managersEarnings);
    return ManagerEarningsDto.fromJson(res.data!);
  }

  Future<SwitchContextDto> switchContext(String profileId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.managersSwitchContext,
      data: {'profileId': profileId},
    );
    return SwitchContextDto.fromJson(res.data!);
  }

  Future<List<ProfileAccessRowDto>> listAccess(String profileId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.managersProfileAccess(profileId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ProfileAccessRowDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProfileAccessRowDto>> listProfileAccess(String profileId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.profileAccess(profileId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => ProfileAccessRowDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> inviteManager({
    required String profileId,
    required String email,
    required List<String> permissions,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.profileAccess(profileId),
      data: {'email': email, 'permissions': permissions},
    );
    return res.data ?? const {};
  }

  Future<void> revokeAccess({
    required String profileId,
    required String accessId,
  }) async {
    await _dio.delete<void>(
      ApiPaths.profileAccessMember(profileId, accessId),
    );
  }

  Future<void> acceptInvite(String token) async {
    await _dio.post<void>(ApiPaths.managerInviteAccept(token));
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required String profileId,
    required int amountMinor,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.managersWithdrawalRequest,
      data: {'profileId': profileId, 'amountMinor': amountMinor},
    );
    return res.data ?? const {};
  }
}
