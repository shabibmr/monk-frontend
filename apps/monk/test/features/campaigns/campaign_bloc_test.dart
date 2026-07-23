import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_shared/monk_shared.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/campaigns/domain/entities/campaign.dart';
import 'package:monk_web/features/campaigns/domain/repositories/campaign_repository.dart';
import 'package:monk_web/features/campaigns/presentation/bloc/campaign_detail_bloc.dart';
import 'package:monk_web/features/campaigns/presentation/bloc/campaign_form_bloc.dart';

class _MockRepo extends Mock implements CampaignRepository {}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  test('licensing UI is enabled in P2 (T2.8)', () {
    expect(isLicensingUiHidden(), isFalse);
  });

  test('mode selector allows self_serve, managed, and licensing', () {
    expect(campaignModes, containsAll(['self_serve', 'managed', 'licensing']));
  });

  test('status chips map draft/published via entity mapping', () {
    expect(campaignStatusToEntity('draft'), EntityStatus.draft);
    expect(campaignStatusToEntity('published'), EntityStatus.published);
    expect(campaignStatusToEntity('cancelled'), EntityStatus.cancelled);
  });

  test('self-serve draft publish requires deliverables', () {
    expect(
      allowedBrandTransitions(
        status: 'draft',
        mode: 'self_serve',
        deliverableCount: 0,
      ),
      equals(['cancelled']),
    );
    expect(
      allowedBrandTransitions(
        status: 'draft',
        mode: 'self_serve',
        deliverableCount: 1,
      ),
      contains('published'),
    );
  });

  blocTest<CampaignFormBloc, CampaignFormState>(
    'creates campaign with paid collab only (no licensing)',
    build: () {
      when(() => repo.create(any())).thenAnswer(
        (_) async => const Campaign(
          id: 'c1',
          brandId: 'b1',
          name: 'Spring',
          code: 'SPRING',
          status: 'draft',
          mode: 'self_serve',
        ),
      );
      return CampaignFormBloc(repo);
    },
    act: (b) => b.add(
      const CampaignFormSubmitted(
        brandId: 'b1',
        name: 'Spring',
        code: 'SPRING',
        objective: 'awareness',
        mode: 'self_serve',
      ),
    ),
    expect: () => [
      isA<CampaignFormState>()
          .having((s) => s.phase, 'phase', CampaignFormPhase.saving),
      isA<CampaignFormState>()
          .having((s) => s.phase, 'phase', CampaignFormPhase.success)
          .having((s) => s.created?.id, 'id', 'c1'),
    ],
    verify: (_) {
      final body = verify(() => repo.create(captureAny())).captured.single
          as Map<String, dynamic>;
      expect(body['permittedCollabTypes'], equals(['paid']));
      expect(body['mode'], 'self_serve');
    },
  );

  blocTest<CampaignDetailBloc, CampaignDetailState>(
    'invalid transition surfaces conflict messaging',
    build: () {
      when(() => repo.get('c1')).thenAnswer(
        (_) async => const CampaignDetail(
          campaign: Campaign(
            id: 'c1',
            brandId: 'b1',
            name: 'Spring',
            code: 'SPRING',
            status: 'draft',
            mode: 'self_serve',
            deliverableCount: 0,
          ),
          deliverables: [],
        ),
      );
      when(
        () => repo.transition(
          any(),
          to: any(named: 'to'),
          reason: any(named: 'reason'),
        ),
      ).thenThrow(
        const ConflictFailure(
          'No transition draft → published',
          errorCode: ErrorCode.invalidStateTransition,
        ),
      );
      return CampaignDetailBloc(repo);
    },
    act: (b) async {
      b.add(const CampaignDetailLoaded('c1'));
      await Future<void>.delayed(Duration.zero);
      // blocked client-side (no deliverables) before API
      b.add(const CampaignTransitionRequested('published'));
    },
    expect: () => [
      isA<CampaignDetailState>()
          .having((s) => s.phase, 'phase', CampaignDetailPhase.loading),
      isA<CampaignDetailState>()
          .having((s) => s.phase, 'phase', CampaignDetailPhase.ready),
      isA<CampaignDetailState>().having(
        (s) => s.failure,
        'failure',
        isA<ConflictFailure>(),
      ),
    ],
  );

  blocTest<CampaignDetailBloc, CampaignDetailState>(
    '409 from API maps to ConflictFailure',
    build: () {
      when(() => repo.get('c1')).thenAnswer(
        (_) async => const CampaignDetail(
          campaign: Campaign(
            id: 'c1',
            brandId: 'b1',
            name: 'Spring',
            code: 'SPRING',
            status: 'draft',
            mode: 'self_serve',
            deliverableCount: 1,
          ),
          deliverables: [
            Deliverable(
              id: 'd1',
              platform: 'instagram',
              deliverableType: 'instagram_reel',
              disclosureTags: ['#ad'],
            ),
          ],
        ),
      );
      when(
        () => repo.transition(
          'c1',
          to: 'published',
          reason: any(named: 'reason'),
        ),
      ).thenThrow(
        const ConflictFailure(
          'No transition',
          errorCode: ErrorCode.invalidStateTransition,
        ),
      );
      return CampaignDetailBloc(repo);
    },
    act: (b) async {
      b.add(const CampaignDetailLoaded('c1'));
      await Future<void>.delayed(Duration.zero);
      b.add(const CampaignTransitionRequested('published'));
    },
    expect: () => [
      isA<CampaignDetailState>()
          .having((s) => s.phase, 'phase', CampaignDetailPhase.loading),
      isA<CampaignDetailState>()
          .having((s) => s.phase, 'phase', CampaignDetailPhase.ready),
      isA<CampaignDetailState>()
          .having((s) => s.phase, 'phase', CampaignDetailPhase.acting),
      isA<CampaignDetailState>()
          .having((s) => s.phase, 'phase', CampaignDetailPhase.failure)
          .having(
            (s) => s.failure?.errorCode,
            'code',
            ErrorCode.invalidStateTransition,
          ),
    ],
  );
}
