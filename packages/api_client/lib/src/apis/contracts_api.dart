import 'package:dio/dio.dart';

import '../api_paths.dart';
import '../models/contract_models.dart';

class ContractsApi {
  ContractsApi(this._dio);
  final Dio _dio;

  Future<ContractDto> get(String collaborationId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiPaths.collaborationContract(collaborationId),
    );
    return ContractDto.fromJson(res.data!);
  }

  Future<ContractDto> accept(
    String collaborationId, {
    required String contentHash,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.collaborationContractAccept(collaborationId),
      data: {'contentHash': contentHash},
    );
    return ContractDto.fromJson(res.data!);
  }

  Future<ContractDto> generate(String collaborationId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiPaths.collaborationContractGenerate(collaborationId),
    );
    return ContractDto.fromJson(res.data!);
  }
}
