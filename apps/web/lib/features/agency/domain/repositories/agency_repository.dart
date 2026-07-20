import '../entities/agency_asset.dart';
import '../entities/agency_kanban_card.dart';
import '../entities/agency_kanban_column.dart';
import '../entities/agency_operator_report.dart';

abstract class AgencyRepository {
  Future<List<AgencyKanbanColumn>> fetchKanbanBoard();
  Future<AgencyKanbanCard> moveKanbanCard({
    required String cardId,
    required String targetColumnId,
  });
  Future<List<AgencyAsset>> fetchAssets({required String cardId});
  Future<AgencyAsset> attachAsset({
    required String cardId,
    required String title,
    required String fileUrl,
    required String fileType,
  });
  Future<AgencyAsset> updateAssetStatus({
    required String assetId,
    required String status,
    String? notes,
  });
  Future<AgencyOperatorReport> fetchOperatorReport();
}
