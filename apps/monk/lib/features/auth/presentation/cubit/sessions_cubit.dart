import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class SessionsState extends Equatable {
  const SessionsState({
    this.loading = false,
    this.sessions = const [],
    this.failure,
  });

  final bool loading;
  final List<DeviceSession> sessions;
  final Failure? failure;

  SessionsState copyWith({
    bool? loading,
    List<DeviceSession>? sessions,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return SessionsState(
      loading: loading ?? this.loading,
      sessions: sessions ?? this.sessions,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [loading, sessions, failure];
}

class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit(this._repo) : super(const SessionsState());

  final AuthRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final sessions = await _repo.listSessions();
      emit(state.copyWith(loading: false, sessions: sessions));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> revoke(String id) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.revokeSession(id);
      await load();
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }
}
