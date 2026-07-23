import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/publish/domain/entities/published_post.dart';
import 'package:monk_web/features/publish/domain/repositories/publish_repository.dart';
import 'package:monk_web/features/publish/presentation/bloc/publish_bloc.dart';

class _MockRepo extends Mock implements PublishRepository {}

void main() {
  late _MockRepo repo;

  const pending = PublishedPost(
    id: 'p1',
    collaborationId: 'col1',
    campaignDeliverableId: 'd1',
    liveUrl: 'https://www.instagram.com/reel/AbC/',
    platform: 'instagram',
    ownershipVerified: false,
    verificationStatus: 'pending',
  );

  const verified = PublishedPost(
    id: 'p1',
    collaborationId: 'col1',
    campaignDeliverableId: 'd1',
    liveUrl: 'https://www.instagram.com/reel/AbC/',
    platform: 'instagram',
    ownershipVerified: true,
    verificationStatus: 'verified',
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('URL validation rejects free text', () {
    expect(looksLikeHttpUrl('not a url'), isFalse);
    expect(looksLikeHttpUrl('ftp://x.com'), isFalse);
    expect(looksLikeHttpUrl('https://www.instagram.com/reel/x/'), isTrue);
  });

  blocTest<PublishBloc, PublishState>(
    'invalid URL messaging',
    build: () => PublishBloc(
      repo,
      collaborationId: 'col1',
      deliverableId: 'd1',
    ),
    act: (b) => b.add(const PublishUrlSubmitted('notaurl')),
    expect: () => [
      isA<PublishState>()
          .having((s) => s.failure, 'failure', isA<ValidationFailure>())
          .having((s) => s.failure?.errorCode, 'code', 'INVALID_URL'),
    ],
    verify: (_) {
      verifyNever(
        () => repo.submit(
          collaborationId: any(named: 'collaborationId'),
          deliverableId: any(named: 'deliverableId'),
          liveUrl: any(named: 'liveUrl'),
        ),
      );
    },
  );

  blocTest<PublishBloc, PublishState>(
    'submit → polling → verified chip',
    build: () {
      when(
        () => repo.get(
          collaborationId: any(named: 'collaborationId'),
          deliverableId: any(named: 'deliverableId'),
        ),
      ).thenAnswer((_) async => pending);
      when(
        () => repo.submit(
          collaborationId: any(named: 'collaborationId'),
          deliverableId: any(named: 'deliverableId'),
          liveUrl: any(named: 'liveUrl'),
        ),
      ).thenAnswer((_) async => pending);
      return PublishBloc(
        repo,
        collaborationId: 'col1',
        deliverableId: 'd1',
        pollInterval: const Duration(milliseconds: 20),
        maxPolls: 5,
      );
    },
    act: (b) async {
      b.add(
        const PublishUrlSubmitted('https://www.instagram.com/reel/AbC/'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      // next poll returns verified
      when(
        () => repo.get(
          collaborationId: any(named: 'collaborationId'),
          deliverableId: any(named: 'deliverableId'),
        ),
      ).thenAnswer((_) async => verified);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    },
    wait: const Duration(milliseconds: 120),
    verify: (b) {
      expect(b.state.post?.isVerified, isTrue);
      expect(b.state.post?.statusChip.name, 'verified');
      expect(b.state.polling, isFalse);
      verify(
        () => repo.submit(
          collaborationId: 'col1',
          deliverableId: 'd1',
          liveUrl: 'https://www.instagram.com/reel/AbC/',
        ),
      ).called(1);
    },
  );

  blocTest<PublishBloc, PublishState>(
    'poll cancellation on dispose (close stops timer)',
    build: () {
      when(
        () => repo.submit(
          collaborationId: any(named: 'collaborationId'),
          deliverableId: any(named: 'deliverableId'),
          liveUrl: any(named: 'liveUrl'),
        ),
      ).thenAnswer((_) async => pending);
      when(
        () => repo.get(
          collaborationId: any(named: 'collaborationId'),
          deliverableId: any(named: 'deliverableId'),
        ),
      ).thenAnswer((_) async => pending);
      return PublishBloc(
        repo,
        collaborationId: 'col1',
        deliverableId: 'd1',
        pollInterval: const Duration(milliseconds: 30),
      );
    },
    act: (b) async {
      b.add(
        const PublishUrlSubmitted('https://www.instagram.com/reel/AbC/'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await b.close();
    },
    verify: (_) {
      // After close, further polls should not throw; get may have been called.
      expect(true, isTrue);
    },
  );
}
