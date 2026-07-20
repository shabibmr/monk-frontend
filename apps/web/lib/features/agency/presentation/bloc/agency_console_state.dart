import 'package:equatable/equatable.dart';
import '../../domain/entities/agency_asset.dart';
import '../../domain/entities/agency_kanban_column.dart';
import '../../domain/entities/agency_operator_report.dart';

enum AgencyConsolePhase { initial, loading, success, failure }

class AgencyConsoleState extends Equatable {
  const AgencyConsoleState({
    this.phase = AgencyConsolePhase.initial,
    this.columns = const [],
    this.activeTab = 0,
    this.selectedCardId,
    this.selectedCardAssets = const [],
    this.isAssetDrawerOpen = false,
    this.isAssetActionLoading = false,
    this.operatorReport,
    this.errorMessage,
  });

  final AgencyConsolePhase phase;
  final List<AgencyKanbanColumn> columns;
  final int activeTab;
  final String? selectedCardId;
  final List<AgencyAsset> selectedCardAssets;
  final bool isAssetDrawerOpen;
  final bool isAssetActionLoading;
  final AgencyOperatorReport? operatorReport;
  final String? errorMessage;

  AgencyConsoleState copyWith({
    AgencyConsolePhase? phase,
    List<AgencyKanbanColumn>? columns,
    int? activeTab,
    String? selectedCardId,
    List<AgencyAsset>? selectedCardAssets,
    bool? isAssetDrawerOpen,
    bool? isAssetActionLoading,
    AgencyOperatorReport? operatorReport,
    String? errorMessage,
  }) {
    return AgencyConsoleState(
      phase: phase ?? this.phase,
      columns: columns ?? this.columns,
      activeTab: activeTab ?? this.activeTab,
      selectedCardId: selectedCardId ?? this.selectedCardId,
      selectedCardAssets: selectedCardAssets ?? this.selectedCardAssets,
      isAssetDrawerOpen: isAssetDrawerOpen ?? this.isAssetDrawerOpen,
      isAssetActionLoading: isAssetActionLoading ?? this.isAssetActionLoading,
      operatorReport: operatorReport ?? this.operatorReport,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        columns,
        activeTab,
        selectedCardId,
        selectedCardAssets,
        isAssetDrawerOpen,
        isAssetActionLoading,
        operatorReport,
        errorMessage,
      ];
}
