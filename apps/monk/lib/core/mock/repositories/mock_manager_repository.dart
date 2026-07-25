import '../../../features/manager/domain/entities/roster.dart';
import '../../../features/manager/domain/repositories/manager_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [ManagerRepository].
///
/// Store keys (aligned with `seed_profiles.dart`):
/// - `manager_roster` → `List<RosterEntry>`
/// - `profile_access` → `List<ProfileAccessRow>`
class MockManagerRepository implements ManagerRepository {
  MockManagerRepository({required MockSeedStore store}) : _store = store;

  final MockSeedStore _store;

  static const rosterKey = 'manager_roster';
  static const accessKey = 'profile_access';
  static const earningsKey = 'manager_earnings';

  @override
  Future<List<RosterEntry>> getRoster() async {
    await _store.delay();
    final roster = _store.list<RosterEntry>(rosterKey);
    if (roster.isNotEmpty) return roster;

    final account = _currentAccount();
    final permissions = account?.managerPermissions.isNotEmpty == true
        ? account!.managerPermissions
        : const [
            'view_earnings',
            'manage_applications',
            'manage_content',
          ];
    final entry = RosterEntry(
      profileId: account?.profileId ?? MockIds.influencer1,
      displayName: account?.profileName ?? 'Arjun Creates',
      verificationStatus: 'approved',
      country: 'IN',
      permissions: permissions,
      inviteStatus: 'accepted',
      openApplications: 2,
      contentDue: 1,
      payableMinor: 1850000,
      currency: 'INR',
    );
    _store.add(rosterKey, entry);
    return [entry];
  }

  @override
  Future<SwitchContextResult> switchContext(String profileId) async {
    await _store.delay();
    final roster = await getRoster();
    final match = roster.where((e) => e.profileId == profileId).toList();
    if (match.isEmpty) {
      throw ForbiddenFailure('No access to profile: $profileId');
    }
    final permissions = match.first.permissions;
    return SwitchContextResult(
      profileId: profileId,
      permissions: permissions,
      withdrawalRequiresOwnerConfirmation: true,
      canInitiateWithdrawal: permissions.contains('view_earnings'),
    );
  }

  @override
  Future<ManagerEarnings> getEarnings() async {
    await _store.delay();
    final cached = _store.singles[earningsKey];
    if (cached is ManagerEarnings) return cached;

    final roster = await getRoster();
    final lines = roster
        .map(
          (e) => ManagerEarningsLine(
            profileId: e.profileId,
            displayName: e.displayName,
            payableMinor: e.payableMinor,
            currency: e.currency,
          ),
        )
        .toList();
    final total = lines.fold<int>(0, (sum, l) => sum + l.payableMinor);
    final earnings = ManagerEarnings(
      totalPayableMinor: total,
      currency: lines.isNotEmpty ? lines.first.currency : 'INR',
      lines: lines,
      note: 'Demo manager earnings (split disabled)',
      managerSplitEnabled: false,
    );
    _store.singles[earningsKey] = earnings;
    return earnings;
  }

  @override
  Future<List<ProfileAccessRow>> listAccess(String profileId) async {
    await _store.delay();
    final rows = _store.list<ProfileAccessRow>(accessKey);
    if (rows.isNotEmpty) return rows;

    final seeded = <ProfileAccessRow>[
      ProfileAccessRow(
        id: 'access-owner-$profileId',
        userId: MockIds.creator1,
        accessRole: 'owner',
        permissions: const [
          'view_earnings',
          'manage_applications',
          'manage_content',
          'withdraw',
        ],
        inviteStatus: 'accepted',
      ),
      ProfileAccessRow(
        id: 'access-mgr-$profileId',
        userId: MockIds.manager1,
        accessRole: 'manager',
        permissions: const [
          'view_earnings',
          'manage_applications',
          'manage_content',
        ],
        inviteStatus: 'accepted',
      ),
    ];
    for (final row in seeded) {
      _store.add(accessKey, row);
    }
    return seeded;
  }

  @override
  Future<void> inviteManager({
    required String profileId,
    required String email,
    required List<String> permissions,
  }) async {
    await _store.delay();
    if (email.trim().isEmpty) {
      throw const ValidationFailure('email is required');
    }
    _store.add(
      accessKey,
      ProfileAccessRow(
        id: 'access-inv-${DateTime.now().millisecondsSinceEpoch}',
        accessRole: 'manager',
        permissions: permissions,
        inviteStatus: 'pending',
      ),
    );
  }

  @override
  Future<void> revokeAccess({
    required String profileId,
    required String accessId,
  }) async {
    await _store.delay();
    final existing =
        _store.findWhere<ProfileAccessRow>(accessKey, (r) => r.id == accessId);
    if (existing == null) {
      throw NotFoundFailure('Access not found: $accessId');
    }
    if (existing.isOwner) {
      throw const ForbiddenFailure('Cannot revoke owner access');
    }
    _store.removeWhere<ProfileAccessRow>(accessKey, (r) => r.id == accessId);
  }

  @override
  Future<void> acceptInvite(String token) async {
    await _store.delay();
    if (token.trim().isEmpty) {
      throw const ValidationFailure('Invite token is required');
    }
    final pending = _store
        .list<ProfileAccessRow>(accessKey)
        .where((r) => r.inviteStatus == 'pending')
        .toList();
    if (pending.isEmpty) return;
    final first = pending.first;
    _store.replaceWhere<ProfileAccessRow>(
      accessKey,
      (r) => r.id == first.id,
      ProfileAccessRow(
        id: first.id,
        userId: _store.currentUserId ?? first.userId,
        accessRole: first.accessRole,
        permissions: first.permissions,
        inviteStatus: 'accepted',
      ),
    );
  }

  DemoAccount? _currentAccount() {
    final id = _store.currentUserId;
    if (id == null) return null;
    return _store.findAccountById(id);
  }
}
