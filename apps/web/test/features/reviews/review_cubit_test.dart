import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/reviews/domain/entities/review.dart';
import 'package:monk_web/features/reviews/domain/repositories/review_repository.dart';
import 'package:monk_web/features/reviews/presentation/cubit/review_cubit.dart';

class _MockRepo extends Mock implements ReviewRepository {}

void main() {
  late _MockRepo repo;

  const review = Review(
    id: 'r1',
    collaborationId: 'col1',
    reviewerSide: 'brand',
    visible: true,
    rating: 5,
    body: 'Great collab',
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('isValidStarRating accepts 1–5 only', () {
    expect(isValidStarRating(0), isFalse);
    expect(isValidStarRating(1), isTrue);
    expect(isValidStarRating(5), isTrue);
    expect(isValidStarRating(6), isFalse);
  });

  blocTest<ReviewCubit, ReviewState>(
    'load lists collaboration reviews',
    build: () {
      when(() => repo.listForCollaboration('col1'))
          .thenAnswer((_) async => [review]);
      return ReviewCubit(repo, 'col1');
    },
    act: (c) => c.load(),
    expect: () => [
      isA<ReviewState>().having((s) => s.loading, 'loading', true),
      isA<ReviewState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.reviews.length, 'count', 1)
          .having((s) => s.reviews.first.rating, 'rating', 5),
    ],
  );

  blocTest<ReviewCubit, ReviewState>(
    'submit without rating → ValidationFailure INVALID_RATING',
    build: () => ReviewCubit(repo, 'col1'),
    act: (c) => c.submit(body: 'no stars'),
    expect: () => [
      isA<ReviewState>()
          .having((s) => s.failure, 'failure', isA<ValidationFailure>())
          .having((s) => s.failure?.errorCode, 'code', 'INVALID_RATING'),
    ],
    verify: (_) {
      verifyNever(
        () => repo.create(
          collaborationId: any(named: 'collaborationId'),
          rating: any(named: 'rating'),
          body: any(named: 'body'),
        ),
      );
    },
  );

  blocTest<ReviewCubit, ReviewState>(
    'mutual review happy path: setRating → submit → reload list',
    build: () {
      when(
        () => repo.create(
          collaborationId: any(named: 'collaborationId'),
          rating: any(named: 'rating'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => review);
      when(() => repo.listForCollaboration('col1'))
          .thenAnswer((_) async => [review]);
      return ReviewCubit(repo, 'col1');
    },
    act: (c) async {
      c.setRating(5);
      await c.submit(body: 'Great collab');
    },
    verify: (c) {
      expect(c.state.submitted?.id, 'r1');
      expect(c.state.reviews.length, 1);
      expect(c.state.infoMessage, 'Review submitted');
      expect(c.state.submitting, isFalse);
      verify(
        () => repo.create(
          collaborationId: 'col1',
          rating: 5,
          body: 'Great collab',
        ),
      ).called(1);
    },
  );

  blocTest<ReviewCubit, ReviewState>(
    'create failure maps to Failure on state',
    build: () {
      when(
        () => repo.create(
          collaborationId: any(named: 'collaborationId'),
          rating: any(named: 'rating'),
          body: any(named: 'body'),
        ),
      ).thenThrow(
        const ConflictFailure(
          'Already reviewed',
          errorCode: 'REVIEW_DUPLICATE',
        ),
      );
      return ReviewCubit(repo, 'col1');
    },
    act: (c) async {
      c.setRating(4);
      await c.submit();
    },
    verify: (c) {
      expect(c.state.failure, isA<ConflictFailure>());
      expect(c.state.failure?.errorCode, 'REVIEW_DUPLICATE');
      expect(c.state.submitting, isFalse);
    },
  );
}
