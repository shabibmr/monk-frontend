import '../../../features/agency/domain/entities/agency_asset.dart';
import '../../../features/agency/domain/entities/agency_kanban_card.dart';
import '../../../features/agency/domain/entities/agency_kanban_column.dart';
import '../../../features/agency/domain/entities/agency_operator_report.dart';
import '../../../features/agency/domain/repositories/agency_repository.dart';
import '../../errors/failures.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [AgencyRepository].
class MockAgencyRepository implements AgencyRepository {
  MockAgencyRepository(this.store);

  final MockSeedStore store;

  static const _columnsKey = 'agency_columns';
  static const _assetsKey = 'agency_assets';
  static const _reportKey = 'agency_report';

  void _ensureSeeded() {
    if (store.list<AgencyKanbanColumn>(_columnsKey).isNotEmpty) return;
    store.putAll(_columnsKey, [
      const AgencyKanbanColumn(
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
            currency: 'INR',
          ),
        ],
      ),
      const AgencyKanbanColumn(
        id: 'in_briefing',
        title: 'In Briefing / Matching',
        wipLimit: 8,
        cards: [
          AgencyKanbanCard(
            id: 'card-102',
            title: 'Fitness Supplement Unboxing',
            brandName: 'Pulse Fit',
            creatorName: 'Arjun Creates',
            stage: 'in_briefing',
            dueDate: '2026-08-08',
            assetCount: 2,
            pendingApprovalsCount: 0,
            budgetMinor: 180000,
            currency: 'INR',
          ),
        ],
      ),
      const AgencyKanbanColumn(
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
            currency: 'INR',
          ),
        ],
      ),
      const AgencyKanbanColumn(
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
            currency: 'INR',
          ),
        ],
      ),
    ]);

    store.putAll(_assetsKey, [
      const AgencyAsset(
        id: 'asset-1',
        cardId: 'card-103',
        title: 'Draft Reel Video (v1).mp4',
        fileUrl: 'https://cdn.monk.local/assets/draft_v1.mp4',
        fileType: 'video/mp4',
        status: 'pending',
        uploadedBy: 'Sam Chen (Creator)',
        uploadedAt: '2026-07-20 14:30',
        notes: 'Includes brand disclosure tag in lower left.',
      ),
      const AgencyAsset(
        id: 'asset-2',
        cardId: 'card-103',
        title: 'High-Res Product Still 01.png',
        fileUrl: 'https://cdn.monk.local/assets/still_01.png',
        fileType: 'image/png',
        status: 'approved',
        uploadedBy: 'Agency Operator',
        uploadedAt: '2026-07-19 10:15',
        notes: 'Approved by brand lead.',
      ),
      const AgencyAsset(
        id: 'asset-3',
        cardId: 'card-101',
        title: 'Mood board.pdf',
        fileUrl: 'https://cdn.monk.local/assets/moodboard.pdf',
        fileType: 'application/pdf',
        status: 'pending',
        uploadedBy: 'Alex Agency',
        uploadedAt: '2026-07-21 09:00',
      ),
      const AgencyAsset(
        id: 'asset-4',
        cardId: 'card-102',
        title: 'Unboxing script.docx',
        fileUrl: 'https://cdn.monk.local/assets/script.docx',
        fileType: 'application/docx',
        status: 'approved',
        uploadedBy: 'Arjun Creates',
        uploadedAt: '2026-07-18 16:45',
      ),
      const AgencyAsset(
        id: 'asset-5',
        cardId: 'card-104',
        title: 'Lookbook final.zip',
        fileUrl: 'https://cdn.monk.local/assets/lookbook.zip',
        fileType: 'application/zip',
        status: 'approved',
        uploadedBy: 'Maya Lin',
        uploadedAt: '2026-07-22 11:20',
      ),
    ]);

    store.singles[_reportKey] = AgencyOperatorReport(
      totalActiveBriefs: 18,
      deliveredOnTimeCount: 16,
      pendingApprovalAssetsCount: 5,
      avgTurnaroundDays: 2.1,
      operators: [
        OperatorMetrics(
          operatorId: MockIds.agency1,
          name: 'Alex Agency',
          activeBriefs: 6,
          completedCampaigns: 24,
          onTimeDeliveryRatePct: 96.0,
        ),
        const OperatorMetrics(
          operatorId: 'op-2',
          name: 'David Kim',
          activeBriefs: 7,
          completedCampaigns: 19,
          onTimeDeliveryRatePct: 92.5,
        ),
        const OperatorMetrics(
          operatorId: 'op-3',
          name: 'Elena Rostova',
          activeBriefs: 5,
          completedCampaigns: 31,
          onTimeDeliveryRatePct: 98.2,
        ),
      ],
    );
  }

  (AgencyKanbanColumn, AgencyKanbanCard)? _findCard(String cardId) {
    for (final col in store.list<AgencyKanbanColumn>(_columnsKey)) {
      for (final card in col.cards) {
        if (card.id == cardId) return (col, card);
      }
    }
    return null;
  }

  @override
  Future<List<AgencyKanbanColumn>> fetchKanbanBoard() async {
    await store.delay();
    _ensureSeeded();
    return store.list<AgencyKanbanColumn>(_columnsKey);
  }

  @override
  Future<AgencyKanbanCard> moveKanbanCard({
    required String cardId,
    required String targetColumnId,
  }) async {
    await store.delay();
    _ensureSeeded();
    final found = _findCard(cardId);
    if (found == null) {
      throw NotFoundFailure('Kanban card not found: $cardId');
    }
    final columns = store.list<AgencyKanbanColumn>(_columnsKey);
    AgencyKanbanColumn? target;
    for (final col in columns) {
      if (col.id == targetColumnId) {
        target = col;
        break;
      }
    }
    if (target == null) {
      throw NotFoundFailure('Target column not found: $targetColumnId');
    }
    if (target.wipLimit != null &&
        target.cards.length >= target.wipLimit! &&
        found.$1.id != targetColumnId) {
      throw ConflictFailure(
        'Column "${target.title}" is at WIP limit (${target.wipLimit}).',
      );
    }

    final moved = found.$2.copyWith(stage: targetColumnId);
    final updatedColumns = columns.map((col) {
      if (col.id == found.$1.id && col.id == targetColumnId) {
        // Same column — just refresh stage field.
        return col.copyWith(
          cards: col.cards
              .map((c) => c.id == cardId ? moved : c)
              .toList(),
        );
      }
      if (col.id == found.$1.id) {
        return col.copyWith(
          cards: col.cards.where((c) => c.id != cardId).toList(),
        );
      }
      if (col.id == targetColumnId) {
        return col.copyWith(cards: [...col.cards, moved]);
      }
      return col;
    }).toList();

    store.putAll(_columnsKey, updatedColumns);
    return moved;
  }

  @override
  Future<List<AgencyAsset>> fetchAssets({required String cardId}) async {
    await store.delay();
    _ensureSeeded();
    return store
        .list<AgencyAsset>(_assetsKey)
        .where((a) => a.cardId == cardId)
        .toList();
  }

  @override
  Future<AgencyAsset> attachAsset({
    required String cardId,
    required String title,
    required String fileUrl,
    required String fileType,
  }) async {
    await store.delay();
    _ensureSeeded();
    if (_findCard(cardId) == null) {
      throw NotFoundFailure('Kanban card not found: $cardId');
    }
    if (title.trim().isEmpty || fileUrl.trim().isEmpty) {
      throw const ValidationFailure('title and fileUrl are required.');
    }
    final asset = AgencyAsset(
      id: 'asset-mock-${DateTime.now().millisecondsSinceEpoch}',
      cardId: cardId,
      title: title,
      fileUrl: fileUrl,
      fileType: fileType,
      status: 'pending',
      uploadedBy: store.findAccountById(store.currentUserId ?? MockIds.agency1)
              ?.user
              .fullName ??
          'Agency Operator',
      uploadedAt: 'Just now',
    );
    store.add(_assetsKey, asset);

    // Bump asset count on the card.
    final found = _findCard(cardId);
    if (found != null) {
      final updatedCard = found.$2.copyWith(
        assetCount: found.$2.assetCount + 1,
        pendingApprovalsCount: found.$2.pendingApprovalsCount + 1,
      );
      final columns = store.list<AgencyKanbanColumn>(_columnsKey).map((col) {
        if (col.id != found.$1.id) return col;
        return col.copyWith(
          cards: col.cards
              .map((c) => c.id == cardId ? updatedCard : c)
              .toList(),
        );
      }).toList();
      store.putAll(_columnsKey, columns);
    }
    return asset;
  }

  @override
  Future<AgencyAsset> updateAssetStatus({
    required String assetId,
    required String status,
    String? notes,
  }) async {
    await store.delay();
    _ensureSeeded();
    final allowed = {'pending', 'approved', 'rejected'};
    if (!allowed.contains(status)) {
      throw ValidationFailure(
        'Invalid asset status "$status". Allowed: ${allowed.join(', ')}',
      );
    }
    final existing =
        store.findWhere<AgencyAsset>(_assetsKey, (a) => a.id == assetId);
    if (existing == null) {
      throw NotFoundFailure('Asset not found: $assetId');
    }
    final updated = existing.copyWith(status: status, notes: notes);
    store.replaceWhere<AgencyAsset>(_assetsKey, (a) => a.id == assetId, updated);

    // Adjust pending count on parent card when leaving pending.
    if (existing.status == 'pending' && status != 'pending') {
      final found = _findCard(existing.cardId);
      if (found != null) {
        final nextPending =
            (found.$2.pendingApprovalsCount - 1).clamp(0, 9999);
        final updatedCard =
            found.$2.copyWith(pendingApprovalsCount: nextPending);
        final columns = store.list<AgencyKanbanColumn>(_columnsKey).map((col) {
          if (col.id != found.$1.id) return col;
          return col.copyWith(
            cards: col.cards
                .map((c) => c.id == existing.cardId ? updatedCard : c)
                .toList(),
          );
        }).toList();
        store.putAll(_columnsKey, columns);
      }
    }
    return updated;
  }

  @override
  Future<AgencyOperatorReport> fetchOperatorReport() async {
    await store.delay();
    _ensureSeeded();
    final report = store.singles[_reportKey];
    if (report is AgencyOperatorReport) return report;
    return const AgencyOperatorReport(
      totalActiveBriefs: 0,
      deliveredOnTimeCount: 0,
      pendingApprovalAssetsCount: 0,
      avgTurnaroundDays: 0,
      operators: [],
    );
  }
}
