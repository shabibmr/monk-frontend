import 'package:equatable/equatable.dart';

class ContractAmendment extends Equatable {
  const ContractAmendment({
    required this.id,
    required this.contractId,
    required this.collaborationId,
    required this.title,
    required this.reason,
    required this.amendedTerms,
    required this.status,
    required this.requestedBy,
    this.requestedAt,
    this.respondedAt,
    this.adminNotes,
  });

  final String id;
  final String contractId;
  final String collaborationId;
  final String title;
  final String reason;
  final String amendedTerms;
  final String status; // 'pending', 'approved', 'rejected'
  final String requestedBy;
  final String? requestedAt;
  final String? respondedAt;
  final String? adminNotes;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory ContractAmendment.fromJson(Map<String, dynamic> json) {
    return ContractAmendment(
      id: json['id'] as String? ?? '',
      contractId: json['contractId'] as String? ?? '',
      collaborationId: json['collaborationId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      amendedTerms: json['amendedTerms'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      requestedBy: json['requestedBy'] as String? ?? '',
      requestedAt: json['requestedAt'] as String?,
      respondedAt: json['respondedAt'] as String?,
      adminNotes: json['adminNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contractId': contractId,
        'collaborationId': collaborationId,
        'title': title,
        'reason': reason,
        'amendedTerms': amendedTerms,
        'status': status,
        'requestedBy': requestedBy,
        'requestedAt': requestedAt,
        'respondedAt': respondedAt,
        'adminNotes': adminNotes,
      };

  @override
  List<Object?> get props => [
        id,
        contractId,
        collaborationId,
        title,
        reason,
        amendedTerms,
        status,
        requestedBy,
        requestedAt,
        respondedAt,
        adminNotes,
      ];
}
