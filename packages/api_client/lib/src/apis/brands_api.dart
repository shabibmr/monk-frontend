import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/brand_models.dart';

class BrandsApi {
  BrandsApi(this._dio);
  final Dio _dio;

  Future<BrandDto> create(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.brands,
      data: body,
    );
    return BrandDto.fromJson(res.data!);
  }

  Future<List<BrandDto>> listMine() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiPaths.brandsMe);
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => BrandDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BrandDto> getById(String brandId) async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiPaths.brand(brandId));
    return BrandDto.fromJson(res.data!);
  }

  Future<BrandDto> update(String brandId, Map<String, dynamic> body) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiPaths.brand(brandId),
      data: body,
    );
    return BrandDto.fromJson(res.data!);
  }

  Future<List<BrandMemberDto>> listMembers(String brandId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.brandMembers(brandId),
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => BrandMemberDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InviteMemberResultDto> inviteMember(
    String brandId, {
    required String email,
    required String memberRole,
    required List<String> permissions,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.brandMembers(brandId),
      data: {
        'email': email,
        'memberRole': memberRole,
        'permissions': permissions,
      },
    );
    return InviteMemberResultDto.fromJson(res.data!);
  }

  Future<BrandMemberDto> updateMember(
    String brandId,
    String memberId, {
    String? memberRole,
    List<String>? permissions,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiPaths.brandMember(brandId, memberId),
      data: {
        if (memberRole != null) 'memberRole': memberRole,
        if (permissions != null) 'permissions': permissions,
      },
    );
    return BrandMemberDto.fromJson(res.data!);
  }

  Future<void> removeMember(String brandId, String memberId) async {
    await _dio.delete<void>(ApiPaths.brandMember(brandId, memberId));
  }

  Future<Map<String, dynamic>> acceptInvite(String token) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.brandInviteAccept(token),
    );
    return res.data ?? const {};
  }
}
