import 'package:equatable/equatable.dart';

class Dispute extends Equatable {
  const Dispute({
    required this.id,
    required this.collaborationId,
    required this.raisedBy,
    required this.reason,
    required this.description,
    required this.status, // 'open', 'under_review', 'resolved_refund', 'resolved_release', 'closed'
    this.paymentId,
    this.evidenceUrls = const [],
    this.adminNotes,
    this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String collaborationId;
  final String raisedBy;
  final String reason;
  final String description;
  final String status;
  final String? paymentId;
  final List<String> evidenceUrls;
  final String? adminNotes;
  final String? createdAt;
  final String? resolvedAt;

  bool get isOpen => status == 'open' || status == 'under_review';
  bool get isResolved =>
      status == 'resolved_refund' ||
      status == 'resolved_release' ||
      status == 'closed';

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'] as String? ?? '',
      collaborationId: json['collaborationId'] as String? ?? '',
      raisedBy: json['raisedBy'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      paymentId: json['paymentId'] as String?,
      evidenceUrls: (json['evidenceUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      adminNotes: json['adminNotes'] as String?,
      createdAt: json['createdAt'] as String?,
      resolvedAt: json['resolvedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'collaborationId': collaborationId,
        'raisedBy': raisedBy,
        'reason': reason,
        'description': description,
        'status': status,
        'paymentId': paymentId,
        'evidenceUrls': evidenceUrls,
        'adminNotes': adminNotes,
        'createdAt': createdAt,
        'resolvedAt': resolvedAt,
      };

  @override
  List<Object?> get props => [
        id,
        collaborationId,
        raisedBy,
        reason,
        description,
        status,
        paymentId,
        evidenceUrls,
        adminNotes,
        createdAt,
        resolvedAt,
      ];
}
