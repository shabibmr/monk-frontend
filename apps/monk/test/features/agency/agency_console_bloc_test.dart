import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/agency/domain/entities/agency_asset.dart';
import 'package:monk_web/features/agency/domain/entities/agency_kanban_card.dart';
import 'package:monk_web/features/agency/domain/entities/agency_kanban_column.dart';
import 'package:monk_web/features/agency/domain/entities/agency_operator_report.dart';
import 'package:monk_web/features/agency/domain/repositories/agency_repository.dart';
import 'package:monk_web/features/agency/presentation/bloc/agency_console_bloc.dart';
import 'package:monk_web/features/agency/presentation/bloc/agency_console_event.dart';
import 'package:monk_web/features/agency/presentation/bloc/agency_console_state.dart';

class _MockAgencyRepository extends Mock implements AgencyRepository {}

void main() {
  late _MockAgencyRepository repo;

  const card1 = AgencyKanbanCard(
    id: 'card-1',
    title: 'Summer Skincare Campaign',
    brandName: 'Glow Beauty',
    creatorName: 'Alex Rivera',
    stage: 'unassigned',
    dueDate: '2026-08-01',
    assetCount: 1,
    pendingApprovalsCount: 1,
    budgetMinor: 250000,
    currency: 'USD',
  );

  const col1 = AgencyKanbanColumn(
    id: 'unassigned',
    title: 'Unassigned Briefs',
    cards: [card1],
  );

  const asset1 = AgencyAsset(
    id: 'asset-1',
    cardId: 'card-1',
    title: 'Reel Draft v1.mp4',
    fileUrl: 'https://example.com/reel.mp4',
    fileType: 'video/mp4',
    status: 'pending',
    uploadedBy: 'Alex Rivera',
    uploadedAt: '2026-07-20',
  );

  const report1 = AgencyOperatorReport(
    totalActiveBriefs: 10,
    deliveredOnTimeCount: 9,
    pendingApprovalAssetsCount: 2,
    avgTurnaroundDays: 2.0,
    operators: [],
  );

  setUp(() {
    repo = _MockAgencyRepository();
  });

  group('AgencyConsoleBloc', () {
    blocTest<AgencyConsoleBloc, AgencyConsoleState>(
      'emits [loading, success] when LoadAgencyConsole is added',
      build: () {
        when(() => repo.fetchKanbanBoard()).thenAnswer((_) async => [col1]);
        when(() => repo.fetchOperatorReport()).thenAnswer((_) async => report1);
        return AgencyConsoleBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadAgencyConsole()),
      expect: () => [
        const AgencyConsoleState(phase: AgencyConsolePhase.loading),
        const AgencyConsoleState(
          phase: AgencyConsolePhase.success,
          columns: [col1],
          operatorReport: report1,
        ),
      ],
      verify: (_) {
        verify(() => repo.fetchKanbanBoard()).called(1);
        verify(() => repo.fetchOperatorReport()).called(1);
      },
    );

    blocTest<AgencyConsoleBloc, AgencyConsoleState>(
      'moves kanban card and re-fetches board',
      build: () {
        when(() => repo.moveKanbanCard(
              cardId: 'card-1',
              targetColumnId: 'in_review',
            )).thenAnswer(
          (_) async => card1.copyWith(stage: 'in_review'),
        );
        when(() => repo.fetchKanbanBoard()).thenAnswer(
          (_) async => [
            col1.copyWith(
              cards: [card1.copyWith(stage: 'in_review')],
            ),
          ],
        );
        return AgencyConsoleBloc(repo);
      },
      act: (bloc) => bloc.add(
        const MoveKanbanCardEvent(
          cardId: 'card-1',
          targetColumnId: 'in_review',
        ),
      ),
      expect: () => [
        AgencyConsoleState(
          columns: [
            col1.copyWith(
              cards: [card1.copyWith(stage: 'in_review')],
            ),
          ],
        ),
      ],
      verify: (_) {
        verify(
          () => repo.moveKanbanCard(
            cardId: 'card-1',
            targetColumnId: 'in_review',
          ),
        ).called(1);
      },
    );

    blocTest<AgencyConsoleBloc, AgencyConsoleState>(
      'fetches assets when card is selected',
      build: () {
        when(() => repo.fetchAssets(cardId: 'card-1')).thenAnswer(
          (_) async => [asset1],
        );
        return AgencyConsoleBloc(repo);
      },
      act: (bloc) => bloc.add(const SelectCardForAssetsEvent('card-1')),
      expect: () => [
        const AgencyConsoleState(
          selectedCardId: 'card-1',
          isAssetDrawerOpen: true,
          isAssetActionLoading: true,
        ),
        const AgencyConsoleState(
          selectedCardId: 'card-1',
          isAssetDrawerOpen: true,
          isAssetActionLoading: false,
          selectedCardAssets: [asset1],
        ),
      ],
    );

    blocTest<AgencyConsoleBloc, AgencyConsoleState>(
      'attaches asset successfully',
      seed: () => const AgencyConsoleState(
        selectedCardId: 'card-1',
        selectedCardAssets: [asset1],
      ),
      build: () {
        when(() => repo.attachAsset(
              cardId: 'card-1',
              title: 'New Asset',
              fileUrl: 'https://example.com/new.png',
              fileType: 'image/png',
            )).thenAnswer(
          (_) async => const AgencyAsset(
            id: 'asset-2',
            cardId: 'card-1',
            title: 'New Asset',
            fileUrl: 'https://example.com/new.png',
            fileType: 'image/png',
            status: 'pending',
            uploadedBy: 'Me',
            uploadedAt: 'Now',
          ),
        );
        return AgencyConsoleBloc(repo);
      },
      act: (bloc) => bloc.add(
        const AttachAssetEvent(
          cardId: 'card-1',
          title: 'New Asset',
          fileUrl: 'https://example.com/new.png',
          fileType: 'image/png',
        ),
      ),
      expect: () => [
        const AgencyConsoleState(
          selectedCardId: 'card-1',
          selectedCardAssets: [asset1],
          isAssetActionLoading: true,
        ),
        const AgencyConsoleState(
          selectedCardId: 'card-1',
          isAssetActionLoading: false,
          selectedCardAssets: [
            asset1,
            AgencyAsset(
              id: 'asset-2',
              cardId: 'card-1',
              title: 'New Asset',
              fileUrl: 'https://example.com/new.png',
              fileType: 'image/png',
              status: 'pending',
              uploadedBy: 'Me',
              uploadedAt: 'Now',
            ),
          ],
        ),
      ],
    );
  });
}
