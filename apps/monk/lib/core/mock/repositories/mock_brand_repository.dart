import 'package:monk_shared/monk_shared.dart';

import '../../../features/onboarding_brand/domain/entities/brand.dart';
import '../../../features/onboarding_brand/domain/repositories/brand_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [BrandRepository].
///
/// Store keys (aligned with `seed_profiles.dart`):
/// - `brands` → `List<Brand>`
/// - `brand_members` → `List<BrandMember>`
class MockBrandRepository implements BrandRepository {
  MockBrandRepository({required MockSeedStore store}) : _store = store;

  final MockSeedStore _store;

  static const brandsKey = 'brands';
  static const membersKey = 'brand_members';

  @override
  Future<List<Brand>> listMine() async {
    await _store.delay();
    final account = _currentAccount();

    // Incomplete brand onboarding → empty list (AuthBloc uses this flag).
    if (account != null &&
        account.user.role == UserRole.brandUser &&
        account.brandId == null) {
      return const [];
    }

    final brands = _store.list<Brand>(brandsKey);
    if (account?.brandId != null) {
      final mine = brands.where((b) => b.id == account!.brandId).toList();
      if (mine.isNotEmpty) return mine;
      // Brand linked but not in collection yet.
      return [_ensureBrand(account!.brandId!)];
    }

    if (brands.isNotEmpty) return brands;
    return [_ensureBrand(MockIds.brandOrg1)];
  }

  @override
  Future<Brand> create(Map<String, dynamic> body) async {
    await _store.delay();
    final companyName = (body['companyName'] as String?)?.trim() ?? '';
    if (companyName.isEmpty) {
      throw const ValidationFailure('companyName is required');
    }

    final id = 'brand-demo-${DateTime.now().millisecondsSinceEpoch}';
    final brand = Brand(
      id: id,
      companyName: companyName,
      website: body['website'] as String?,
      industry: body['industry'] as String?,
      gstVatNumber: body['gstVatNumber'] as String?,
      country: body['country'] as String?,
      timezone: body['timezone'] as String?,
      address: body['address'] as String?,
      contactPerson: body['contactPerson'] as String?,
      contactEmail: body['contactEmail'] as String?,
      contactPhone: body['contactPhone'] as String?,
      verificationStatus: 'pending',
    );
    _store.add(brandsKey, brand);

    final account = _currentAccount();
    if (account != null) {
      _store.registerAccount(
        DemoAccount(
          user: account.user,
          password: account.password,
          brandId: brand.id,
          profileId: account.profileId,
          profileName: account.profileName,
          brandOnboardingComplete: true,
          influencerOnboardingComplete: account.influencerOnboardingComplete,
          isManagerContext: account.isManagerContext,
          managerPermissions: account.managerPermissions,
        ),
      );
    }

    _store.add(
      membersKey,
      BrandMember(
        id: 'bm-owner-$id',
        email: account?.user.email ?? 'owner@demo.local',
        memberRole: 'owner',
        permissions: List<String>.from(brandPermissionOptions),
        inviteStatus: 'accepted',
      ),
    );

    return brand;
  }

  @override
  Future<Brand> getById(String brandId) async {
    await _store.delay();
    final brand = _store.findWhere<Brand>(brandsKey, (b) => b.id == brandId);
    if (brand != null) return brand;

    if (brandId == MockIds.brandOrg1 || brandId == MockIds.brandOrg2) {
      return _ensureBrand(brandId);
    }
    throw NotFoundFailure('Brand not found: $brandId');
  }

