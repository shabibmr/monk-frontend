class BrandDto {
  const BrandDto({
    required this.id,
    required this.companyName,
    this.ownerUserId,
    this.logoFileId,
    this.website,
    this.industry,
    this.gstVatNumber,
    this.country,
    this.timezone,
    this.address,
    this.contactPerson,
    this.contactEmail,
    this.contactPhone,
    this.socialLinks,
    this.verificationStatus,
  });

  final String id;
  final String companyName;
  final String? ownerUserId;
  final String? logoFileId;
  final String? website;
  final String? industry;
  final String? gstVatNumber;
  final String? country;
  final String? timezone;
  final String? address;
  final String? contactPerson;
  final String? contactEmail;
  final String? contactPhone;
  final Map<String, dynamic>? socialLinks;
  final String? verificationStatus;

  factory BrandDto.fromJson(Map<String, dynamic> json) {
    final links = json['socialLinks'];
    return BrandDto(
      id: json['id'] as String,
      companyName: json['companyName'] as String? ?? '',
      ownerUserId: json['ownerUserId'] as String?,
      logoFileId: json['logoFileId'] as String?,
      website: json['website'] as String?,
      industry: json['industry'] as String?,
      gstVatNumber: json['gstVatNumber'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
      address: json['address'] as String?,
      contactPerson: json['contactPerson'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      socialLinks: links is Map<String, dynamic> ? links : null,
      verificationStatus: json['verificationStatus'] as String?,
    );
  }
}

class BrandMemberDto {
  const BrandMemberDto({
    required this.id,
    required this.email,
    required this.memberRole,
    required this.permissions,
    required this.inviteStatus,
    this.brandId,
    this.userId,
  });

  final String id;
  final String email;
  final String memberRole;
  final List<String> permissions;
  final String inviteStatus;
  final String? brandId;
  final String? userId;

  factory BrandMemberDto.fromJson(Map<String, dynamic> json) {
    final perms = json['permissions'];
    return BrandMemberDto(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      memberRole: json['memberRole'] as String? ?? '',
      permissions: perms is List
          ? perms.map((e) => e.toString()).toList()
          : const [],
      inviteStatus: json['inviteStatus'] as String? ?? '',
      brandId: json['brandId'] as String?,
      userId: json['userId'] as String?,
    );
  }
}

class InviteMemberResultDto {
  const InviteMemberResultDto({
    required this.member,
    this.inviteTokenDev,
  });

  final BrandMemberDto member;
  final String? inviteTokenDev;

  factory InviteMemberResultDto.fromJson(Map<String, dynamic> json) {
    final memberJson = json['member'] as Map<String, dynamic>? ?? json;
    return InviteMemberResultDto(
      member: BrandMemberDto.fromJson(memberJson),
      inviteTokenDev: json['inviteTokenDev'] as String?,
    );
  }
}
