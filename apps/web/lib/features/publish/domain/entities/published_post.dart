import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

/// Client-side URL shape check only — server re-validates.
bool looksLikeHttpUrl(String raw) {
  final t = raw.trim();
  final uri = Uri.tryParse(t);
  if (uri == null) return false;
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;
  return uri.host.isNotEmpty;
}

EntityStatus publishVerificationToEntity(String status) {
  switch (status) {
    case 'pending':
    case 'verifying':
      return EntityStatus.syncing;
    case 'verified':
      return EntityStatus.verified;
    case 'failed':
      return EntityStatus.failed;
    case 'manual_required':
      return EntityStatus.needsReauth; // warning semantic for manual check
    default:
      return EntityStatus.inReview;
  }
}

class PublishedPost extends Equatable {
  const PublishedPost({
    required this.id,
    required this.collaborationId,
    required this.campaignDeliverableId,
    required this.liveUrl,
    required this.platform,
    required this.ownershipVerified,
    required this.verificationStatus,
    this.verificationMethod,
    this.verificationDetail,
    this.verifiedAt,
    this.autoPublish = false,
  });

  final String id;
  final String collaborationId;
  final String campaignDeliverableId;
  final String liveUrl;
  final String platform;
  final bool ownershipVerified;
  final String verificationStatus;
  final String? verificationMethod;
  final String? verificationDetail;
  final String? verifiedAt;
  final bool autoPublish;

  bool get isVerified =>
      ownershipVerified || verificationStatus == 'verified';
  bool get isTerminal =>
      isVerified ||
      verificationStatus == 'failed' ||
      verificationStatus == 'manual_required';
  bool get isPolling =>
      verificationStatus == 'pending' || verificationStatus == 'verifying';

  EntityStatus get statusChip =>
      publishVerificationToEntity(verificationStatus);

  String get statusLabel {
    if (isVerified) return 'verified';
    return verificationStatus.replaceAll('_', ' ');
  }

  @override
  List<Object?> get props => [
        id,
        collaborationId,
        campaignDeliverableId,
        liveUrl,
        platform,
        ownershipVerified,
        verificationStatus,
        verificationMethod,
        verificationDetail,
        verifiedAt,
        autoPublish,
      ];
}
