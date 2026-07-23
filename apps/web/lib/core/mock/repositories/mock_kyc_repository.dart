import '../../../features/kyc/domain/entities/kyc.dart';
import '../../../features/kyc/domain/repositories/kyc_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [KycRepository].
///
/// Store keys (aligned with `seed_platform.dart`):
/// - `kyc_records` → `List<KycRecord>`
/// - `kyc_queue` → `List<QueueInfluencer>`
/// - `media_licenses` → `List<MediaLicense>`
/// - `rejection_templates` → `List<RejectionTemplate>`
class MockKycRepository implements KycRepository {
  MockKycRepository({required MockSeedStore store}) : _store = store;

  final MockSeedStore _store;

  static const kycKey = 'kyc_records';
  static const queueKey = 'kyc_queue';
  static const licensesKey = 'media_licenses';
  static const templatesKey = 'rejection_templates';

  @override
  Future<({List<KycRecord> records, List<MediaLicense> licenses})> getMyKyc(
    String profileId,
  ) async {
    await _store.delay();
    final records = _store
        .list<KycRecord>(kycKey)
        .where((r) => r.influencerProfileId == profileId)
        .toList();
    final licenses = _store.list<MediaLicense>(licensesKey);
    return (records: records, licenses: licenses);
  }

  @override
  Future<KycRecord> submit({
    required String profileId,
    String? identityDocFileId,
    String? accountNumber,
    String? ifsc,
    String? iban,
    String? panNumber,
    bool? gstRegistered,
    String? gstNumber,
    String? uaeLicenseNumber,
    String? uaeDocFileId,
    String? uaeAuthority,
    String? uaeExpiryDate,
  }) async {
    await _store.delay();
    if (profileId.isEmpty) {
      throw const ValidationFailure('profileId is required');
    }

    String? mask(String? value, {int keep = 4}) {
      if (value == null || value.isEmpty) return null;
      if (value.length <= keep) return '*' * value.length;
      return '${'*' * (value.length - keep)}${value.substring(value.length - keep)}';
    }

    final existing = _store.findWhere<KycRecord>(
      kycKey,
      (r) => r.influencerProfileId == profileId,
    );

    final record = KycRecord(
      id: existing?.id ?? 'kyc-${DateTime.now().millisecondsSinceEpoch}',
      status: 'pending',
      influencerProfileId: profileId,
      identityDocFileId: identityDocFileId ?? existing?.identityDocFileId,
      gstRegistered: gstRegistered ?? existing?.gstRegistered,
      panMasked: mask(panNumber) ?? existing?.panMasked,
      gstMasked: mask(gstNumber) ?? existing?.gstMasked,
      accountMasked: mask(accountNumber) ?? existing?.accountMasked,
    );

    _store.replaceWhere<KycRecord>(
      kycKey,
      (r) =>
          r.influencerProfileId == profileId ||
          (existing != null && r.id == existing.id),
      record,
    );

    if (uaeLicenseNumber != null && uaeLicenseNumber.isNotEmpty) {
      _store.add(
        licensesKey,
        MediaLicense(
          id: 'lic-${DateTime.now().millisecondsSinceEpoch}',
          licenseNumber: uaeLicenseNumber,
          status: 'valid',
          expiryDate: uaeExpiryDate != null
              ? DateTime.tryParse(uaeExpiryDate)
              : null,
          issuingAuthority: uaeAuthority,
        ),
      );
    }

    final queue = _store.list<QueueInfluencer>(queueKey);
    if (!queue.any((q) => q.id == profileId)) {
      _store.add(
        queueKey,
        QueueInfluencer(
          id: profileId,
          displayName: profileId == MockIds.influencer1
              ? 'Arjun Creates'
              : profileId,
          country: 'IN',
          verificationStatus: 'pending',
        ),
      );
    } else {
      _store.replaceWhere<QueueInfluencer>(
        queueKey,
        (q) => q.id == profileId,
        QueueInfluencer(
          id: profileId,
          displayName: _queueName(profileId),
          country: 'IN',
          verificationStatus: 'pending',
        ),
      );
    }

    return record;
  }

  @override
  Future<UaeGateResult> checkUaeGate({
    required String profileId,
    required String collabType,
  }) async {
    await _store.delay();
    return const UaeGateResult(
      allowed: true,
      reason: 'Demo mode — UAE gate open',
      code: 'UAE_GATE_ALLOW',
    );
  }

