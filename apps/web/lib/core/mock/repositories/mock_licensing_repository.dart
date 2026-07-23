import '../../../features/licensing/domain/entities/licensing_grant.dart';
import '../../../features/licensing/domain/repositories/licensing_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [LicensingRepository].
class MockLicensingRepository implements LicensingRepository {
  MockLicensingRepository(this.store);

  final MockSeedStore store;

  static const _key = 'licensing_grants';

  void _ensureSeeded() {
    if (store.list<LicensingGrant>(_key).isNotEmpty) return;
    final now = DateTime.now();
    store.putAll(_key, [
      LicensingGrant(
        id: 'license-demo-1',
        collaborationId: MockIds.collab1,
        assetUrl: 'https://cdn.monk.local/assets/reel_final.mp4',
        token: 'lic-token-demo-1',
        scope: 'digital_only',
        territory: 'IN',
        durationDays: 180,
        fee: 25000,
        status: 'active',
        deliverableId: MockIds.content1,
        createdAt: now.subtract(const Duration(days: 10)).toIso8601String(),
        expiresAt: now.add(const Duration(days: 170)).toIso8601String(),
      ),
      LicensingGrant(
        id: 'license-demo-2',
        collaborationId: MockIds.collab1,
        assetUrl: 'https://cdn.monk.local/assets/still_pack.zip',
        token: 'lic-token-demo-2',
        scope: 'whitelisting',
        territory: 'worldwide',
        durationDays: 365,
        fee: 50000,
        status: 'active',
        createdAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        expiresAt: now.add(const Duration(days: 360)).toIso8601String(),
      ),
    ]);
  }

  @override
  Future<List<LicensingGrant>> getGrants({String? collaborationId}) async {
    await store.delay();
    _ensureSeeded();
    final all = store.list<LicensingGrant>(_key);
    if (collaborationId == null || collaborationId.isEmpty) return all;
    return all.where((g) => g.collaborationId == collaborationId).toList();
  }

  @override
  Future<LicensingGrant> getGrant(String id) async {
    await store.delay();
    _ensureSeeded();
    final grant = store.findWhere<LicensingGrant>(_key, (g) => g.id == id);
    if (grant == null) {
      throw NotFoundFailure('Licensing grant not found: $id');
    }
    return grant;
  }

  @override
  Future<LicensingGrant> createGrant(Map<String, dynamic> data) async {
    await store.delay();
    _ensureSeeded();
    final collaborationId = data['collaborationId'] as String? ?? '';
    if (collaborationId.isEmpty) {
      throw const ValidationFailure('collaborationId is required.');
    }
    final now = DateTime.now();
    final durationDays = (data['durationDays'] as num?)?.toInt() ?? 365;
    final grant = LicensingGrant(
      id: 'license-mock-${now.millisecondsSinceEpoch}',
      collaborationId: collaborationId,
      assetUrl: data['assetUrl'] as String? ??
          'https://cdn.monk.local/assets/licensed_asset.bin',
      token: 'lic-token-${now.millisecondsSinceEpoch}',
      scope: data['scope'] as String? ?? 'digital_only',
      territory: data['territory'] as String? ?? 'worldwide',
      durationDays: durationDays,
      fee: (data['fee'] as num?)?.toDouble() ?? 0,
      status: 'active',
      deliverableId: data['deliverableId'] as String?,
      createdAt: now.toIso8601String(),
      expiresAt: now.add(Duration(days: durationDays)).toIso8601String(),
    );
    store.add(_key, grant);
    return grant;
  }

  @override
  Future<LicensingGrant> revokeGrant(String id) async {
    await store.delay();
    _ensureSeeded();
    final existing =
        store.findWhere<LicensingGrant>(_key, (g) => g.id == id);
    if (existing == null) {
      throw NotFoundFailure('Licensing grant not found: $id');
    }
    if (existing.isRevoked) {
      throw const ConflictFailure('Grant is already revoked.');
    }
    final updated = LicensingGrant(
      id: existing.id,
      collaborationId: existing.collaborationId,
      assetUrl: existing.assetUrl,
      token: existing.token,
      scope: existing.scope,
      territory: existing.territory,
      durationDays: existing.durationDays,
      fee: existing.fee,
      status: 'revoked',
      deliverableId: existing.deliverableId,
      createdAt: existing.createdAt,
      expiresAt: existing.expiresAt,
    );
    store.replaceWhere<LicensingGrant>(_key, (g) => g.id == id, updated);
    return updated;
  }
}
