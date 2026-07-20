import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/discovery_models.dart';

class DiscoveryApi {
  DiscoveryApi(this._dio);
  final Dio _dio;

  Future<DiscoveryPageDto> searchInfluencers(Map<String, dynamic> query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.discoveryInfluencers,
      queryParameters: query,
    );
    return DiscoveryPageDto.fromJson(res.data!);
  }

  Future<List<ShortlistDto>> listShortlists(String brandId) async {
    final res = await _dio.get<dynamic>(ApiPaths.brandShortlists(brandId));
    final raw = res.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['data'] is List)
            ? raw['data'] as List
            : const [];
    return list
        .map((e) => ShortlistDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ShortlistDto> createShortlist(String brandId, String name) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.brandShortlists(brandId),
      data: {'name': name},
    );
    return ShortlistDto.fromJson(res.data!);
  }

  Future<void> deleteShortlist(String brandId, String id) async {
    await _dio.delete<void>(ApiPaths.brandShortlist(brandId, id));
  }

  Future<List<ShortlistItemDto>> listItems(
    String brandId,
    String shortlistId,
  ) async {
    final res = await _dio.get<dynamic>(
      ApiPaths.brandShortlistItems(brandId, shortlistId),
    );
    final raw = res.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['data'] is List)
            ? raw['data'] as List
            : const [];
    return list
        .map((e) => ShortlistItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ShortlistItemDto> addItem({
    required String brandId,
    required String shortlistId,
    required String influencerProfileId,
    String? note,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.brandShortlistItems(brandId, shortlistId),
      data: {
        'influencerProfileId': influencerProfileId,
        if (note != null) 'note': note,
      },
    );
    return ShortlistItemDto.fromJson(res.data!);
  }

  Future<void> removeItem({
    required String brandId,
    required String shortlistId,
    required String itemId,
  }) async {
    await _dio.delete<void>(
      ApiPaths.brandShortlistItem(brandId, shortlistId, itemId),
    );
  }
}
