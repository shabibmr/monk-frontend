import '../entities/data_erasure_request.dart';
import '../entities/dispute.dart';

abstract class DisputeRepository {
  Future<List<Dispute>> getDisputes({String? collaborationId});
  Future<Dispute> getDispute(String id);
  Future<Dispute> fileDispute({
    required String collaborationId,
    required String reason,
    required String description,
    String? paymentId,
    List<String> evidenceUrls = const [],
  });

  // Admin dispute resolution
  Future<List<Dispute>> getAdminDisputes();
  Future<Dispute> resolveDispute({
    required String disputeId,
    required String resolution, // 'resolved_refund' or 'resolved_release'
    String? notes,
  });

  // Data erasure requests
  Future<List<DataErasureRequest>> getDataErasureRequests();
  Future<DataErasureRequest> submitDataErasureRequest(String reason);
}
