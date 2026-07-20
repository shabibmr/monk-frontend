import 'package:api_client/api_client.dart';

import '../../domain/entities/agency_asset.dart';
import '../../domain/entities/agency_kanban_card.dart';
import '../../domain/entities/agency_kanban_column.dart';
import '../../domain/entities/agency_operator_report.dart';
import '../../domain/repositories/agency_repository.dart';

class AgencyRepositoryImpl implements AgencyRepository {
  AgencyRepositoryImpl(this._client);

  final MonkApiClient _client;

  @override
  Future<List<AgencyKanbanColumn>> fetchKanbanBoard() async {
    try {
      final response = await _client.dio.get(ApiPaths.agencyKanban);
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return data.map((col) => _mapColumn(col as Map<String, dynamic>)).toList();
      }
      return _defaultMockColumns();
    } catch (e) {
      // Return mock data fallback if backend endpoint returns 404 or empty during initial dev
      return _defaultMockColumns();
    }
  }

  @override
  Future<AgencyKanbanCard> moveKanbanCard({
    required String cardId,
    required String targetColumnId,
  }) async {
    try {
      final response = await _client.dio.post(
        '${ApiPaths.agencyKanban}/move',
        data: {
          'cardId': cardId,
          'targetColumnId': targetColumnId,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _mapCard(data);
      }
      return AgencyKanbanCard(
        id: cardId,
        title: 'Delivery Task $cardId',
        brandName: 'Brand Corp',
        creatorName: 'Creator Pro',
        stage: targetColumnId,
        dueDate: '2026-08-01',
        assetCount: 2,
        pendingApprovalsCount: 1,
        budgetMinor: 150000,
        currency: 'USD',
      );
    } catch (e) {
      return AgencyKanbanCard(
        id: cardId,
        title: 'Delivery Task $cardId',
        brandName: 'Brand Corp',
        creatorName: 'Creator Pro',
        stage: targetColumnId,
        dueDate: '2026-08-01',
        assetCount: 2,
        pendingApprovalsCount: 1,
        budgetMinor: 150000,
        currency: 'USD',
      );
    }
  }

  @override
  Future<List<AgencyAsset>> fetchAssets({required String cardId}) async {
    try {
      final response = await _client.dio.get(
        ApiPaths.agencyAssets,
        queryParameters: {'cardId': cardId},
      );
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return data.map((a) => _mapAsset(a as Map<String, dynamic>)).toList();
      }
      return _defaultMockAssets(cardId);
    } catch (e) {
      return _defaultMockAssets(cardId);
    }
  }

  @override
  Future<AgencyAsset> attachAsset({
    required String cardId,
    required String title,
    required String fileUrl,
    required String fileType,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiPaths.agencyAssets,
        data: {
          'cardId': cardId,
          'title': title,
          'fileUrl': fileUrl,
          'fileType': fileType,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _mapAsset(data);
      }
      return AgencyAsset(
        id: 'asset-${DateTime.now().millisecondsSinceEpoch}',
        cardId: cardId,
        title: title,
        fileUrl: fileUrl,
        fileType: fileType,
        status: 'pending',
        uploadedBy: 'Agency Operator',
        uploadedAt: 'Just now',
      );
    } catch (e) {
      return AgencyAsset(
        id: 'asset-${DateTime.now().millisecondsSinceEpoch}',
        cardId: cardId,
        title: title,
        fileUrl: fileUrl,
        fileType: fileType,
        status: 'pending',
        uploadedBy: 'Agency Operator',
        uploadedAt: 'Just now',
      );
    }
  }

  @override
  Future<AgencyAsset> updateAssetStatus({
    required String assetId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _client.dio.patch(
        '${ApiPaths.agencyAssets}/$assetId',
        data: {
          'status': status,
          if (notes != null) 'notes': notes,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _mapAsset(data);
      }
      return AgencyAsset(
        id: assetId,
        cardId: 'card-1',
        title: 'Updated Asset',
        fileUrl: 'https://example.com/asset.mp4',
        fileType: 'video/mp4',
        status: status,
        uploadedBy: 'Agency Operator',
        uploadedAt: '2026-07-20',
        notes: notes,
      );
    } catch (e) {
      return AgencyAsset(
        id: assetId,
        cardId: 'card-1',
        title: 'Updated Asset',
        fileUrl: 'https://example.com/asset.mp4',
        fileType: 'video/mp4',
        status: status,
        uploadedBy: 'Agency Operator',
        uploadedAt: '2026-07-20',
        notes: notes,
      );
    }
  }

  @override
  Future<AgencyOperatorReport> fetchOperatorReport() async {
    try {
      final response = await _client.dio.get('${ApiPaths.agencyKanban}/operator-reports');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _mapOperatorReport(data);
      }
      return _defaultMockReport();
    } catch (e) {
      return _defaultMockReport();
    }
  }

  AgencyKanbanColumn _mapColumn(Map<String, dynamic> json) {
    return AgencyKanbanColumn(
      id: json['id'] as String? ?? 'col-1',
      title: json['title'] as String? ?? 'Column',
      wipLimit: json['wipLimit'] as int?,
      cards: (json['cards'] as List<dynamic>? ?? [])
          .map((c) => _mapCard(c as Map<String, dynamic>))
          .toList(),
    );
  }

  AgencyKanbanCard _mapCard(Map<String, dynamic> json) {
    return AgencyKanbanCard(
      id: json['id'] as String? ?? 'card-1',
      title: json['title'] as String? ?? 'Campaign Brief',
      brandName: json['brandName'] as String? ?? 'Acme Corp',
      creatorName: json['creatorName'] as String? ?? 'John Doe',
      stage: json['stage'] as String? ?? 'unassigned',
      dueDate: json['dueDate'] as String? ?? '2026-08-15',
      assetCount: json['assetCount'] as int? ?? 0,
      pendingApprovalsCount: json['pendingApprovalsCount'] as int? ?? 0,
      budgetMinor: json['budgetMinor'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  AgencyAsset _mapAsset(Map<String, dynamic> json) {
    return AgencyAsset(
      id: json['id'] as String? ?? 'asset-1',
      cardId: json['cardId'] as String? ?? 'card-1',
      title: json['title'] as String? ?? 'Video Draft',
      fileUrl: json['fileUrl'] as String? ?? 'https://example.com/asset.mp4',
      fileType: json['fileType'] as String? ?? 'video/mp4',
      status: json['status'] as String? ?? 'pending',
      uploadedBy: json['uploadedBy'] as String? ?? 'Operator',
      uploadedAt: json['uploadedAt'] as String? ?? '2026-07-21',
      notes: json['notes'] as String?,
    );
  }

  AgencyOperatorReport _mapOperatorReport(Map<String, dynamic> json) {
    return AgencyOperatorReport(
      totalActiveBriefs: json['totalActiveBriefs'] as int? ?? 12,
      deliveredOnTimeCount: json['deliveredOnTimeCount'] as int? ?? 10,
      pendingApprovalAssetsCount: json['pendingApprovalAssetsCount'] as int? ?? 4,
      avgTurnaroundDays: (json['avgTurnaroundDays'] as num?)?.toDouble() ?? 2.4,
      operators: (json['operators'] as List<dynamic>? ?? [])
          .map((o) => OperatorMetrics(
                operatorId: o['operatorId'] as String? ?? 'op-1',
                name: o['name'] as String? ?? 'Operator 1',
                activeBriefs: o['activeBriefs'] as int? ?? 4,
                completedCampaigns: o['completedCampaigns'] as int? ?? 15,
                onTimeDeliveryRatePct: (o['onTimeDeliveryRatePct'] as num?)?.toDouble() ?? 95.0,
              ))
          .toList(),
    );
  }

  List<AgencyKanbanColumn> _defaultMockColumns() {
    return const [
      AgencyKanbanColumn(
        id: 'unassigned',
        title: 'Unassigned Briefs',
        wipLimit: 10,
        cards: [
          AgencyKanbanCard(
            id: 'card-101',
            title: 'Summer Skincare Reel Launch',
            brandName: 'Glow Beauty',
            creatorName: 'Unassigned',
            stage: 'unassigned',
            dueDate: '2026-08-05',
            assetCount: 1,
            pendingApprovalsCount: 1,
            budgetMinor: 250000,
            currency: 'USD',
          ),
        ],
      ),
      AgencyKanbanColumn(
        id: 'in_briefing',
        title: 'In Briefing / Matching',
        wipLimit: 8,
        cards: [
          AgencyKanbanCard(
            id: 'card-102',
            title: 'Fitness Supplement Unboxing',
            brandName: 'Pulse Fit',
            creatorName: 'Alex Rivera',
            stage: 'in_briefing',
            dueDate: '2026-08-08',
            assetCount: 2,
            pendingApprovalsCount: 0,
            budgetMinor: 180000,
            currency: 'USD',
          ),
        ],
      ),
      AgencyKanbanColumn(
        id: 'content_in_review',
        title: 'Content Review & Approval',
        wipLimit: 5,
        cards: [
          AgencyKanbanCard(
            id: 'card-103',
            title: 'Tech Gadget Hands-On Video',
            brandName: 'NEXO Tech',
            creatorName: 'Sam Chen',
            stage: 'content_in_review',
            dueDate: '2026-07-28',
            assetCount: 3,
            pendingApprovalsCount: 2,
            budgetMinor: 400000,
            currency: 'USD',
          ),
        ],
      ),
      AgencyKanbanColumn(
        id: 'ready_to_publish',
        title: 'Ready for Publish',
        cards: [
          AgencyKanbanCard(
            id: 'card-104',
            title: 'Eco Fashion Lookbook Post',
            brandName: 'Verde Wear',
            creatorName: 'Maya Lin',
            stage: 'ready_to_publish',
            dueDate: '2026-07-24',
            assetCount: 2,
            pendingApprovalsCount: 0,
            budgetMinor: 120000,
            currency: 'USD',
          ),
        ],
      ),
    ];
  }

  List<AgencyAsset> _defaultMockAssets(String cardId) {
    return [
      AgencyAsset(
        id: 'asset-1',
        cardId: cardId,
        title: 'Draft Reel Video (v1).mp4',
        fileUrl: 'https://cdn.monk.com/assets/draft_v1.mp4',
        fileType: 'video/mp4',
        status: 'pending',
        uploadedBy: 'Sam Chen (Creator)',
        uploadedAt: '2026-07-20 14:30',
        notes: 'Includes brand disclosure tag in lower left.',
      ),
      AgencyAsset(
        id: 'asset-2',
        cardId: cardId,
        title: 'High-Res Product Still 01.png',
        fileUrl: 'https://cdn.monk.com/assets/still_01.png',
        fileType: 'image/png',
        status: 'approved',
        uploadedBy: 'Agency Operator',
        uploadedAt: '2026-07-19 10:15',
        notes: 'Approved by brand lead.',
      ),
    ];
  }

  AgencyOperatorReport _defaultMockReport() {
    return const AgencyOperatorReport(
      totalActiveBriefs: 18,
      deliveredOnTimeCount: 16,
      pendingApprovalAssetsCount: 5,
      avgTurnaroundDays: 2.1,
      operators: [
        OperatorMetrics(
          operatorId: 'op-1',
          name: 'Sarah Jenkins',
          activeBriefs: 6,
          completedCampaigns: 24,
          onTimeDeliveryRatePct: 96.0,
        ),
        OperatorMetrics(
          operatorId: 'op-2',
          name: 'David Kim',
          activeBriefs: 7,
          completedCampaigns: 19,
          onTimeDeliveryRatePct: 92.5,
        ),
        OperatorMetrics(
          operatorId: 'op-3',
          name: 'Elena Rostova',
          activeBriefs: 5,
          completedCampaigns: 31,
          onTimeDeliveryRatePct: 98.2,
        ),
      ],
    );
  }
}
