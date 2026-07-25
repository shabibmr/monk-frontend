import '../../../features/notifications/domain/entities/notification_preferences.dart';
import '../../../features/notifications/domain/repositories/notification_preferences_repository.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [NotificationPreferencesRepository].
///
/// Store key: `notification_prefs` → `List<NotificationPreferences>` (first row is active).
class MockNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  MockNotificationPreferencesRepository(this.store);

  final MockSeedStore store;

  static const _key = 'notification_prefs';

  static const _defaults = NotificationPreferences(
    fcmWebPushEnabled: true,
    smsOptIn: false,
    smsPhoneNumber: '',
    emailEnabled: true,
    quietHoursEnabled: false,
    quietHoursStart: '22:00',
    quietHoursEnd: '08:00',
    campaignUpdates: true,
    paymentAlerts: true,
    chatMessagesAlert: true,
  );

  void _ensureSeeded() {
    if (store.list<NotificationPreferences>(_key).isNotEmpty) return;
    store.putAll(_key, [_defaults]);
  }

  @override
  Future<NotificationPreferences> fetchPreferences() async {
    await store.delay();
    _ensureSeeded();
    return store.list<NotificationPreferences>(_key).first;
  }

  @override
  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    await store.delay();
    _ensureSeeded();
    store.putAll(_key, [preferences]);
    return preferences;
  }
}
