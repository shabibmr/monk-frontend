import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import 'notification_preferences_event.dart';
import 'notification_preferences_state.dart';

class NotificationPreferencesBloc
    extends Bloc<NotificationPreferencesEvent, NotificationPreferencesState> {
  NotificationPreferencesBloc(this._repository)
      : super(const NotificationPreferencesState()) {
    on<LoadNotificationPreferences>(_onLoad);
    on<SaveNotificationPreferences>(_onSave);
  }

  final NotificationPreferencesRepository _repository;

  Future<void> _onLoad(
    LoadNotificationPreferences event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    emit(state.copyWith(phase: NotificationPreferencesPhase.loading));
    try {
      final prefs = await _repository.fetchPreferences();
      emit(
        state.copyWith(
          phase: NotificationPreferencesPhase.success,
          preferences: prefs,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          phase: NotificationPreferencesPhase.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSave(
    SaveNotificationPreferences event,
    Emitter<NotificationPreferencesState> emit,
  ) async {
    emit(state.copyWith(isSaving: true));
    try {
      final updated = await _repository.updatePreferences(event.preferences);
      emit(
        state.copyWith(
          preferences: updated,
          isSaving: false,
          saveSuccessMessage: 'Notification preferences saved successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save preferences: $e',
        ),
      );
    }
  }
}