  @override
  Future<({List<QueueInfluencer> influencers, List<KycRecord> kyc})>
      adminQueue() async {
    await _store.delay();
    var influencers = _store.list<QueueInfluencer>(queueKey);
    var kyc = _store.list<KycRecord>(kycKey);

    if (influencers.isEmpty && kyc.isEmpty) {
      // Minimal fallback if seed not loaded.
      _store.putAll(kycKey, [
        const KycRecord(
          id: MockIds.kyc1,
          status: 'pending',
          influencerProfileId: MockIds.influencer3,
          panMasked: 'XXXXXX1234',
          accountMasked: 'XXXX4521',
        ),
      ]);
      _store.putAll(queueKey, [
        const QueueInfluencer(
          id: MockIds.influencer3,
          displayName: 'Dev Tech Reviews',
          country: 'IN',
          verificationStatus: 'pending',
        ),
      ]);
      influencers = _store.list<QueueInfluencer>(queueKey);
      kyc = _store.list<KycRecord>(kycKey);
    }

    return (influencers: influencers, kyc: kyc);
  }

  @override
  Future<KycRecord> adminApprove(String kycId) async {
    await _store.delay();
    final existing = _store.findWhere<KycRecord>(kycKey, (r) => r.id == kycId);
    if (existing == null) {
      throw NotFoundFailure('KYC not found: $kycId');
    }
    final approved = KycRecord(
      id: existing.id,
      status: 'approved',
      influencerProfileId: existing.influencerProfileId,
      identityDocFileId: existing.identityDocFileId,
      gstRegistered: existing.gstRegistered,
      panMasked: existing.panMasked,
      gstMasked: existing.gstMasked,
      accountMasked: existing.accountMasked,
    );
    _store.replaceWhere<KycRecord>(kycKey, (r) => r.id == kycId, approved);

    final profileId = existing.influencerProfileId;
    if (profileId != null) {
      _store.replaceWhere<QueueInfluencer>(
        queueKey,
        (q) => q.id == profileId,
        QueueInfluencer(
          id: profileId,
          displayName: _queueName(profileId),
          country: 'IN',
          verificationStatus: 'approved',
        ),
      );
    }
    return approved;
  }

  @override
  Future<KycRecord> adminReject(
    String kycId, {
    String? templateKey,
    String? reason,
  }) async {
    await _store.delay();
    final existing = _store.findWhere<KycRecord>(kycKey, (r) => r.id == kycId);
    if (existing == null) {
      throw NotFoundFailure('KYC not found: $kycId');
    }

    String? rejection = reason;
    if (rejection == null && templateKey != null) {
      final templates = await rejectionTemplates();
      final match = templates.where((t) => t.key == templateKey);
      rejection =
          match.isEmpty ? templateKey : (match.first.body ?? templateKey);
    }
    rejection ??= 'Rejected in demo';

    final rejected = KycRecord(
      id: existing.id,
      status: 'rejected',
      influencerProfileId: existing.influencerProfileId,
      identityDocFileId: existing.identityDocFileId,
      gstRegistered: existing.gstRegistered,
      panMasked: existing.panMasked,
      gstMasked: existing.gstMasked,
      accountMasked: existing.accountMasked,
      rejectionReason: rejection,
    );
    _store.replaceWhere<KycRecord>(kycKey, (r) => r.id == kycId, rejected);

    final profileId = existing.influencerProfileId;
    if (profileId != null) {
      _store.replaceWhere<QueueInfluencer>(
        queueKey,
        (q) => q.id == profileId,
        QueueInfluencer(
          id: profileId,
          displayName: _queueName(profileId),
          country: 'IN',
          verificationStatus: 'rejected',
        ),
      );
    }
    return rejected;
  }

  @override
  Future<List<RejectionTemplate>> rejectionTemplates() async {
    await _store.delay();
    final existing = _store.list<RejectionTemplate>(templatesKey);
    if (existing.isNotEmpty) return existing;

    const seeded = [
      RejectionTemplate(
        key: 'doc_expired',
        category: 'kyc',
        body: 'Identity document expired — please re-upload a valid ID.',
      ),
      RejectionTemplate(
        key: 'blurry_scan',
        category: 'kyc',
        body: 'Document image is unreadable. Upload a clear scan or photo.',
      ),
      RejectionTemplate(
        key: 'name_mismatch',
        category: 'kyc',
        body: 'Name on document does not match profile legal name.',
      ),
    ];
    _store.putAll(templatesKey, seeded);
    return seeded;
  }

  String _queueName(String profileId) {
    final q = _store.findWhere<QueueInfluencer>(
      queueKey,
      (e) => e.id == profileId,
    );
    if (q?.displayName != null) return q!.displayName!;
    switch (profileId) {
      case MockIds.influencer1:
        return 'Arjun Creates';
      case MockIds.influencer2:
        return 'Nisha Vlogs';
      case MockIds.influencer3:
        return 'Dev Tech Reviews';
      default:
        return profileId;
    }
  }
}
