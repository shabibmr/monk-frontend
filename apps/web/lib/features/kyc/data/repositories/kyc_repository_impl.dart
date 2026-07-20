import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/kyc.dart';
import '../../domain/repositories/kyc_repository.dart';

class KycRepositoryImpl implements KycRepository {
  KycRepositoryImpl(this._client);
  final MonkApiClient _client;

  KycRecord _map(KycRecordDto d) => KycRecord(
        id: d.id,
        status: d.status,
        influencerProfileId: d.influencerProfileId,
        identityDocFileId: d.identityDocFileId,
        gstRegistered: d.gstRegistered,
        panMasked: d.panMasked,
        gstMasked: d.gstMasked,
        accountMasked: d.accountMasked,
        rejectionReason: d.rejectionReason,
      );

  MediaLicense _mapLic(MediaLicenseDto d) => MediaLicense(
        id: d.id,
        licenseNumber: d.licenseNumber,
        status: d.status,
        expiryDate: d.expiryDate,
        issuingAuthority: d.issuingAuthority,
      );

  @override
  Future<({List<KycRecord> records, List<MediaLicense> licenses})> getMyKyc(
    String profileId,
  ) async {
    try {
      final res = await _client.kyc.me(profileId);
      return (
        records: res.data.map(_map).toList(),
        licenses: res.licenses.map(_mapLic).toList(),
      );
    } catch (e) {
      throw mapError(e);
    }
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
    try {
      final body = <String, dynamic>{
        'profileId': profileId,
        if (identityDocFileId != null && identityDocFileId.isNotEmpty)
          'identityDocFileId': identityDocFileId,
        if (panNumber != null && panNumber.isNotEmpty) 'panNumber': panNumber,
        if (gstRegistered != null) 'gstRegistered': gstRegistered,
        if (gstNumber != null && gstNumber.isNotEmpty) 'gstNumber': gstNumber,
      };
      if (accountNumber != null || ifsc != null || iban != null) {
        body['payoutDetails'] = {
          if (accountNumber != null && accountNumber.isNotEmpty)
            'accountNumber': accountNumber,
          if (ifsc != null && ifsc.isNotEmpty) 'ifsc': ifsc,
          if (iban != null && iban.isNotEmpty) 'iban': iban,
        };
      }
      if (uaeLicenseNumber != null && uaeLicenseNumber.isNotEmpty) {
        body['uaeLicense'] = {
          'licenseNumber': uaeLicenseNumber,
          if (uaeDocFileId != null && uaeDocFileId.isNotEmpty)
            'documentFileId': uaeDocFileId,
          if (uaeAuthority != null && uaeAuthority.isNotEmpty)
            'issuingAuthority': uaeAuthority,
          if (uaeExpiryDate != null) 'expiryDate': uaeExpiryDate,
        };
      }
      final dto = await _client.kyc.submit(body);
      return _map(dto);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<UaeGateResult> checkUaeGate({
    required String profileId,
    required String collabType,
  }) async {
    try {
      final r = await _client.kyc.uaeGate(
        profileId: profileId,
        collabType: collabType,
      );
      return UaeGateResult(
        allowed: r.allowed,
        reason: r.reason,
        code: r.code,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<({List<QueueInfluencer> influencers, List<KycRecord> kyc})>
      adminQueue() async {
    try {
      final q = await _client.kyc.adminQueue();
      return (
        influencers: q.influencers
            .map(
              (e) => QueueInfluencer(
                id: e.id,
                displayName: e.displayName,
                country: e.country,
                verificationStatus: e.verificationStatus,
              ),
            )
            .toList(),
        kyc: q.kyc.map(_map).toList(),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<KycRecord> adminApprove(String kycId) async {
    try {
      return _map(await _client.kyc.adminApprove(kycId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<KycRecord> adminReject(
    String kycId, {
    String? templateKey,
    String? reason,
  }) async {
    try {
      return _map(
        await _client.kyc.adminReject(
          kycId,
          templateKey: templateKey,
          reason: reason,
        ),
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<RejectionTemplate>> rejectionTemplates() async {
    try {
      final list = await _client.kyc.rejectionTemplates();
      return list
          .map(
            (t) => RejectionTemplate(
              key: t.key,
              body: t.body,
              category: t.category,
            ),
          )
          .toList();
    } catch (e) {
      throw mapError(e);
    }
  }
}
