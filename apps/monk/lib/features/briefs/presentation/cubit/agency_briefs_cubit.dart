import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/brief.dart';
import '../../domain/repositories/brief_repository.dart';

class AgencyBriefsState extends Equatable {
  const AgencyBriefsState({
    this.loading = false,
    this.items = const [],
    this.selected,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final List<Brief> items;
  final Brief? selected;
  final Failure? failure;
  final String? infoMessage;

  AgencyBriefsState copyWith({
    bool? loading,
    List<Brief>? items,
    Brief? selected,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearSelected = false,
  }) {
    return AgencyBriefsState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      selected: clearSelected ? null : (selected ?? this.selected),
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }

  @override
  List<Object?> get props =>
      [loading, items, selected, failure, infoMessage];
}

class AgencyBriefsCubit extends Cubit<AgencyBriefsState> {
  AgencyBriefsCubit(this._repo) : super(const AgencyBriefsState());
  final BriefRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final items = await _repo.agencyList();
      emit(state.copyWith(loading: false, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  void select(Brief brief) {
    emit(state.copyWith(selected: brief));
  }

  Future<void> triage(String id, {String? notes}) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.triage(id, notes: notes);
      await load();
      emit(state.copyWith(infoMessage: 'Brief triaged'));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<SubmitBriefResult?> convert(String id) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final result = await _repo.convert(id);
      // Assert no invented fee
      if (result.managedFeeMode != 'none' && result.agencyFeeMinor == null) {
        // still OK — only show if API provides amount
      }
      await load();
      emit(
        state.copyWith(
          infoMessage: 'Brief converted · fee mode ${result.managedFeeMode}',
          selected: result.brief,
        ),
      );
      return result;
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
      return null;
    }
  }

  Future<void> assign({
    required String campaignId,
    required List<String> profileIds,
  }) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.assignInfluencers(
        campaignId: campaignId,
        profileIds: profileIds,
      );
      emit(
        state.copyWith(
          loading: false,
          infoMessage: 'Assigned ${profileIds.length} influencer(s)',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }
}
