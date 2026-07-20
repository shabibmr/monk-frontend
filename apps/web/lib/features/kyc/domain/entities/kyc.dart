import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

class KycRecord extends Equatable {
  const KycRecord({
    required this.id,
    required this.status,
    this.influencerProfileId,
    this.identityDocFileId,
    this.gstRegistered,
    this.panMasked,
    this.gstMasked,
    this.accountMasked,
    this.rejectionReason,
  });

  final String id;
  final String status;
  final String? influencerProfileId;
  final String? identityDocFileId;
  final bool? gstRegistered;
  final String? panMasked;
  final String? gstMasked;
  final String? accountMasked;
  final String? rejectionReason;

  EntityStatus get statusChip {
    switch (status) {
      case 'approved':
        return EntityStatus.approved;
      case 'rejected':
        return EntityStatus.rejected;
      default:
        return EntityStatus.inReview;
    }
  }

  @override
  List<Object?> get props => [
        id,
        status,
        influencerProfileId,
        identityDocFileId,
        gstRegistered,
        panMasked,
        gstMasked,
        accountMasked,
        rejectionReason,
      ];
}

class MediaLicense extends Equatable {
  const MediaLicense({
    required this.id,
    required this.licenseNumber,
    required this.status,
    this.expiryDate,
    this.issuingAuthority,
  });

  final String id;
  final String licenseNumber;
  final String status;
  final DateTime? expiryDate;
  final String? issuingAuthority;

  EntityStatus get statusChip {
    switch (status) {
      case 'valid':
        return EntityStatus.activeLicense;
      case 'expiring':
        return EntityStatus.licenseExpiring;
      case 'expired':
        return EntityStatus.rejected;
      default:
        return EntityStatus.inReview;
    }
  }

  @override
  List<Object?> get props =>
      [id, licenseNumber, status, expiryDate, issuingAuthority];
}

class QueueInfluencer extends Equatable {
  const QueueInfluencer({
    required this.id,
    this.displayName,
    this.country,
    this.verificationStatus,
  });

  final String id;
  final String? displayName;
  final String? country;
  final String? verificationStatus;

  @override
  List<Object?> get props => [id, displayName, country, verificationStatus];
}

class RejectionTemplate extends Equatable {
  const RejectionTemplate({
    required this.key,
    this.body,
    this.category,
  });

  final String key;
  final String? body;
  final String? category;

  @override
  List<Object?> get props => [key, body, category];
}

class UaeGateResult extends Equatable {
  const UaeGateResult({
    required this.allowed,
    this.reason,
    this.code,
  });

  final bool allowed;
  final String? reason;
  final String? code;

  @override
  List<Object?> get props => [allowed, reason, code];
}

/// Jurisdiction UI hints from profile country (display only).
/// Messaging for gates still comes from API codes.
bool showIndiaFields(String? country) {
  final c = (country ?? '').toUpperCase();
  return c == 'IN' || c == 'IND' || c.isEmpty;
}

bool showUaeLicenseFields(String? country) {
  final c = (country ?? '').toUpperCase();
  return c == 'AE' || c == 'UAE';
}
