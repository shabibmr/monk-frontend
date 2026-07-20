import 'package:api_client/api_client.dart';

import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';

class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository {
  NotificationPreferencesRepositoryImpl(this._client);

  final MonkApiClient _client;

  @override
  Future<NotificationPreferences> fetchPreferences() async {
    try {
      final response = await _client.dio.get(ApiPaths.notificationPreferences);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _mapPreferences(data);
      }
      return _defaultPreferences();
    } catch (e) {
      return _defaultPreferences();
    }
  }

  @override
  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final response = await _client.dio.put(
        ApiPaths.notificationPreferences,
        data: {
          'fcmWebPushEnabled': preferences.fcmWebPushEnabled,
          'smsOptIn': preferences.smsOptIn,
          'smsPhoneNumber': preferences.smsPhoneNumber,
          'emailEnabled': preferences.emailEnabled,
          'quietHoursEnabled': preferences.quietHoursEnabled,
          'quietHoursStart': preferences.quietHoursStart,
          'quietHoursEnd': preferences.quietHoursEnd,
          'campaignUpdates': preferences.campaignUpdates,
          'paymentAlerts': preferences.paymentAlerts,
          'chatMessagesAlert': preferences.chatMessagesAlert,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _mapPreferences(data);
      }
      return preferences;
    } catch (e) {
      return preferences;
    }
  }

  NotificationPreferences _mapPreferences(Map<String, dynamic> json) {
    return NotificationPreferences(
      fcmWebPushEnabled: json['fcmWebPushEnabled'] as bool? ?? false,
      smsOptIn: json['smsOptIn'] as bool? ?? false,
      smsPhoneNumber: json['smsPhoneNumber'] as String? ?? '',
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] as String? ?? '08:00',
      campaignUpdates: json['campaignUpdates'] as bool? ?? true,
      paymentAlerts: json['paymentAlerts'] as bool? ?? true,
      chatMessagesAlert: json['chatMessagesAlert'] as bool? ?? true,
    );
  }

  NotificationPreferences _defaultPreferences() {
    return const NotificationPreferences(
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
  }
}
