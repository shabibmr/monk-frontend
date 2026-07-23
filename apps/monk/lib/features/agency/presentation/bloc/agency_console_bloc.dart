import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/agency_repository.dart';
import 'agency_console_event.dart';
import 'agency_console_state.dart';

class AgencyConsoleBloc extends Bloc<AgencyConsoleEvent, AgencyConsoleState> {
  AgencyConsoleBloc(this._repository) : super(const AgencyConsoleState()) {
    on<LoadAgencyConsole>(_onLoad);
    on<ChangeTabEvent>(_onChangeTab);
    on<MoveKanbanCardEvent>(_onMoveKanbanCard);
    on<SelectCardForAssetsEvent>(_onSelectCardForAssets);
    on<CloseAssetDrawerEvent>(_onCloseAssetDrawer);
    on<AttachAssetEvent>(_onAttachAsset);
    on<UpdateAssetStatusEvent>(_onUpdateAssetStatus);
  }

  final AgencyRepository _repository;

  Future<void> _onLoad(
    LoadAgencyConsole event,
    Emitter<AgencyConsoleState> emit,
  ) async {
    emit(state.copyWith(phase: AgencyConsolePhase.loading));
    try {
      final columns = await _repository.fetchKanbanBoard();
      final report = await _repository.fetchOperatorReport();
      emit(
        state.copyWith(
          phase: AgencyConsolePhase.success,
          columns: columns,
          operatorReport: report,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          phase: AgencyConsolePhase.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onChangeTab(
    ChangeTabEvent event,
    Emitter<AgencyConsoleState> emit,
  ) {
    emit(state.copyWith(activeTab: event.tabIndex));
  }

  Future<void> _onMoveKanbanCard(
    MoveKanbanCardEvent event,
    Emitter<AgencyConsoleState> emit,
  ) async {
    try {
      await _repository.moveKanbanCard(
        cardId: event.cardId,
        targetColumnId: event.targetColumnId,
      );

      // Re-fetch or locally update board
      final updatedColumns = await _repository.fetchKanbanBoard();
      emit(state.copyWith(columns: updatedColumns));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to move card: $e'));
    }
  }

  Future<void> _onSelectCardForAssets(
    SelectCardForAssetsEvent event,
    Emitter<AgencyConsoleState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCardId: event.cardId,
        isAssetDrawerOpen: true,
        isAssetActionLoading: true,
      ),
    );
    try {
      final assets = await _repository.fetchAssets(cardId: event.cardId);
      emit(
        state.copyWith(
          selectedCardAssets: assets,
          isAssetActionLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isAssetActionLoading: false,
          errorMessage: 'Failed to load assets: $e',
        ),
      );
    }
  }

  void _onCloseAssetDrawer(
    CloseAssetDrawerEvent event,
    Emitter<AgencyConsoleState> emit,
  ) {
    emit(
      state.copyWith(
        isAssetDrawerOpen: false,
        selectedCardId: null,
        selectedCardAssets: const [],
      ),
    );
  }

  Future<void> _onAttachAsset(
    AttachAssetEvent event,
    Emitter<AgencyConsoleState> emit,
  ) async {
    emit(state.copyWith(isAssetActionLoading: true));
    try {
      final newAsset = await _repository.attachAsset(
        cardId: event.cardId,
        title: event.title,
        fileUrl: event.fileUrl,
        fileType: event.fileType,
      );

      final updatedList = [...state.selectedCardAssets, newAsset];
      emit(
        state.copyWith(
          selectedCardAssets: updatedList,
          isAssetActionLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isAssetActionLoading: false,
          errorMessage: 'Failed to attach asset: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateAssetStatus(
    UpdateAssetStatusEvent event,
    Emitter<AgencyConsoleState> emit,
  ) async {
    emit(state.copyWith(isAssetActionLoading: true));
    try {
      final updatedAsset = await _repository.updateAssetStatus(
        assetId: event.assetId,
        status: event.status,
        notes: event.notes,
      );

      final updatedList = state.selectedCardAssets.map((a) {
        return a.id == event.assetId ? updatedAsset : a;
      }).toList();

      emit(
        state.copyWith(
          selectedCardAssets: updatedList,
          isAssetActionLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isAssetActionLoading: false,
          errorMessage: 'Failed to update asset status: $e',
        ),
      );
    }
  }
}
