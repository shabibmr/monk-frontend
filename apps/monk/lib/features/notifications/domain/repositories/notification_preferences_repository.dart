import '../entities/notification_preferences.dart';

abstract class NotificationPreferencesRepository {
  Future<NotificationPreferences> fetchPreferences();
  Future<NotificationPreferences> updatePreferences(NotificationPreferences preferences);
}
