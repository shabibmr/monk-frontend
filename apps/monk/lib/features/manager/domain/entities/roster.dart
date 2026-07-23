import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

class RosterEntry extends Equatable {
  const RosterEntry({
    required this.profileId,
    required this.permissions,
    required this.inviteStatus,
    this.displayName,
    this.verificationStatus,
    this.country,
    this.openApplications = 0,
    this.contentDue = 0,
    this.payableMinor = 0,
    this.currency = 'INR',
  });

  final String profileId;
  final String? displayName;
  final String? verificationStatus;
  final String? country;
  final List<String> permissions;
  final String inviteStatus;
  final int openApplications;
  final int contentDue;
  final int payableMinor;
  final String currency;

  String get label => displayName?.isNotEmpty == true
      ? displayName!
      : profileId.substring(0, profileId.length.clamp(0, 8));

  EntityStatus get verificationChip {
    switch (verificationStatus) {
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
        profileId,
        displayName,
        verificationStatus,
        country,
        permissions,
        inviteStatus,
        openApplications,
        contentDue,
        payableMinor,
        currency,
      ];
}

class ProfileAccessRow extends Equatable {
  const ProfileAccessRow({
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

  bool get isManager => accessRole == 'manager';
  bool get isOwner => accessRole == 'owner';

  @override
  List<Object?> get props =>
      [id, userId, accessRole, permissions, inviteStatus];
}

class ManagerEarnings extends Equatable {
  const ManagerEarnings({
    required this.totalPayableMinor,
    required this.currency,
    required this.lines,
    this.note,
    this.managerSplitEnabled = false,
  });

  final int totalPayableMinor;
  final String currency;
  final List<ManagerEarningsLine> lines;
  final String? note;
  final bool managerSplitEnabled;

  @override
  List<Object?> get props =>
      [totalPayableMinor, currency, lines, note, managerSplitEnabled];
}

class ManagerEarningsLine extends Equatable {
  const ManagerEarningsLine({
    required this.profileId,
    required this.payableMinor,
    required this.currency,
    this.displayName,
  });

  final String profileId;
  final String? displayName;
  final int payableMinor;
  final String currency;

  @override
  List<Object?> get props => [profileId, displayName, payableMinor, currency];
}

class SwitchContextResult extends Equatable {
  const SwitchContextResult({
    required this.profileId,
    required this.permissions,
    required this.withdrawalRequiresOwnerConfirmation,
    required this.canInitiateWithdrawal,
  });

  final String profileId;
  final List<String> permissions;
  final bool withdrawalRequiresOwnerConfirmation;
  final bool canInitiateWithdrawal;

  @override
  List<Object?> get props => [
        profileId,
        permissions,
        withdrawalRequiresOwnerConfirmation,
        canInitiateWithdrawal,
      ];
}
