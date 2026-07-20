import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/repositories/discovery_repository.dart';

class ShortlistState extends Equatable {
  const ShortlistState({
    this.loading = false,
    this.lists = const [],
    this.selectedId,
    this.items = const [],
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final List<Shortlist> lists;
  final String? selectedId;
  final List<ShortlistItem> items;
  final Failure? failure;
  final String? infoMessage;

  ShortlistState copyWith({
    bool? loading,
    List<Shortlist>? lists,
    String? selectedId,
    List<ShortlistItem>? items,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearSelected = false,
  }) {
    return ShortlistState(
      loading: loading ?? this.loading,
      lists: lists ?? this.lists,
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
      items: items ?? this.items,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }

  @override
  List<Object?> get props =>
      [loading, lists, selectedId, items, failure, infoMessage];
}

class ShortlistCubit extends Cubit<ShortlistState> {
  ShortlistCubit(this._repo, this.brandId) : super(const ShortlistState());

  final DiscoveryRepository _repo;
  final String brandId;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final lists = await _repo.listShortlists(brandId);
      emit(state.copyWith(loading: false, lists: lists));
      if (lists.isNotEmpty && state.selectedId == null) {
        await select(lists.first.id);
      }
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> create(String name) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.createShortlist(brandId, name);
      await load();
      emit(state.copyWith(infoMessage: 'Shortlist created'));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> select(String id) async {
    emit(state.copyWith(loading: true, selectedId: id, clearFailure: true));
    try {
      final items = await _repo.listItems(brandId, id);
      emit(state.copyWith(loading: false, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> addInfluencer(String influencerProfileId) async {
    final id = state.selectedId ??
        (state.lists.isNotEmpty ? state.lists.first.id : null);
    if (id == null) {
      emit(
        state.copyWith(
          failure: const ValidationFailure('Create a shortlist first'),
        ),
      );
      return;
    }
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.addItem(
        brandId: brandId,
        shortlistId: id,
        influencerProfileId: influencerProfileId,
      );
      await select(id);
      emit(state.copyWith(infoMessage: 'Added to shortlist'));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> removeItem(String itemId) async {
    final id = state.selectedId;
    if (id == null) return;
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.removeItem(
        brandId: brandId,
        shortlistId: id,
        itemId: itemId,
      );
      await select(id);
      emit(state.copyWith(infoMessage: 'Removed from shortlist'));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> deleteList(String id) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.deleteShortlist(brandId, id);
      emit(state.copyWith(clearSelected: true, items: const []));
      await load();
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }
}
