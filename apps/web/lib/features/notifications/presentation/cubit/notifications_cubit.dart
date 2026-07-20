import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.read,
  });

  final String id;
  final String title;
  final bool read;

  @override
  List<Object?> get props => [id, title, read];
}

class NotificationsState extends Equatable {
  const NotificationsState({this.items = const []});

  final List<NotificationItem> items;

  int get unreadCount => items.where((e) => !e.read).length;

  @override
  List<Object?> get props => [items];
}

/// Stub until backend notifications list is fully wired (T0.4+).
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  void setStubUnread(int count) {
    emit(
      NotificationsState(
        items: List.generate(
          count,
          (i) => NotificationItem(
            id: 'stub-$i',
            title: 'Notification ${i + 1}',
            read: false,
          ),
        ),
      ),
    );
  }

  void markAllRead() {
    emit(
      NotificationsState(
        items: state.items
            .map(
              (e) => NotificationItem(
                id: e.id,
                title: e.title,
                read: true,
              ),
            )
            .toList(),
      ),
    );
  }
}
