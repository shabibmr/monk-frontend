import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewState extends Equatable {
  const ReviewState({
    this.loading = false,
    this.submitting = false,
    this.reviews = const [],
    this.selectedRating = 0,
    this.submitted,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool submitting;
  final List<Review> reviews;
  final int selectedRating;
  final Review? submitted;
  final Failure? failure;
  final String? infoMessage;

  bool get canSubmit => isValidStarRating(selectedRating) && !submitting;

  ReviewState copyWith({
    bool? loading,
    bool? submitting,
    List<Review>? reviews,
    int? selectedRating,
    Review? submitted,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return ReviewState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      reviews: reviews ?? this.reviews,
      selectedRating: selectedRating ?? this.selectedRating,
      submitted: submitted ?? this.submitted,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props =>
      [loading, submitting, reviews, selectedRating, submitted, failure, infoMessage];
}

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit(this._repo, this.collaborationId)
      : super(const ReviewState());

  final ReviewRepository _repo;
  final String collaborationId;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final list = await _repo.listForCollaboration(collaborationId);
      emit(state.copyWith(loading: false, reviews: list));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  void setRating(int rating) {
    emit(state.copyWith(selectedRating: rating, clearFailure: true));
  }

  Future<void> submit({String? body}) async {
    if (!state.canSubmit) {
      emit(
        state.copyWith(
          failure: const ValidationFailure(
            'Choose a rating from 1 to 5 stars',
            errorCode: 'INVALID_RATING',
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(submitting: true, clearFailure: true, clearInfo: true));
    try {
      final r = await _repo.create(
        collaborationId: collaborationId,
        rating: state.selectedRating,
        body: body,
      );
      final list = await _repo.listForCollaboration(collaborationId);
      emit(
        state.copyWith(
          submitting: false,
          submitted: r,
          reviews: list,
          infoMessage: 'Review submitted',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }
}
