import 'package:equatable/equatable.dart';
import 'agency_kanban_card.dart';

class AgencyKanbanColumn extends Equatable {
  const AgencyKanbanColumn({
    required this.id,
    required this.title,
    required this.cards,
    this.wipLimit,
  });

  final String id;
  final String title;
  final List<AgencyKanbanCard> cards;
  final int? wipLimit;

  AgencyKanbanColumn copyWith({
    String? id,
    String? title,
    List<AgencyKanbanCard>? cards,
    int? wipLimit,
  }) {
    return AgencyKanbanColumn(
      id: id ?? this.id,
      title: title ?? this.title,
      cards: cards ?? this.cards,
      wipLimit: wipLimit ?? this.wipLimit,
    );
  }

  @override
  List<Object?> get props => [id, title, cards, wipLimit];
}
