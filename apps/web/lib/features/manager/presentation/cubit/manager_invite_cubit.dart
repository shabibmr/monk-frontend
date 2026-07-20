import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/manager_repository.dart';

class ManagerInviteState extends Equatable {
  const ManagerInviteState({
    this.loading = false,
    this.success = false,
    this.failure,
  });

  final bool loading;
  final bool success;
  final Failure? failure;

  @override
  List<Object?> get props => [loading, success, failure];
}

class ManagerInviteCubit extends Cubit<ManagerInviteState> {
  ManagerInviteCubit(this._repo) : super(const ManagerInviteState());
  final ManagerRepository _repo;

  Future<void> accept(String token) async {
    emit(const ManagerInviteState(loading: true));
    try {
      await _repo.acceptInvite(token);
      emit(const ManagerInviteState(success: true));
    } on Failure catch (f) {
      emit(ManagerInviteState(failure: f));
    }
  }
}
