import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/kyc_models.dart';

class KycApi {
  KycApi(this._dio);
  final Dio _dio;

  Future<KycRecordDto> submit(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.kyc,
      data: body,
    );
    return KycRecordDto.fromJson(res.data!);
  }

  Future<KycMeResponseDto> me(String profileId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.kycMe,
      queryParameters: {'profileId': profileId},
    );
    return KycMeResponseDto.fromJson(res.data!);
  }

  Future<List<RejectionTemplateDto>> rejectionTemplates({
    String? category,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.rejectionTemplates,
      queryParameters: {
        if (category != null) 'category': category,
      },
    );
    final data = res.data?['data'] as List<dynamic>? ?? const [];
    return data
        .map((e) => RejectionTemplateDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UaeGateDto> uaeGate({
    required String profileId,
    required String collabType,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.complianceUaeGate,
      queryParameters: {
        'profileId': profileId,
        'collabType': collabType,
      },
    );
    return UaeGateDto.fromJson(res.data!);
  }

  Future<VerificationQueueDto> adminQueue({String? type}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.adminVerificationQueue,
      queryParameters: {
        if (type != null) 'type': type,
      },
    );
    return VerificationQueueDto.fromJson(res.data!);
  }

  Future<KycRecordDto> adminApprove(String kycId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.adminKycApprove(kycId),
    );
    return KycRecordDto.fromJson(res.data!);
  }

  Future<KycRecordDto> adminReject(
    String kycId, {
    String? templateKey,
    String? reason,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.adminKycReject(kycId),
      data: {
        if (templateKey != null) 'templateKey': templateKey,
        if (reason != null) 'reason': reason,
      },
    );
    return KycRecordDto.fromJson(res.data!);
  }

  Future<void> adminVerifyLicense(String licenseId) async {
    await _dio.post<void>(ApiPaths.adminLicenseVerify(licenseId));
  }
}
