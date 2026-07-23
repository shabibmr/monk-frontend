import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../domain/entities/roster.dart';
import '../../domain/repositories/manager_repository.dart';

class RosterState extends Equatable {
  const RosterState({
    this.loading = false,
    this.entries = const [],
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final List<RosterEntry> entries;
  final Failure? failure;
  final String? infoMessage;

  RosterState copyWith({
    bool? loading,
    List<RosterEntry>? entries,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
  }) {
    return RosterState(
      loading: loading ?? this.loading,
      entries: entries ?? this.entries,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }

  @override
  List<Object?> get props => [loading, entries, failure, infoMessage];
}

class RosterCubit extends Cubit<RosterState> {
  RosterCubit({
    required ManagerRepository repository,
    required SessionCubit sessionCubit,
  })  : _repo = repository,
        _session = sessionCubit,
        super(const RosterState());

  final ManagerRepository _repo;
  final SessionCubit _session;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final entries = await _repo.getRoster();
      emit(state.copyWith(loading: false, entries: entries));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> selectProfile(RosterEntry entry) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final ctx = await _repo.switchContext(entry.profileId);
      _session.setActiveProfile(
        profileId: ctx.profileId,
        isManagerContext: true,
        displayName: entry.displayName,
        permissions: ctx.permissions,
      );
      emit(
        state.copyWith(
          loading: false,
          infoMessage: 'Now managing ${entry.label}',
        ),
      );
    } on Failure catch (f) {
      if (f is ForbiddenFailure) {
        _session.setActiveProfile(
          profileId: null,
          isManagerContext: false,
        );
      }
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  void exitContext() {
    _session.setActiveProfile(profileId: null, isManagerContext: false);
    emit(state.copyWith(infoMessage: 'Exited manager context'));
  }
}
