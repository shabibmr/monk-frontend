import '../entities/roster.dart';

abstract class ManagerRepository {
  Future<List<RosterEntry>> getRoster();
  Future<SwitchContextResult> switchContext(String profileId);
  Future<ManagerEarnings> getEarnings();
  Future<List<ProfileAccessRow>> listAccess(String profileId);
  Future<void> inviteManager({
    required String profileId,
    required String email,
    required List<String> permissions,
  });
  Future<void> revokeAccess({
    required String profileId,
    required String accessId,
  });
  Future<void> acceptInvite(String token);
}
