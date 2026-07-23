import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/licensing_grant.dart';
import '../../domain/repositories/licensing_repository.dart';

class LicensingRepositoryImpl implements LicensingRepository {
  LicensingRepositoryImpl(this._client);
  final MonkApiClient _client;

  @override
  Future<List<LicensingGrant>> getGrants({String? collaborationId}) async {
    try {
      final query = collaborationId != null
          ? {'collaborationId': collaborationId}
          : null;
      final res = await _client.dio.get<List<dynamic>>(
        ApiPaths.licensingGrants,
        queryParameters: query,
      );
      final list = res.data ?? [];
      return list
          .map((e) => LicensingGrant.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<LicensingGrant> getGrant(String id) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiPaths.licensingGrant(id),
      );
      return LicensingGrant.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<LicensingGrant> createGrant(Map<String, dynamic> data) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiPaths.licensingGrants,
        data: data,
      );
      return LicensingGrant.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<LicensingGrant> revokeGrant(String id) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '${ApiPaths.licensingGrant(id)}/revoke',
      );
      return LicensingGrant.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }
}
