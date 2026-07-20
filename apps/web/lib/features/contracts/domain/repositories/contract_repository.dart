import '../entities/contract.dart';
import '../entities/contract_amendment.dart';
import '../entities/contract_template.dart';

abstract class ContractRepository {
  Future<Contract> get(String collaborationId);
  Future<Contract> accept({
    required String collaborationId,
    required String contentHash,
  });
  Future<Contract> generate(String collaborationId);

  // Contracts v2 (T2.3) - Templates & Amendments
  Future<List<ContractTemplate>> getTemplates();
  Future<ContractTemplate> createTemplate(Map<String, dynamic> data);
  Future<ContractTemplate> updateTemplate(
    String id,
    Map<String, dynamic> data,
  );
  Future<void> deleteTemplate(String id);

  Future<List<ContractAmendment>> getAmendments(String contractId);
  Future<ContractAmendment> requestAmendment({
    required String contractId,
    required String collaborationId,
    required String title,
    required String reason,
    required String amendedTerms,
  });
  Future<ContractAmendment> respondAmendment({
    required String contractId,
    required String amendmentId,
    required String status,
    String? notes,
  });
}
