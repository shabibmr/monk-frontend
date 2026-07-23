import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/roster.dart';
import '../../domain/repositories/manager_repository.dart';

class AccessState extends Equatable {
  const AccessState({
    this.loading = false,
    this.rows = const [],
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final List<ProfileAccessRow> rows;
  final Failure? failure;
  final String? infoMessage;

  AccessState copyWith({
    bool? loading,
    List<ProfileAccessRow>? rows,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
  }) {
    return AccessState(
      loading: loading ?? this.loading,
      rows: rows ?? this.rows,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }

  @override
  List<Object?> get props => [loading, rows, failure, infoMessage];
}

class AccessCubit extends Cubit<AccessState> {
  AccessCubit(this._repo, this.profileId) : super(const AccessState());

  final ManagerRepository _repo;
  final String profileId;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final rows = await _repo.listAccess(profileId);
      emit(state.copyWith(loading: false, rows: rows));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> invite({
    required String email,
    required List<String> permissions,
  }) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.inviteManager(
        profileId: profileId,
        email: email,
        permissions: permissions,
      );
      await load();
      emit(state.copyWith(infoMessage: 'Manager invite sent'));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> revoke(String accessId) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.revokeAccess(profileId: profileId, accessId: accessId);
      await load();
      emit(state.copyWith(infoMessage: 'Access revoked'));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }
}
