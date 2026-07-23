import 'package:equatable/equatable.dart';

class LicensingGrant extends Equatable {
  const LicensingGrant({
    required this.id,
    required this.collaborationId,
    required this.assetUrl,
    required this.token,
    required this.scope,
    required this.territory,
    required this.durationDays,
    required this.fee,
    required this.status, // 'active', 'expired', 'revoked'
    this.deliverableId,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String collaborationId;
  final String assetUrl;
  final String token;
  final String scope;
  final String territory;
  final int durationDays;
  final double fee;
  final String status;
  final String? deliverableId;
  final String? createdAt;
  final String? expiresAt;

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isRevoked => status == 'revoked';

  factory LicensingGrant.fromJson(Map<String, dynamic> json) {
    return LicensingGrant(
      id: json['id'] as String? ?? '',
      collaborationId: json['collaborationId'] as String? ?? '',
      assetUrl: json['assetUrl'] as String? ?? '',
      token: json['token'] as String? ?? '',
      scope: json['scope'] as String? ?? 'digital_only',
      territory: json['territory'] as String? ?? 'worldwide',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 365,
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
      deliverableId: json['deliverableId'] as String?,
      createdAt: json['createdAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'collaborationId': collaborationId,
        'assetUrl': assetUrl,
        'token': token,
        'scope': scope,
        'territory': territory,
        'durationDays': durationDays,
        'fee': fee,
        'status': status,
        'deliverableId': deliverableId,
        'createdAt': createdAt,
        'expiresAt': expiresAt,
      };

  @override
  List<Object?> get props => [
        id,
        collaborationId,
        assetUrl,
        token,
        scope,
        territory,
        durationDays,
        fee,
        status,
        deliverableId,
        createdAt,
        expiresAt,
      ];
}
