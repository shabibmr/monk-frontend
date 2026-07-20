import 'package:equatable/equatable.dart';

abstract class AgencyConsoleEvent extends Equatable {
  const AgencyConsoleEvent();

  @override
  List<Object?> get props => [];
}

class LoadAgencyConsole extends AgencyConsoleEvent {
  const LoadAgencyConsole();
}

class ChangeTabEvent extends AgencyConsoleEvent {
  const ChangeTabEvent(this.tabIndex);
  final int tabIndex; // 0: Kanban, 1: Operator Reports

  @override
  List<Object?> get props => [tabIndex];
}

class MoveKanbanCardEvent extends AgencyConsoleEvent {
  const MoveKanbanCardEvent({
    required this.cardId,
    required this.targetColumnId,
  });

  final String cardId;
  final String targetColumnId;

  @override
  List<Object?> get props => [cardId, targetColumnId];
}

class SelectCardForAssetsEvent extends AgencyConsoleEvent {
  const SelectCardForAssetsEvent(this.cardId);
  final String cardId;

  @override
  List<Object?> get props => [cardId];
}

class CloseAssetDrawerEvent extends AgencyConsoleEvent {
  const CloseAssetDrawerEvent();
}

class AttachAssetEvent extends AgencyConsoleEvent {
  const AttachAssetEvent({
    required this.cardId,
    required this.title,
    required this.fileUrl,
    required this.fileType,
  });

  final String cardId;
  final String title;
  final String fileUrl;
  final String fileType;

  @override
  List<Object?> get props => [cardId, title, fileUrl, fileType];
}

class UpdateAssetStatusEvent extends AgencyConsoleEvent {
  const UpdateAssetStatusEvent({
    required this.assetId,
    required this.status,
    this.notes,
  });

  final String assetId;
  final String status;
  final String? notes;

  @override
  List<Object?> get props => [assetId, status, notes];
}
