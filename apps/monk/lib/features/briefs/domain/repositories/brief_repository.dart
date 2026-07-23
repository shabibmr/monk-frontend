import '../entities/brief.dart';

abstract class BriefRepository {
  Future<SubmitBriefResult> submit(Map<String, dynamic> body);
  Future<List<Brief>> listMine();
  Future<List<Brief>> agencyList({String? status});
  Future<Brief> triage(String id, {String? notes});
  Future<SubmitBriefResult> convert(String id);
  Future<void> assignInfluencers({
    required String campaignId,
    required List<String> profileIds,
  });
}