  @override
  Future<Brand> update(String brandId, Map<String, dynamic> body) async {
    await _store.delay();
    final existing = await getById(brandId);
    final updated = Brand(
      id: existing.id,
      companyName: (body['companyName'] as String?) ?? existing.companyName,
      website: body.containsKey('website')
          ? body['website'] as String?
          : existing.website,
      industry: body.containsKey('industry')
          ? body['industry'] as String?
          : existing.industry,
      gstVatNumber: body.containsKey('gstVatNumber')
          ? body['gstVatNumber'] as String?
          : existing.gstVatNumber,
      country: body.containsKey('country')
          ? body['country'] as String?
          : existing.country,
      timezone: body.containsKey('timezone')
          ? body['timezone'] as String?
          : existing.timezone,
      address: body.containsKey('address')
          ? body['address'] as String?
          : existing.address,
      contactPerson: body.containsKey('contactPerson')
          ? body['contactPerson'] as String?
          : existing.contactPerson,
      contactEmail: body.containsKey('contactEmail')
          ? body['contactEmail'] as String?
          : existing.contactEmail,
      contactPhone: body.containsKey('contactPhone')
          ? body['contactPhone'] as String?
          : existing.contactPhone,
      verificationStatus: body.containsKey('verificationStatus')
          ? body['verificationStatus'] as String?
          : existing.verificationStatus,
    );
    _store.replaceWhere<Brand>(brandsKey, (b) => b.id == brandId, updated);
    return updated;
  }

  @override
  Future<List<BrandMember>> listMembers(String brandId) async {
    await _store.delay();
    await getById(brandId);

    final members = _store.list<BrandMember>(membersKey);
    if (members.isNotEmpty) return members;

    final account = _store.accountsById.values
        .where((a) => a.brandId == brandId)
        .toList();
    final owner = BrandMember(
      id: 'bm-owner-$brandId',
      email: account.isEmpty
          ? MockIds.contactEmailBrand1
          : account.first.user.email,
      memberRole: 'owner',
      permissions: List<String>.from(brandPermissionOptions),
      inviteStatus: 'accepted',
    );
    _store.add(membersKey, owner);
    return [owner];
  }

  @override
  Future<BrandInviteResult> inviteMember({
    required String brandId,
    required String email,
    required String memberRole,
    required List<String> permissions,
  }) async {
    await _store.delay();
    await getById(brandId);
    if (email.trim().isEmpty) {
      throw const ValidationFailure('email is required');
    }
    if (memberRole == 'owner') {
      throw const ValidationFailure('Cannot invite as owner');
    }

    final member = BrandMember(
      id: 'bm-inv-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim().toLowerCase(),
      memberRole: memberRole,
      permissions: permissions,
      inviteStatus: 'pending',
    );
    _store.add(membersKey, member);
    return BrandInviteResult(
      member: member,
      inviteTokenDev: 'mock-brand-invite-${member.id}',
    );
  }

  @override
  Future<void> removeMember({
    required String brandId,
    required String memberId,
  }) async {
    await _store.delay();
    final member =
        _store.findWhere<BrandMember>(membersKey, (m) => m.id == memberId);
    if (member == null) {
      throw NotFoundFailure('Member not found: $memberId');
    }
    if (member.isOwner) {
      throw const ForbiddenFailure('Cannot remove brand owner');
    }
    _store.removeWhere<BrandMember>(membersKey, (m) => m.id == memberId);
  }

  @override
  Future<void> acceptInvite(String token) async {
    await _store.delay();
    if (token.trim().isEmpty) {
      throw const ValidationFailure('Invite token is required');
    }
    final pending = _store
        .list<BrandMember>(membersKey)
        .where((m) => m.isPending)
        .toList();
    if (pending.isEmpty) return;
    final m = pending.first;
    _store.replaceWhere<BrandMember>(
      membersKey,
      (x) => x.id == m.id,
      BrandMember(
        id: m.id,
        email: m.email,
        memberRole: m.memberRole,
        permissions: m.permissions,
        inviteStatus: 'accepted',
      ),
    );
  }

  DemoAccount? _currentAccount() {
    final id = _store.currentUserId;
    if (id == null) return null;
    return _store.findAccountById(id);
  }

  Brand _ensureBrand(String id) {
    final existing = _store.findWhere<Brand>(brandsKey, (b) => b.id == id);
    if (existing != null) return existing;

    final brand = Brand(
      id: id,
      companyName: id == MockIds.brandOrg2 ? 'Pulse Fit Co' : 'Monk Demo Brand',
      website: 'https://demo.influencersmonk.local',
      industry: 'Consumer Electronics',
      country: 'IN',
      timezone: 'Asia/Kolkata',
      contactPerson: 'Priya Brand',
      contactEmail: MockIds.contactEmailBrand1,
      verificationStatus: 'verified',
    );
    _store.add(brandsKey, brand);
    return brand;
  }
}
