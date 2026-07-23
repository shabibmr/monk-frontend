import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/marketplace.dart';
import '../../domain/repositories/marketplace_repository.dart';

class MarketplaceState extends Equatable {
  const MarketplaceState({
    this.loading = false,
    this.items = const [],
    this.nextCursor,
    this.failure,
    this.platformFilter,
    this.collabFilter,
  });

  final bool loading;
  final List<MarketplaceCampaign> items;
  final String? nextCursor;
  final Failure? failure;
  final String? platformFilter;
  final String? collabFilter;

  bool get isEmpty => !loading && items.isEmpty && failure == null;

  MarketplaceState copyWith({
    bool? loading,
    List<MarketplaceCampaign>? items,
    String? nextCursor,
    Failure? failure,
    String? platformFilter,
    String? collabFilter,
    bool clearFailure = false,
    bool clearCursor = false,
  }) {
    return MarketplaceState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      failure: clearFailure ? null : (failure ?? this.failure),
      platformFilter: platformFilter ?? this.platformFilter,
      collabFilter: collabFilter ?? this.collabFilter,
    );
  }

  @override
  List<Object?> get props =>
      [loading, items, nextCursor, failure, platformFilter, collabFilter];
}

class MarketplaceCubit extends Cubit<MarketplaceState> {
  MarketplaceCubit(this._repo) : super(const MarketplaceState());

  final MarketplaceRepository _repo;

  Future<void> load({bool refresh = true}) async {
    emit(
      state.copyWith(
        loading: true,
        clearFailure: true,
        items: refresh ? const [] : state.items,
        clearCursor: refresh,
      ),
    );
    try {
      final page = await _repo.browse(
        platform: state.platformFilter,
        collabType: state.collabFilter,
        cursor: refresh ? null : state.nextCursor,
      );
      emit(
        state.copyWith(
          loading: false,
          items: refresh ? page.items : [...state.items, ...page.items],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  void setPlatformFilter(String? platform) {
    emit(
      MarketplaceState(
        platformFilter: platform,
        collabFilter: state.collabFilter,
      ),
    );
    load();
  }

  void setCollabFilter(String? collab) {
    emit(
      MarketplaceState(
        platformFilter: state.platformFilter,
        collabFilter: collab,
      ),
    );
    load();
  }

  Future<void> loadMore() async {
    if (state.loading || state.nextCursor == null) return;
    await load(refresh: false);
  }
}
