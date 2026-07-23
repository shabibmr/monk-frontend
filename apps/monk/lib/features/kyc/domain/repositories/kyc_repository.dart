import '../entities/kyc.dart';

abstract class KycRepository {
  Future<({List<KycRecord> records, List<MediaLicense> licenses})> getMyKyc(
    String profileId,
  );

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
  });

  Future<UaeGateResult> checkUaeGate({
    required String profileId,
    required String collabType,
  });

  Future<({List<QueueInfluencer> influencers, List<KycRecord> kyc})>
      adminQueue();

  Future<KycRecord> adminApprove(String kycId);

  Future<KycRecord> adminReject(
    String kycId, {
    String? templateKey,
    String? reason,
  });

  Future<List<RejectionTemplate>> rejectionTemplates();
}
