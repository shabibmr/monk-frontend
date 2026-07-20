import '../entities/brand.dart';

abstract class BrandRepository {
  Future<List<Brand>> listMine();
  Future<Brand> create(Map<String, dynamic> body);
  Future<Brand> getById(String brandId);
  Future<Brand> update(String brandId, Map<String, dynamic> body);
  Future<List<BrandMember>> listMembers(String brandId);
  Future<BrandInviteResult> inviteMember({
    required String brandId,
    required String email,
    required String memberRole,
    required List<String> permissions,
  });
  Future<void> removeMember({
    required String brandId,
    required String memberId,
  });
  Future<void> acceptInvite(String token);
}
