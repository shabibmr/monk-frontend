import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendations_repository.dart';

enum RecommendationsStatus { initial, loading, loaded, empty, error }

abstract class RecommendationsEvent extends Equatable {
  const RecommendationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecommendationsRequested extends RecommendationsEvent {
  const FetchRecommendationsRequested({
    this.campaignId,
    this.type,
    this.category,
  });

  final String? campaignId;
  final String? type;
  final String? category;

  @override
  List<Object?> get props => [campaignId, type, category];
}

class DismissRecommendationRequested extends RecommendationsEvent {
  const DismissRecommendationRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class RecommendationsState extends Equatable {
  const RecommendationsState({
    this.status = RecommendationsStatus.initial,
    this.recommendations = const [],
    this.failure,
  });

  final RecommendationsStatus status;
  final List<Recommendation> recommendations;
  final Failure? failure;

  RecommendationsState copyWith({
    RecommendationsStatus? status,
    List<Recommendation>? recommendations,
    Failure? failure,
  }) {
    return RecommendationsState(
      status: status ?? this.status,
      recommendations: recommendations ?? this.recommendations,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, recommendations, failure];
}

class RecommendationsBloc
    extends Bloc<RecommendationsEvent, RecommendationsState> {
  RecommendationsBloc(this._repository) : super(const RecommendationsState()) {
    on<FetchRecommendationsRequested>(_onFetchRecommendationsRequested);
    on<DismissRecommendationRequested>(_onDismissRecommendationRequested);
  }

  final RecommendationsRepository _repository;

  Future<void> _onFetchRecommendationsRequested(
    FetchRecommendationsRequested event,
    Emitter<RecommendationsState> emit,
  ) async {
    emit(state.copyWith(status: RecommendationsStatus.loading));
    try {
      final items = await _repository.getRecommendations(
        campaignId: event.campaignId,
        type: event.type,
        category: event.category,
      );
      if (items.isEmpty) {
        emit(
          state.copyWith(
            status: RecommendationsStatus.empty,
            recommendations: const [],
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: RecommendationsStatus.loaded,
            recommendations: items,
          ),
        );
      }
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: RecommendationsStatus.error,
          failure: f,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RecommendationsStatus.error,
          failure: ServerFailure(e.toString()),
        ),
      );
    }
  }

  void _onDismissRecommendationRequested(
    DismissRecommendationRequested event,
    Emitter<RecommendationsState> emit,
  ) {
    final updated =
        state.recommendations.where((r) => r.id != event.id).toList();
    if (updated.isEmpty) {
      emit(
        state.copyWith(
          status: RecommendationsStatus.empty,
          recommendations: const [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: RecommendationsStatus.loaded,
          recommendations: updated,
        ),
      );
    }
  }
}
