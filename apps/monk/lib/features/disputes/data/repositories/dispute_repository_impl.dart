import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/data_erasure_request.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/repositories/dispute_repository.dart';

class DisputeRepositoryImpl implements DisputeRepository {
  DisputeRepositoryImpl(this._client);
  final MonkApiClient _client;

  @override
  Future<List<Dispute>> getDisputes({String? collaborationId}) async {
    try {
      final query = collaborationId != null
          ? {'collaborationId': collaborationId}
          : null;
      final res = await _client.dio.get<List<dynamic>>(
        ApiPaths.disputes,
        queryParameters: query,
      );
      final list = res.data ?? [];
      return list
          .map((e) => Dispute.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Dispute> getDispute(String id) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiPaths.dispute(id),
      );
      return Dispute.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Dispute> fileDispute({
    required String collaborationId,
    required String reason,
    required String description,
    String? paymentId,
    List<String> evidenceUrls = const [],
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiPaths.disputes,
        data: {
          'collaborationId': collaborationId,
          'reason': reason,
          'description': description,
          if (paymentId != null) 'paymentId': paymentId,
          'evidenceUrls': evidenceUrls,
        },
      );
      return Dispute.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Dispute>> getAdminDisputes() async {
    try {
      final res = await _client.dio.get<List<dynamic>>(ApiPaths.adminDisputes);
      final list = res.data ?? [];
      return list
          .map((e) => Dispute.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Dispute> resolveDispute({
    required String disputeId,
    required String resolution,
    String? notes,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '${ApiPaths.dispute(disputeId)}/resolve',
        data: {
          'resolution': resolution,
          if (notes != null) 'notes': notes,
        },
      );
      return Dispute.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<DataErasureRequest>> getDataErasureRequests() async {
    try {
      final res =
          await _client.dio.get<List<dynamic>>(ApiPaths.dataErasureRequests);
      final list = res.data ?? [];
      return list
          .map((e) => DataErasureRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<DataErasureRequest> submitDataErasureRequest(String reason) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiPaths.dataErasureRequests,
        data: {'reason': reason},
      );
      return DataErasureRequest.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }
}
