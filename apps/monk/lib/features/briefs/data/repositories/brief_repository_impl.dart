import 'package:api_client/api_client.dart';

import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/brief.dart';
import '../../domain/repositories/brief_repository.dart';

class BriefRepositoryImpl implements BriefRepository {
  BriefRepositoryImpl(this._client);
  final MonkApiClient _client;

  Brief _map(BriefDto d, {String managedFeeMode = 'none', int? agencyFeeMinor}) =>
      Brief(
        id: d.id,
        brandId: d.brandId,
        campaignId: d.campaignId,
        goals: d.goals,
        status: d.status,
        budgetMinor: d.budgetMinor,
        currency: d.currency,
        productDescription: d.productDescription,
        notes: d.notes,
        managedFeeMode: managedFeeMode,
        agencyFeeMinor: agencyFeeMinor,
      );

  @override
  Future<SubmitBriefResult> submit(Map<String, dynamic> body) async {
    try {
      final r = await _client.briefs.submit(body);
      return SubmitBriefResult(
        brief: _map(
          r.brief,
          managedFeeMode: r.managedFeeMode,
          agencyFeeMinor: r.agencyFeeMinor,
        ),
        campaignId: r.campaignId,
        managedFeeMode: r.managedFeeMode,
        agencyFeeMinor: r.agencyFeeMinor,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Brief>> listMine() async {
    try {
      final list = await _client.briefs.listMine();
      return list.map(_map).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<List<Brief>> agencyList({String? status}) async {
    try {
      final list = await _client.briefs.agencyList(status: status);
      return list.map(_map).toList();
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<Brief> triage(String id, {String? notes}) async {
    try {
      return _map(await _client.briefs.triage(id, notes: notes));
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<SubmitBriefResult> convert(String id) async {
    try {
      final r = await _client.briefs.convert(id);
      return SubmitBriefResult(
        brief: _map(
          r.brief,
          managedFeeMode: r.managedFeeMode,
          agencyFeeMinor: r.agencyFeeMinor,
        ),
        campaignId: r.campaignId,
        managedFeeMode: r.managedFeeMode,
        agencyFeeMinor: r.agencyFeeMinor,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  @override
  Future<void> assignInfluencers({
    required String campaignId,
    required List<String> profileIds,
  }) async {
    try {
      await _client.briefs.assignInfluencers(
        campaignId: campaignId,
        profileIds: profileIds,
      );
    } catch (e) {
      throw mapError(e);
    }
  }
}
