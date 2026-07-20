class KycRecordDto {
  const KycRecordDto({
    required this.id,
    required this.status,
    this.influencerProfileId,
    this.brandId,
    this.identityDocFileId,
    this.gstRegistered,
    this.panMasked,
    this.gstMasked,
    this.accountMasked,
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String status;
  final String? influencerProfileId;
  final String? brandId;
  final String? identityDocFileId;
  final bool? gstRegistered;
  final String? panMasked;
  final String? gstMasked;
  final String? accountMasked;
  final String? rejectionReason;
  final DateTime? createdAt;

  factory KycRecordDto.fromJson(Map<String, dynamic> json) {
    return KycRecordDto(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending',
      influencerProfileId: json['influencerProfileId'] as String?,
      brandId: json['brandId'] as String?,
      identityDocFileId: json['identityDocFileId'] as String?,
      gstRegistered: json['gstRegistered'] as bool?,
      panMasked: json['panMasked'] as String?,
      gstMasked: json['gstMasked'] as String?,
      accountMasked: json['accountMasked'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class MediaLicenseDto {
  const MediaLicenseDto({
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

  factory MediaLicenseDto.fromJson(Map<String, dynamic> json) {
    return MediaLicenseDto(
      id: json['id'] as String,
      licenseNumber: json['licenseNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'unverified',
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'].toString())
          : null,
      issuingAuthority: json['issuingAuthority'] as String?,
    );
  }
}

class KycMeResponseDto {
  const KycMeResponseDto({
    required this.data,
    required this.licenses,
  });

  final List<KycRecordDto> data;
  final List<MediaLicenseDto> licenses;

  factory KycMeResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? const [];
    final licenses = json['licenses'] as List<dynamic>? ?? const [];
    return KycMeResponseDto(
      data: data
          .map((e) => KycRecordDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      licenses: licenses
          .map((e) => MediaLicenseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VerificationQueueDto {
  const VerificationQueueDto({
    required this.influencers,
    required this.kyc,
  });

  final List<QueueInfluencerDto> influencers;
  final List<KycRecordDto> kyc;

  factory VerificationQueueDto.fromJson(Map<String, dynamic> json) {
    final influencers = json['influencers'] as List<dynamic>? ?? const [];
    final kyc = json['kyc'] as List<dynamic>? ?? const [];
    return VerificationQueueDto(
      influencers: influencers
          .map((e) => QueueInfluencerDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      kyc: kyc
          .map((e) => KycRecordDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QueueInfluencerDto {
  const QueueInfluencerDto({
    required this.id,
    this.displayName,
    this.country,
    this.verificationStatus,
    this.ownerUserId,
    this.createdAt,
    this.onboardingCompletedAt,
  });

  final String id;
  final String? displayName;
  final String? country;
  final String? verificationStatus;
  final String? ownerUserId;
  final DateTime? createdAt;
  final DateTime? onboardingCompletedAt;

  factory QueueInfluencerDto.fromJson(Map<String, dynamic> json) {
    return QueueInfluencerDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      country: json['country'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      ownerUserId: json['ownerUserId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      onboardingCompletedAt: json['onboardingCompletedAt'] != null
          ? DateTime.tryParse(json['onboardingCompletedAt'].toString())
          : null,
    );
  }
}

class RejectionTemplateDto {
  const RejectionTemplateDto({
    required this.id,
    required this.key,
    this.category,
    this.body,
  });

  final String id;
  final String key;
  final String? category;
  final String? body;

  factory RejectionTemplateDto.fromJson(Map<String, dynamic> json) {
    return RejectionTemplateDto(
      id: json['id'] as String? ?? json['key'] as String? ?? '',
      key: json['key'] as String? ?? '',
      category: json['category'] as String?,
      body: json['body'] as String? ?? json['text'] as String?,
    );
  }
}

class UaeGateDto {
  const UaeGateDto({
    required this.allowed,
    this.reason,
    this.code,
  });

  final bool allowed;
  final String? reason;
  final String? code;

  factory UaeGateDto.fromJson(Map<String, dynamic> json) {
    return UaeGateDto(
      allowed: json['allowed'] == true,
      reason: json['reason'] as String?,
      code: json['code'] as String?,
    );
  }
}
