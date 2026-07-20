import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/marketplace.dart';
import '../../domain/repositories/marketplace_repository.dart';

class BrandApplicationsState extends Equatable {
  const BrandApplicationsState({
    this.loading = false,
    this.items = const [],
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final List<Application> items;
  final Failure? failure;
  final String? infoMessage;

  BrandApplicationsState copyWith({
    bool? loading,
    List<Application>? items,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return BrandApplicationsState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [loading, items, failure, infoMessage];
}

class BrandApplicationsCubit extends Cubit<BrandApplicationsState> {
  BrandApplicationsCubit(this._repo, this.brandId)
      : super(const BrandApplicationsState());

  final MarketplaceRepository _repo;
  final String brandId;

  Future<void> load({String? campaignId, String? status}) async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final items = await _repo.brandInbox(
        brandId,
        campaignId: campaignId,
        status: status,
      );
      emit(state.copyWith(loading: false, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> shortlist(String id) async {
    emit(state.copyWith(clearFailure: true, clearInfo: true));
    try {
      final updated = await _repo.shortlist(id);
      final items = state.items
          .map((a) => a.id == id ? updated : a)
          .toList(growable: false);
      emit(
        state.copyWith(
          items: items,
          infoMessage: 'Application shortlisted',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  Future<void> reject(String id, {required String reason}) async {
    emit(state.copyWith(clearFailure: true, clearInfo: true));
    try {
      final updated = await _repo.reject(id, reason: reason);
      final items = state.items
          .map((a) => a.id == id ? updated : a)
          .toList(growable: false);
      emit(
        state.copyWith(
          items: items,
          infoMessage: 'Application rejected',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  Future<void> invite({
    required String campaignId,
    required String profileId,
    String? message,
  }) async {
    emit(state.copyWith(clearFailure: true, clearInfo: true));
    try {
      await _repo.invite(
        campaignId: campaignId,
        profileId: profileId,
        message: message,
      );
      await load();
      emit(state.copyWith(infoMessage: 'Invite sent'));
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }
}
