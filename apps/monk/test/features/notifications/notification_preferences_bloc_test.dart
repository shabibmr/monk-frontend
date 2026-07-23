import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/notifications/domain/entities/notification_preferences.dart';
import 'package:monk_web/features/notifications/domain/repositories/notification_preferences_repository.dart';
import 'package:monk_web/features/notifications/presentation/bloc/notification_preferences_bloc.dart';
import 'package:monk_web/features/notifications/presentation/bloc/notification_preferences_event.dart';
import 'package:monk_web/features/notifications/presentation/bloc/notification_preferences_state.dart';

class _MockPrefsRepository extends Mock implements NotificationPreferencesRepository {}

class _FakeNotificationPreferences extends Fake implements NotificationPreferences {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeNotificationPreferences());
  });

  late _MockPrefsRepository repo;

  const prefs1 = NotificationPreferences(
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

  setUp(() {
    repo = _MockPrefsRepository();
  });

  group('NotificationPreferencesBloc', () {
    blocTest<NotificationPreferencesBloc, NotificationPreferencesState>(
      'loads preferences successfully',
      build: () {
        when(() => repo.fetchPreferences()).thenAnswer((_) async => prefs1);
        return NotificationPreferencesBloc(repo);
      },
      act: (bloc) => bloc.add(const LoadNotificationPreferences()),
      expect: () => [
        const NotificationPreferencesState(phase: NotificationPreferencesPhase.loading),
        const NotificationPreferencesState(
          phase: NotificationPreferencesPhase.success,
          preferences: prefs1,
        ),
      ],
    );

    blocTest<NotificationPreferencesBloc, NotificationPreferencesState>(
      'saves preferences successfully',
      seed: () => const NotificationPreferencesState(preferences: prefs1),
      build: () {
        when(() => repo.updatePreferences(any())).thenAnswer((_) async => prefs1.copyWith(smsOptIn: true));
        return NotificationPreferencesBloc(repo);
      },
      act: (bloc) => bloc.add(SaveNotificationPreferences(prefs1.copyWith(smsOptIn: true))),
      expect: () => [
        const NotificationPreferencesState(
          preferences: prefs1,
          isSaving: true,
        ),
        NotificationPreferencesState(
          preferences: prefs1.copyWith(smsOptIn: true),
          isSaving: false,
          saveSuccessMessage: 'Notification preferences saved successfully',
        ),
      ],
    );
  });
}
