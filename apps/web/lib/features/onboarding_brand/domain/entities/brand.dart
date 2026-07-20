import 'package:equatable/equatable.dart';

class Brand extends Equatable {
  const Brand({
    required this.id,
    required this.companyName,
    this.website,
    this.industry,
    this.gstVatNumber,
    this.country,
    this.timezone,
    this.address,
    this.contactPerson,
    this.contactEmail,
    this.contactPhone,
    this.verificationStatus,
  });

  final String id;
  final String companyName;
  final String? website;
  final String? industry;
  final String? gstVatNumber;
  final String? country;
  final String? timezone;
  final String? address;
  final String? contactPerson;
  final String? contactEmail;
  final String? contactPhone;
  final String? verificationStatus;

  @override
  List<Object?> get props => [
        id,
        companyName,
        website,
        industry,
        gstVatNumber,
        country,
        timezone,
        address,
        contactPerson,
        contactEmail,
        contactPhone,
        verificationStatus,
      ];
}

class BrandMember extends Equatable {
  const BrandMember({
    required this.id,
    required this.email,
    required this.memberRole,
    required this.permissions,
    required this.inviteStatus,
  });

  final String id;
  final String email;
  final String memberRole;
  final List<String> permissions;
  final String inviteStatus;

  bool get isPending => inviteStatus == 'pending';
  bool get isOwner => memberRole == 'owner';

  @override
  List<Object?> get props =>
      [id, email, memberRole, permissions, inviteStatus];
}

class BrandInviteResult extends Equatable {
  const BrandInviteResult({
    required this.member,
    this.inviteTokenDev,
  });

  final BrandMember member;
  final String? inviteTokenDev;

  @override
  List<Object?> get props => [member, inviteTokenDev];
}

/// SRS team roles (cannot invite owner).
const brandInviteRoles = [
  'marketing_manager',
  'finance',
  'legal',
  'content_reviewer',
];

const brandPermissionOptions = [
  'read',
  'write',
  'approve',
  'publish',
  'finance',
];
