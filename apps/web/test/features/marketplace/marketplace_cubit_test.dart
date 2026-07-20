import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/marketplace/domain/entities/marketplace.dart';
import 'package:monk_web/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:monk_web/features/marketplace/presentation/cubit/brand_applications_cubit.dart';
import 'package:monk_web/features/marketplace/presentation/cubit/marketplace_cubit.dart';
import 'package:monk_web/features/marketplace/presentation/cubit/marketplace_detail_cubit.dart';

class _MockRepo extends Mock implements MarketplaceRepository {}

void main() {
  late _MockRepo repo;

  const campaign = MarketplaceCampaign(
    id: 'c1',
    name: 'Summer launch',
    code: 'SUM',
    status: 'applications_open',
    mode: 'self_serve',
    objective: 'awareness',
    currency: 'INR',
    budgetTotalMinor: 100000,
    permittedCollabTypes: ['paid', 'barter', 'licensing'],
    brand: MarketplaceBrand(id: 'b1', companyName: 'Acme'),
  );

  const submitted = Application(
    id: 'a1',
    campaignId: 'c1',
    influencerProfileId: 'p1',
    origin: 'applied',
    status: 'submitted',
    pitch: 'Hello',
    proposedCollabType: 'paid',
  );

  const shortlisted = Application(
    id: 'a1',
    campaignId: 'c1',
    influencerProfileId: 'p1',
    origin: 'applied',
    status: 'shortlisted',
    pitch: 'Hello',
    proposedCollabType: 'paid',
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('empty marketplace state when no campaigns', () async {
    when(
      () => repo.browse(
        platform: any(named: 'platform'),
        objective: any(named: 'objective'),
        collabType: any(named: 'collabType'),
        cursor: any(named: 'cursor'),
      ),
    ).thenAnswer((_) async => (items: <MarketplaceCampaign>[], nextCursor: null));

    final cubit = MarketplaceCubit(repo);
    await cubit.load();
    expect(cubit.state.isEmpty, isTrue);
    expect(cubit.state.items, isEmpty);
    await cubit.close();
  });

  test('licensing not offered in apply collab options', () {
    expect(campaign.applyCollabOptions, ['paid', 'barter']);
    expect(campaign.applyCollabOptions.contains('licensing'), isFalse);
  });

  blocTest<MarketplaceDetailCubit, MarketplaceDetailState>(
    'apply success',
    build: () {
      when(() => repo.getCampaign('c1')).thenAnswer((_) async => campaign);
      when(
        () => repo.apply(
          campaignId: any(named: 'campaignId'),
          profileId: any(named: 'profileId'),
          proposedCollabType: any(named: 'proposedCollabType'),
          pitch: any(named: 'pitch'),
          proposedPrices: any(named: 'proposedPrices'),
        ),
      ).thenAnswer((_) async => submitted);
      return MarketplaceDetailCubit(repo, 'c1');
    },
    act: (c) async {
      await c.load();
      await c.apply(
        profileId: 'p1',
        proposedCollabType: 'paid',
        pitch: 'Hello',
      );
    },
    expect: () => [
      isA<MarketplaceDetailState>().having((s) => s.loading, 'loading', true),
      isA<MarketplaceDetailState>()
          .having((s) => s.campaign?.id, 'campaign', 'c1')
          .having((s) => s.loading, 'loading', false),
      isA<MarketplaceDetailState>().having((s) => s.applying, 'applying', true),
      isA<MarketplaceDetailState>()
          .having((s) => s.application?.status, 'status', 'submitted')
          .having((s) => s.infoMessage, 'info', 'Application submitted'),
    ],
  );

  blocTest<MarketplaceDetailCubit, MarketplaceDetailState>(
    'apply failure surfaces ForbiddenFailure',
    build: () {
      when(() => repo.getCampaign('c1')).thenAnswer((_) async => campaign);
      when(
        () => repo.apply(
          campaignId: any(named: 'campaignId'),
          profileId: any(named: 'profileId'),
          proposedCollabType: any(named: 'proposedCollabType'),
          pitch: any(named: 'pitch'),
          proposedPrices: any(named: 'proposedPrices'),
        ),
      ).thenThrow(
        const ForbiddenFailure(
          'Influencer profile must be approved',
          errorCode: 'NOT_MARKETPLACE_VISIBLE',
        ),
      );
      return MarketplaceDetailCubit(repo, 'c1');
    },
    act: (c) async {
      await c.load();
      await c.apply(profileId: 'p1', proposedCollabType: 'paid');
    },
    verify: (c) {
      expect(c.state.failure, isA<ForbiddenFailure>());
      expect(c.state.application, isNull);
    },
  );

  blocTest<BrandApplicationsCubit, BrandApplicationsState>(
    'brand shortlist then reject reflects on list',
    build: () {
      when(
        () => repo.brandInbox(
          any(),
          campaignId: any(named: 'campaignId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => [submitted]);
      when(() => repo.shortlist('a1')).thenAnswer((_) async => shortlisted);
      when(
        () => repo.reject('a1', reason: any(named: 'reason')),
      ).thenAnswer(
        (_) async => const Application(
          id: 'a1',
          campaignId: 'c1',
          influencerProfileId: 'p1',
          origin: 'applied',
          status: 'rejected',
          rejectionReason: 'Not a fit',
        ),
      );
      return BrandApplicationsCubit(repo, 'b1');
    },
    act: (c) async {
      await c.load();
      await c.shortlist('a1');
      await c.reject('a1', reason: 'Not a fit');
    },
    verify: (c) {
      expect(c.state.items.single.status, 'rejected');
      expect(c.state.items.single.rejectionReason, 'Not a fit');
      verify(() => repo.shortlist('a1')).called(1);
      verify(() => repo.reject('a1', reason: 'Not a fit')).called(1);
    },
  );
}
