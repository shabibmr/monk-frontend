import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/marketplace.dart';
import '../../domain/repositories/marketplace_repository.dart';

class CreatorApplicationsState extends Equatable {
  const CreatorApplicationsState({
    this.loading = false,
    this.items = const [],
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final List<Application> items;
  final Failure? failure;
  final String? infoMessage;

  CreatorApplicationsState copyWith({
    bool? loading,
    List<Application>? items,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return CreatorApplicationsState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [loading, items, failure, infoMessage];
}

class CreatorApplicationsCubit extends Cubit<CreatorApplicationsState> {
  CreatorApplicationsCubit(this._repo, this.profileId)
      : super(const CreatorApplicationsState());

  final MarketplaceRepository _repo;
  final String profileId;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final items = await _repo.listMine(profileId);
      emit(state.copyWith(loading: false, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> withdraw(String id) async {
    emit(state.copyWith(clearFailure: true, clearInfo: true));
    try {
      await _repo.withdraw(id);
      await load();
      emit(state.copyWith(infoMessage: 'Application withdrawn'));
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  Future<void> acceptInvite(String id) async {
    emit(state.copyWith(clearFailure: true, clearInfo: true));
    try {
      await _repo.acceptInvite(id);
      await load();
      emit(state.copyWith(infoMessage: 'Invite accepted'));
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  Future<void> declineInvite(String id) async {
    emit(state.copyWith(clearFailure: true, clearInfo: true));
    try {
      await _repo.declineInvite(id);
      await load();
      emit(state.copyWith(infoMessage: 'Invite declined'));
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }
}
