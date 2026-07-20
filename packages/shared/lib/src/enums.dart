/// Mirrors backend `packages/shared` UserRole and related enums.
/// Do not invent values — keep in sync with TS source of truth.

enum UserRole {
  brandUser('brand_user'),
  influencer('influencer'),
  manager('manager'),
  agencyOperator('agency_operator'),
  admin('admin');

  const UserRole(this.apiValue);
  final String apiValue;

  static UserRole fromApi(String value) {
    return UserRole.values.firstWhere(
      (r) => r.apiValue == value,
      orElse: () => throw ArgumentError('Unknown UserRole: $value'),
    );
  }

  bool get isBrand => this == UserRole.brandUser;
  bool get isCreator => this == UserRole.influencer || this == UserRole.manager;
  bool get isAdminPortal =>
      this == UserRole.admin || this == UserRole.agencyOperator;
}

enum UserStatus {
  pendingEmail('pending_email'),
  pendingVerification('pending_verification'),
  active('active'),
  suspended('suspended');

  const UserStatus(this.apiValue);
  final String apiValue;

  static UserStatus fromApi(String value) {
    return UserStatus.values.firstWhere(
      (s) => s.apiValue == value,
      orElse: () => throw ArgumentError('Unknown UserStatus: $value'),
    );
  }
}

enum PlatformCurrency {
  inr('INR'),
  aed('AED');

  const PlatformCurrency(this.code);
  final String code;

  static PlatformCurrency fromCode(String code) {
    return PlatformCurrency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => throw ArgumentError('Unknown currency: $code'),
    );
  }
}

/// Entity status for ImStatusChip — single mapping site in status_colors.dart.
enum EntityStatus {
  draft,
  briefSubmitted,
  contentPending,
  agencyBuilding,
  published,
  applicationsOpen,
  applied,
  invited,
  assigned,
  shortlisted,
  negotiating,
  inReview,
  submitted,
  contentSubmitted,
  syncing,
  termsAccepted,
  productShipped,
  revisionRequested,
  held,
  pendingPayout,
  licenseExpiring,
  shortlisting,
  inProgress,
  needsReauth,
  approved,
  verified,
  settled,
  completed,
  funded,
  paidOut,
  activeLicense,
  productReceived,
  rejected,
  cancelled,
  disputed,
  withdrawn,
  refunded,
  failed,
  unlicensedBlocked,
  partiallyRefunded,
}

enum CampaignStatus {
  draft,
  active,
  inReview,
  completed,
  cancelled,
}

