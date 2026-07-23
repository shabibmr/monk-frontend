import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_preferences.dart';

abstract class NotificationPreferencesEvent extends Equatable {
  const NotificationPreferencesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationPreferences extends NotificationPreferencesEvent {
  const LoadNotificationPreferences();
}

class SaveNotificationPreferences extends NotificationPreferencesEvent {
  const SaveNotificationPreferences(this.preferences);
  final NotificationPreferences preferences;

  @override
  List<Object?> get props => [preferences];
}
