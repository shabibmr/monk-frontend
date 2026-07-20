import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/brief_models.dart';

class BriefsApi {
  BriefsApi(this._dio);
  final Dio _dio;

  Future<SubmitBriefResultDto> submit(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.briefs,
      data: body,
    );
    return SubmitBriefResultDto.fromJson(res.data!);
  }

  Future<List<BriefDto>> listMine() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiPaths.briefsMe);
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => BriefDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BriefDto>> agencyList({String? status}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.agencyBriefs,
      queryParameters: {
        if (status != null) 'status': status,
      },
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => BriefDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BriefDto> triage(String id, {String? notes}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.agencyBriefTriage(id),
      data: {
        if (notes != null) 'notes': notes,
      },
    );
    return BriefDto.fromJson(res.data!);
  }

  Future<ConvertBriefResultDto> convert(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.agencyBriefConvert(id),
    );
    return ConvertBriefResultDto.fromJson(res.data!);
  }

  Future<Map<String, dynamic>> assignInfluencers({
    required String campaignId,
    required List<String> profileIds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.agencyAssignInfluencers(campaignId),
      data: {'profileIds': profileIds},
    );
    return res.data ?? const {};
  }
}
