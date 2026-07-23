import 'package:equatable/equatable.dart';

class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    required this.fcmWebPushEnabled,
    required this.smsOptIn,
    required this.smsPhoneNumber,
    required this.emailEnabled,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.campaignUpdates,
    required this.paymentAlerts,
    required this.chatMessagesAlert,
  });

  final bool fcmWebPushEnabled;
  final bool smsOptIn;
  final String smsPhoneNumber;
  final bool emailEnabled;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool campaignUpdates;
  final bool paymentAlerts;
  final bool chatMessagesAlert;

  NotificationPreferences copyWith({
    bool? fcmWebPushEnabled,
    bool? smsOptIn,
    String? smsPhoneNumber,
    bool? emailEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? campaignUpdates,
    bool? paymentAlerts,
    bool? chatMessagesAlert,
  }) {
    return NotificationPreferences(
      fcmWebPushEnabled: fcmWebPushEnabled ?? this.fcmWebPushEnabled,
      smsOptIn: smsOptIn ?? this.smsOptIn,
      smsPhoneNumber: smsPhoneNumber ?? this.smsPhoneNumber,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      campaignUpdates: campaignUpdates ?? this.campaignUpdates,
      paymentAlerts: paymentAlerts ?? this.paymentAlerts,
      chatMessagesAlert: chatMessagesAlert ?? this.chatMessagesAlert,
    );
  }

  @override
  List<Object?> get props => [
        fcmWebPushEnabled,
        smsOptIn,
        smsPhoneNumber,
        emailEnabled,
        quietHoursEnabled,
        quietHoursStart,
        quietHoursEnd,
        campaignUpdates,
        paymentAlerts,
        chatMessagesAlert,
      ];
}
