import '../entities/licensing_grant.dart';

abstract class LicensingRepository {
  Future<List<LicensingGrant>> getGrants({String? collaborationId});
  Future<LicensingGrant> getGrant(String id);
  Future<LicensingGrant> createGrant(Map<String, dynamic> data);
  Future<LicensingGrant> revokeGrant(String id);
}
