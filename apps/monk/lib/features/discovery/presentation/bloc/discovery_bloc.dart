import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/repositories/discovery_repository.dart';

sealed class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();
  @override
  List<Object?> get props => [];
}

class DiscoveryStarted extends DiscoveryEvent {
  const DiscoveryStarted();
}

class DiscoveryQueryChanged extends DiscoveryEvent {
  const DiscoveryQueryChanged(this.q);
  final String q;
  @override
  List<Object?> get props => [q];
}

class DiscoveryFiltersChanged extends DiscoveryEvent {
  const DiscoveryFiltersChanged(this.filters);
  final DiscoveryFilters filters;
  @override
  List<Object?> get props => [filters];
}

class DiscoveryRefreshed extends DiscoveryEvent {
  const DiscoveryRefreshed();
}

class DiscoveryLoadMore extends DiscoveryEvent {
  const DiscoveryLoadMore();
}

enum DiscoveryPhase { initial, loading, ready, loadingMore, failure }

class DiscoveryState extends Equatable {
  const DiscoveryState({
    this.phase = DiscoveryPhase.initial,
    this.filters = const DiscoveryFilters(),
    this.items = const [],
    this.nextCursor,
    this.failure,
  });

  final DiscoveryPhase phase;
  final DiscoveryFilters filters;
  final List<DiscoveryInfluencer> items;
  final String? nextCursor;
  final Failure? failure;

  bool get hasMore => nextCursor != null;

  DiscoveryState copyWith({
    DiscoveryPhase? phase,
    DiscoveryFilters? filters,
    List<DiscoveryInfluencer>? items,
    String? nextCursor,
    Failure? failure,
    bool clearFailure = false,
    bool clearCursor = false,
  }) {
    return DiscoveryState(
      phase: phase ?? this.phase,
      filters: filters ?? this.filters,
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [phase, filters, items, nextCursor, failure];
}

/// Debounce duration for free-text query (tests can inject shorter).
const kDiscoveryDebounce = Duration(milliseconds: 350);

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  DiscoveryBloc(
    this._repo, {
    this.debounce = kDiscoveryDebounce,
  }) : super(const DiscoveryState()) {
    on<DiscoveryStarted>(_onStart);
    on<DiscoveryQueryChanged>(_onQuery);
    on<DiscoveryFiltersChanged>(_onFilters);
    on<DiscoveryRefreshed>(_onRefresh);
    on<DiscoveryLoadMore>(_onMore);
  }

  final DiscoveryRepository _repo;
  final Duration debounce;
  int _queryGen = 0;

  Future<void> _search(
    Emitter<DiscoveryState> emit, {
    required DiscoveryFilters filters,
    bool append = false,
    String? cursor,
  }) async {
    emit(
      state.copyWith(
        phase: append ? DiscoveryPhase.loadingMore : DiscoveryPhase.loading,
        filters: filters,
        clearFailure: true,
        items: append ? state.items : const [],
        clearCursor: !append,
      ),
    );
    try {
      final page = await _repo.search(filters, cursor: cursor);
      emit(
        state.copyWith(
          phase: DiscoveryPhase.ready,
          items: append ? [...state.items, ...page.items] : page.items,
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: DiscoveryPhase.failure, failure: f));
    }
  }

  Future<void> _onStart(
    DiscoveryStarted event,
    Emitter<DiscoveryState> emit,
  ) async {
    await _search(emit, filters: state.filters);
  }

  Future<void> _onQuery(
    DiscoveryQueryChanged event,
    Emitter<DiscoveryState> emit,
  ) async {
    final gen = ++_queryGen;
    // Optimistic filter update for UI
    emit(state.copyWith(filters: state.filters.copyWith(q: event.q)));
    await Future<void>.delayed(debounce);
    if (gen != _queryGen || emit.isDone) return;
    await _search(emit, filters: state.filters.copyWith(q: event.q));
  }

  Future<void> _onFilters(
    DiscoveryFiltersChanged event,
    Emitter<DiscoveryState> emit,
  ) async {
    await _search(emit, filters: event.filters);
  }

  Future<void> _onRefresh(
    DiscoveryRefreshed event,
    Emitter<DiscoveryState> emit,
  ) async {
    await _search(emit, filters: state.filters);
  }

  Future<void> _onMore(
    DiscoveryLoadMore event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (!state.hasMore || state.phase == DiscoveryPhase.loadingMore) return;
    await _search(
      emit,
      filters: state.filters,
      append: true,
      cursor: state.nextCursor,
    );
  }
}
