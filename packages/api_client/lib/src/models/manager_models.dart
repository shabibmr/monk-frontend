class RosterEntryDto {
  const RosterEntryDto({
    required this.profileId,
    required this.permissions,
    required this.inviteStatus,
    this.displayName,
    this.verificationStatus,
    this.country,
    this.accessRole,
    this.openApplications = 0,
    this.contentDue = 0,
    this.unreadReviews = 0,
    this.payableMinor = 0,
    this.currency = 'INR',
    this.earningsNote,
  });

  final String profileId;
  final String? displayName;
  final String? verificationStatus;
  final String? country;
  final String? accessRole;
  final List<String> permissions;
  final String inviteStatus;
  final int openApplications;
  final int contentDue;
  final int unreadReviews;
  final int payableMinor;
  final String currency;
  final String? earningsNote;

  factory RosterEntryDto.fromJson(Map<String, dynamic> json) {
    final tasks = json['pendingTasks'] as Map<String, dynamic>? ?? const {};
    final earnings =
        json['earningsSummary'] as Map<String, dynamic>? ?? const {};
    final perms = json['permissions'];
    return RosterEntryDto(
      profileId: json['profileId'] as String,
      displayName: json['displayName'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      country: json['country'] as String?,
      accessRole: json['accessRole'] as String?,
      permissions: perms is List
          ? perms.map((e) => e.toString()).toList()
          : const [],
      inviteStatus: json['inviteStatus'] as String? ?? 'accepted',
      openApplications: tasks['openApplications'] as int? ?? 0,
      contentDue: tasks['contentDue'] as int? ?? 0,
      unreadReviews: tasks['unreadReviews'] as int? ?? 0,
      payableMinor: earnings['payableMinor'] as int? ?? 0,
      currency: earnings['currency'] as String? ?? 'INR',
      earningsNote: earnings['note'] as String?,
    );
  }
}

class SwitchContextDto {
  const SwitchContextDto({
    required this.profileId,
    required this.permissions,
    required this.withdrawalRequiresOwnerConfirmation,
    required this.canInitiateWithdrawal,
  });

  final String profileId;
  final List<String> permissions;
  final bool withdrawalRequiresOwnerConfirmation;
  final bool canInitiateWithdrawal;

  factory SwitchContextDto.fromJson(Map<String, dynamic> json) {
    final perms = json['permissions'];
    return SwitchContextDto(
      profileId: json['profileId'] as String,
      permissions: perms is List
          ? perms.map((e) => e.toString()).toList()
          : const [],
      withdrawalRequiresOwnerConfirmation:
          json['withdrawalRequiresOwnerConfirmation'] == true,
      canInitiateWithdrawal: json['canInitiateWithdrawal'] == true,
    );
  }
}

class ManagerEarningsDto {
  const ManagerEarningsDto({
    required this.totalPayableMinor,
    required this.currency,
    required this.lines,
    this.note,
    this.managerSplitEnabled = false,
  });

  final int totalPayableMinor;
  final String currency;
  final List<ManagerEarningsLineDto> lines;
  final String? note;
  final bool managerSplitEnabled;

  factory ManagerEarningsDto.fromJson(Map<String, dynamic> json) {
    final lines = json['lines'] as List<dynamic>? ?? const [];
    return ManagerEarningsDto(
      totalPayableMinor: json['totalPayableMinor'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      lines: lines
          .map(
            (e) => ManagerEarningsLineDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      note: json['note'] as String?,
      managerSplitEnabled: json['managerSplitEnabled'] == true,
    );
  }
}

class ManagerEarningsLineDto {
  const ManagerEarningsLineDto({
    required this.profileId,
    required this.payableMinor,
    required this.currency,
    this.displayName,
  });

  final String profileId;
  final String? displayName;
  final int payableMinor;
  final String currency;

  factory ManagerEarningsLineDto.fromJson(Map<String, dynamic> json) {
    return ManagerEarningsLineDto(
      profileId: json['profileId'] as String,
      displayName: json['displayName'] as String?,
      payableMinor: json['payableMinor'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}

class ProfileAccessRowDto {
  const ProfileAccessRowDto({
    required this.id,
    required this.accessRole,
    required this.permissions,
    required this.inviteStatus,
    this.userId,
  });

  final String id;
  final String? userId;
  final String accessRole;
  final List<String> permissions;
  final String inviteStatus;

  factory ProfileAccessRowDto.fromJson(Map<String, dynamic> json) {
    final perms = json['permissions'];
    return ProfileAccessRowDto(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      accessRole: json['accessRole'] as String? ?? '',
      permissions: perms is List
          ? perms.map((e) => e.toString()).toList()
          : const [],
      inviteStatus: json['inviteStatus'] as String? ?? '',
    );
  }
}
