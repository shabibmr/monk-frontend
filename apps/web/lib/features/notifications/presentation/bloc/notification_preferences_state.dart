import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_preferences.dart';

enum NotificationPreferencesPhase { initial, loading, success, failure }

class NotificationPreferencesState extends Equatable {
  const NotificationPreferencesState({
    this.phase = NotificationPreferencesPhase.initial,
    this.preferences,
    this.isSaving = false,
    this.saveSuccessMessage,
    this.errorMessage,
  });

  final NotificationPreferencesPhase phase;
  final NotificationPreferences? preferences;
  final bool isSaving;
  final String? saveSuccessMessage;
  final String? errorMessage;

  NotificationPreferencesState copyWith({
    NotificationPreferencesPhase? phase,
    NotificationPreferences? preferences,
    bool? isSaving,
    String? saveSuccessMessage,
    String? errorMessage,
  }) {
    return NotificationPreferencesState(
      phase: phase ?? this.phase,
      preferences: preferences ?? this.preferences,
      isSaving: isSaving ?? this.isSaving,
      saveSuccessMessage: saveSuccessMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        preferences,
        isSaving,
        saveSuccessMessage,
        errorMessage,
      ];
}
