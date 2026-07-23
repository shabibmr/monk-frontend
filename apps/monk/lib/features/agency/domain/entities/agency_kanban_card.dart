import 'package:equatable/equatable.dart';

class AgencyKanbanCard extends Equatable {
  const AgencyKanbanCard({
    required this.id,
    required this.title,
    required this.brandName,
    required this.creatorName,
    required this.stage,
    required this.dueDate,
    required this.assetCount,
    required this.pendingApprovalsCount,
    required this.budgetMinor,
    required this.currency,
  });

  final String id;
  final String title;
  final String brandName;
  final String creatorName;
  final String stage;
  final String dueDate;
  final int assetCount;
  final int pendingApprovalsCount;
  final int budgetMinor;
  final String currency;

  AgencyKanbanCard copyWith({
    String? id,
    String? title,
    String? brandName,
    String? creatorName,
    String? stage,
    String? dueDate,
    int? assetCount,
    int? pendingApprovalsCount,
    int? budgetMinor,
    String? currency,
  }) {
    return AgencyKanbanCard(
      id: id ?? this.id,
      title: title ?? this.title,
      brandName: brandName ?? this.brandName,
      creatorName: creatorName ?? this.creatorName,
      stage: stage ?? this.stage,
      dueDate: dueDate ?? this.dueDate,
      assetCount: assetCount ?? this.assetCount,
      pendingApprovalsCount: pendingApprovalsCount ?? this.pendingApprovalsCount,
      budgetMinor: budgetMinor ?? this.budgetMinor,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        brandName,
        creatorName,
        stage,
        dueDate,
        assetCount,
        pendingApprovalsCount,
        budgetMinor,
        currency,
      ];
}
