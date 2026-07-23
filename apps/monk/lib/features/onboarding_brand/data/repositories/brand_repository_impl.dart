import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  BrandRepositoryImpl(this._client);
  final MonkApiClient _client;

  Brand _map(BrandDto d) => Brand(
        id: d.id,
        companyName: d.companyName,
        website: d.website,
        industry: d.industry,
        gstVatNumber: d.gstVatNumber,
        country: d.country,
        timezone: d.timezone,
        address: d.address,
        contactPerson: d.contactPerson,
        contactEmail: d.contactEmail,
        contactPhone: d.contactPhone,
        verificationStatus: d.verificationStatus,
      );

  BrandMember _mapMember(BrandMemberDto d) => BrandMember(
        id: d.id,
        email: d.email,
        memberRole: d.memberRole,
        permissions: d.permissions,
        inviteStatus: d.inviteStatus,
      );

  @override
  Future<List<Brand>> listMine() async {
    try {
      final list = await _client.brands.listMine();
      return list.map(_map).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Brand> create(Map<String, dynamic> body) async {
    try {
      return _map(await _client.brands.create(body));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Brand> getById(String brandId) async {
    try {
      return _map(await _client.brands.getById(brandId));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Brand> update(String brandId, Map<String, dynamic> body) async {
    try {
      return _map(await _client.brands.update(brandId, body));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<BrandMember>> listMembers(String brandId) async {
    try {
      final list = await _client.brands.listMembers(brandId);
      return list.map(_mapMember).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<BrandInviteResult> inviteMember({
    required String brandId,
    required String email,
    required String memberRole,
    required List<String> permissions,
  }) async {
    try {
      final res = await _client.brands.inviteMember(
        brandId,
        email: email,
        memberRole: memberRole,
        permissions: permissions,
      );
      return BrandInviteResult(
        member: _mapMember(res.member),
        inviteTokenDev: res.inviteTokenDev,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> removeMember({
    required String brandId,
    required String memberId,
  }) async {
    try {
      await _client.brands.removeMember(brandId, memberId);
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> acceptInvite(String token) async {
    try {
      await _client.brands.acceptInvite(token);
    } catch (e) {
      throw mapError(e);
    }
  }
}
