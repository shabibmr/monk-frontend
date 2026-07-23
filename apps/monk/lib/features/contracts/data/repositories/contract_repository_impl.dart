import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/contract.dart';
import '../../domain/entities/contract_amendment.dart';
import '../../domain/entities/contract_template.dart';
import '../../domain/repositories/contract_repository.dart';

class ContractRepositoryImpl implements ContractRepository {
  ContractRepositoryImpl(this._client);
  final MonkApiClient _client;

  Contract _map(ContractDto d) => Contract(
        id: d.id,
        collaborationId: d.collaborationId,
        status: d.status,
        contentHash: d.contentHash,
        templateKey: d.templateKey,
        templateVersion: d.templateVersion,
        pdfUrl: d.pdfUrl,
        usageRights: d.usageRights == null
            ? null
            : UsageRights(
                organicReuse: d.usageRights!.organicReuse,
                paidAmplification: d.usageRights!.paidAmplification,
                durationDays: d.usageRights!.durationDays,
                territory: d.usageRights!.territory,
                channels: d.usageRights!.channels,
                exclusivityCategory: d.usageRights!.exclusivityCategory,
                exclusivityDays: d.usageRights!.exclusivityDays,
              ),
        acceptances: d.acceptances
            .map(
              (a) => ContractAcceptance(
                party: a.party,
                acceptedByUserId: a.acceptedByUserId,
                contentHash: a.contentHash,
                acceptedAt: a.acceptedAt,
              ),
            )
            .toList(),
        bothPartiesAccepted: d.bothPartiesAccepted,
      );

  @override
  Future<Contract> get(String collaborationId) async {
    try {
      return _map(await _client.contracts.get(collaborationId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Contract> accept({
    required String collaborationId,
    required String contentHash,
  }) async {
    try {
      return _map(
        await _client.contracts.accept(
          collaborationId,
          contentHash: contentHash,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Contract> generate(String collaborationId) async {
    try {
      return _map(await _client.contracts.generate(collaborationId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<ContractTemplate>> getTemplates() async {
    try {
      final res = await _client.dio.get<List<dynamic>>(ApiPaths.contractTemplates);
      final list = res.data ?? [];
      return list
          .map((e) => ContractTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ContractTemplate> createTemplate(Map<String, dynamic> data) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiPaths.contractTemplates,
        data: data,
      );
      return ContractTemplate.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ContractTemplate> updateTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _client.dio.patch<Map<String, dynamic>>(
        '${ApiPaths.contractTemplates}/$id',
        data: data,
      );
      return ContractTemplate.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> deleteTemplate(String id) async {
    try {
      await _client.dio.delete<void>('${ApiPaths.contractTemplates}/$id');
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<ContractAmendment>> getAmendments(String contractId) async {
    try {
      final res = await _client.dio.get<List<dynamic>>(
        ApiPaths.contractAmendments(contractId),
      );
      final list = res.data ?? [];
      return list
          .map((e) => ContractAmendment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ContractAmendment> requestAmendment({
    required String contractId,
    required String collaborationId,
    required String title,
    required String reason,
    required String amendedTerms,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiPaths.contractAmendments(contractId),
        data: {
          'collaborationId': collaborationId,
          'title': title,
          'reason': reason,
          'amendedTerms': amendedTerms,
        },
      );
      return ContractAmendment.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ContractAmendment> respondAmendment({
    required String contractId,
    required String amendmentId,
    required String status,
    String? notes,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        '${ApiPaths.contractAmendments(contractId)}/$amendmentId/respond',
        data: {
          'status': status,
          if (notes != null) 'notes': notes,
        },
      );
      return ContractAmendment.fromJson(res.data ?? {});
    } catch (e) {
      throw mapError(e);
    }
  }
}
