import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/roster.dart';
import '../../domain/repositories/manager_repository.dart';

class ManagerRepositoryImpl implements ManagerRepository {
  ManagerRepositoryImpl(this._client);
  final MonkApiClient _client;

  RosterEntry _mapRoster(RosterEntryDto d) => RosterEntry(
        profileId: d.profileId,
        displayName: d.displayName,
        verificationStatus: d.verificationStatus,
        country: d.country,
        permissions: d.permissions,
        inviteStatus: d.inviteStatus,
        openApplications: d.openApplications,
        contentDue: d.contentDue,
        payableMinor: d.payableMinor,
        currency: d.currency,
      );

  ProfileAccessRow _mapAccess(ProfileAccessRowDto d) => ProfileAccessRow(
        id: d.id,
        userId: d.userId,
        accessRole: d.accessRole,
        permissions: d.permissions,
        inviteStatus: d.inviteStatus,
      );

  @override
  Future<List<RosterEntry>> getRoster() async {
    try {
      final list = await _client.managers.roster();
      return list.map(_mapRoster).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<SwitchContextResult> switchContext(String profileId) async {
    try {
      final r = await _client.managers.switchContext(profileId);
      return SwitchContextResult(
        profileId: r.profileId,
        permissions: r.permissions,
        withdrawalRequiresOwnerConfirmation:
            r.withdrawalRequiresOwnerConfirmation,
        canInitiateWithdrawal: r.canInitiateWithdrawal,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<ManagerEarnings> getEarnings() async {
    try {
      final e = await _client.managers.earnings();
      return ManagerEarnings(
        totalPayableMinor: e.totalPayableMinor,
        currency: e.currency,
        note: e.note,
        managerSplitEnabled: e.managerSplitEnabled,
        lines: e.lines
            .map(
              (l) => ManagerEarningsLine(
                profileId: l.profileId,
                displayName: l.displayName,
                payableMinor: l.payableMinor,
                currency: l.currency,
              ),
            )
            .toList(),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<ProfileAccessRow>> listAccess(String profileId) async {
    try {
      // Prefer owner/manager profile access endpoint; fall back to manager path.
      try {
        final list = await _client.managers.listProfileAccess(profileId);
        return list.map(_mapAccess).toList();
      } catch (_) {
        final list = await _client.managers.listAccess(profileId);
        return list.map(_mapAccess).toList();
      }
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> inviteManager({
    required String profileId,
    required String email,
    required List<String> permissions,
  }) async {
    try {
      await _client.managers.inviteManager(
        profileId: profileId,
        email: email,
        permissions: permissions,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> revokeAccess({
    required String profileId,
    required String accessId,
  }) async {
    try {
      await _client.managers.revokeAccess(
        profileId: profileId,
        accessId: accessId,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> acceptInvite(String token) async {
    try {
      await _client.managers.acceptInvite(token);
    } catch (e) {
      throw mapError(e);
    }
  }
}
