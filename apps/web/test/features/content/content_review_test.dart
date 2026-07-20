import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/content/domain/entities/content.dart';
import 'package:monk_web/features/content/domain/repositories/content_repository.dart';
import 'package:monk_web/features/content/presentation/cubit/content_review_cubit.dart';
import 'package:monk_web/features/content/presentation/widgets/disclosure_banner.dart';

class _MockRepo extends Mock implements ContentRepository {}

void main() {
  late _MockRepo repo;

  const failedDisc = DisclosureInfo(
    passed: false,
    requiredTags: ['#ad'],
    missingTags: ['#ad'],
    overrideRequired: true,
  );

  const version = ContentVersion(
    id: 'v1',
    submissionId: 's1',
    versionNumber: 1,
    status: 'submitted',
    caption: 'Nice product',
    disclosure: failedDisc,
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('canApproveWithDisclosure blocks empty override when failed', () {
    expect(
      canApproveWithDisclosure(disclosurePassed: false, overrideReason: null),
      isFalse,
    );
    expect(
      canApproveWithDisclosure(disclosurePassed: false, overrideReason: '  '),
      isFalse,
    );
    expect(
      canApproveWithDisclosure(
        disclosurePassed: false,
        overrideReason: 'Legal exception signed',
      ),
      isTrue,
    );
    expect(
      canApproveWithDisclosure(disclosurePassed: true, overrideReason: null),
      isTrue,
    );
  });

  blocTest<ContentReviewCubit, ContentReviewState>(
    'Approve disabled without reason when passed=false',
    build: () {
      when(() => repo.listSubmissions(any())).thenAnswer(
        (_) async => [
          const ContentSubmission(
            id: 's1',
            collaborationId: 'col1',
            campaignDeliverableId: 'd1',
            status: 'in_progress',
            versions: [version],
          ),
        ],
      );
      when(() => repo.getVersion('v1')).thenAnswer((_) async => version);
      when(() => repo.listComments('v1')).thenAnswer((_) async => []);
      return ContentReviewCubit(repo, 'col1');
    },
    act: (c) async {
      await c.load();
      await c.approve();
    },
    verify: (c) {
      expect(c.state.canApprove, isFalse);
      expect(c.state.failure, isA<ValidationFailure>());
      expect(c.state.failure?.errorCode, 'DISCLOSURE_OVERRIDE_REQUIRED');
      verifyNever(
        () => repo.review(
          versionId: any(named: 'versionId'),
          decision: any(named: 'decision'),
          comment: any(named: 'comment'),
          overrideReason: any(named: 'overrideReason'),
        ),
      );
    },
  );

  blocTest<ContentReviewCubit, ContentReviewState>(
    'Approve enabled with override reason',
    build: () {
      when(() => repo.listSubmissions(any())).thenAnswer(
        (_) async => [
          const ContentSubmission(
            id: 's1',
            collaborationId: 'col1',
            campaignDeliverableId: 'd1',
            status: 'in_progress',
            versions: [version],
          ),
        ],
      );
      when(() => repo.getVersion('v1')).thenAnswer((_) async => version);
      when(() => repo.listComments('v1')).thenAnswer((_) async => []);
      when(
        () => repo.review(
          versionId: any(named: 'versionId'),
          decision: any(named: 'decision'),
          comment: any(named: 'comment'),
          overrideReason: any(named: 'overrideReason'),
        ),
      ).thenAnswer(
        (_) async => const ContentVersion(
          id: 'v1',
          submissionId: 's1',
          versionNumber: 1,
          status: 'approved',
        ),
      );
      return ContentReviewCubit(repo, 'col1');
    },
    act: (c) async {
      await c.load();
      c.setOverrideReason('Brand legal approved exception');
      await c.approve();
    },
    verify: (c) {
      verify(
        () => repo.review(
          versionId: 'v1',
          decision: 'approve',
          comment: any(named: 'comment'),
          overrideReason: 'Brand legal approved exception',
        ),
      ).called(1);
    },
  );

  testWidgets('banner variants passed vs failed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              DisclosureBanner(
                disclosure: DisclosureInfo(
                  passed: true,
                  requiredTags: ['#ad'],
                ),
              ),
              DisclosureBanner(
                disclosure: DisclosureInfo(
                  passed: false,
                  requiredTags: ['#ad'],
                  missingTags: ['#ad'],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Required disclosures present'), findsOneWidget);
    expect(find.text('Disclosure check failed'), findsOneWidget);
    expect(find.textContaining('Missing: #ad'), findsOneWidget);
  });
}
