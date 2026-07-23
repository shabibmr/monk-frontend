import 'package:equatable/equatable.dart';

class DataErasureRequest extends Equatable {
  const DataErasureRequest({
    required this.id,
    required this.userId,
    required this.status, // 'pending', 'in_progress', 'completed', 'rejected'
    required this.reason,
    this.userEmail,
    this.requestedAt,
    this.completedAt,
    this.rejectionReason,
  });

  final String id;
  final String userId;
  final String status;
  final String reason;
  final String? userEmail;
  final String? requestedAt;
  final String? completedAt;
  final String? rejectionReason;

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';

  factory DataErasureRequest.fromJson(Map<String, dynamic> json) {
    return DataErasureRequest(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      reason: json['reason'] as String? ?? '',
      userEmail: json['userEmail'] as String?,
      requestedAt: json['requestedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'status': status,
        'reason': reason,
        'userEmail': userEmail,
        'requestedAt': requestedAt,
        'completedAt': completedAt,
        'rejectionReason': rejectionReason,
      };

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        reason,
        userEmail,
        requestedAt,
        completedAt,
        rejectionReason,
      ];
}
