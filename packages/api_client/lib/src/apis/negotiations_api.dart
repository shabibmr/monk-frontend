import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/negotiation_models.dart';

class NegotiationsApi {
  NegotiationsApi(this._dio);
  final Dio _dio;

  Future<NegotiationDto> open(
    String applicationId,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.applicationNegotiations(applicationId),
      data: body,
    );
    return NegotiationDto.fromJson(res.data!);
  }

  Future<NegotiationDto> get(String id) async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiPaths.negotiation(id));
    return NegotiationDto.fromJson(res.data!);
  }

  Future<NegotiationDto> counter(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.negotiationOffers(id),
      data: body,
    );
    return NegotiationDto.fromJson(res.data!);
  }

  Future<AcceptNegotiationResultDto> accept(
    String id,
    String offerId,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.negotiationAcceptOffer(id, offerId),
    );
    return AcceptNegotiationResultDto.fromJson(res.data!);
  }

  Future<NegotiationDto> decline(String id, String offerId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.negotiationDeclineOffer(id, offerId),
    );
    return NegotiationDto.fromJson(res.data!);
  }

  Future<NegotiationDto> cancel(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.negotiationCancel(id),
    );
    return NegotiationDto.fromJson(res.data!);
  }
}
