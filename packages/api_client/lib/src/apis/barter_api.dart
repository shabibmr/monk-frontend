import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/barter_models.dart';

class BarterApi {
  BarterApi(this._dio);
  final Dio _dio;

  Future<BarterStatusDto> get(String collaborationId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.collaborationBarter(collaborationId),
    );
    return BarterStatusDto.fromJson(res.data!);
  }

  Future<BarterStatusDto> ship(
    String collaborationId, {
    required String trackingRef,
    String? shippingCarrier,
    String? notes,
    List<String>? evidenceFileIds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.collaborationBarterShip(collaborationId),
      data: {
        'trackingRef': trackingRef,
        if (shippingCarrier != null) 'shippingCarrier': shippingCarrier,
        if (notes != null) 'notes': notes,
        if (evidenceFileIds != null) 'evidenceFileIds': evidenceFileIds,
      },
    );
    return BarterStatusDto.fromJson(res.data!);
  }

  Future<BarterStatusDto> receive(
    String collaborationId, {
    String? notes,
    List<String>? evidenceFileIds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.collaborationBarterReceive(collaborationId),
      data: {
        if (notes != null) 'notes': notes,
        if (evidenceFileIds != null) 'evidenceFileIds': evidenceFileIds,
      },
    );
    return BarterStatusDto.fromJson(res.data!);
  }

  Future<BarterStatusDto> addEvidence(
    String collaborationId, {
    required List<String> fileIds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.collaborationBarterEvidence(collaborationId),
      data: {'fileIds': fileIds},
    );
    // Evidence endpoint may return { collaborationId, fulfillment } only.
    final data = res.data!;
    if (data.containsKey('collabType') || data.containsKey('collabStatus')) {
      return BarterStatusDto.fromJson(data);
    }
    final refreshed = await get(collaborationId);
    return refreshed;
  }

  Future<BarterStatusDto> openContent(String collaborationId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.collaborationContentOpen(collaborationId),
    );
    return BarterStatusDto.fromJson(res.data!);
  }
}
