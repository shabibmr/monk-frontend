import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/briefs/domain/entities/brief.dart';
import 'package:monk_web/features/briefs/domain/repositories/brief_repository.dart';
import 'package:monk_web/features/briefs/presentation/bloc/brief_form_bloc.dart';
import 'package:monk_web/features/briefs/presentation/cubit/agency_briefs_cubit.dart';

class _MockRepo extends Mock implements BriefRepository {}

void main() {
  late _MockRepo repo;

  const brief = Brief(
    id: 'br1',
    brandId: 'b1',
    goals: 'Launch',
    status: 'submitted',
    campaignId: 'c1',
    managedFeeMode: 'none',
    agencyFeeMinor: null,
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('no invented managed fee when mode is none', () {
    expect(brief.showAgencyFee, isFalse);
    expect(
      const Brief(
        id: 'x',
        brandId: 'b',
        goals: 'g',
        status: 'submitted',
        managedFeeMode: 'pct',
        agencyFeeMinor: 100,
      ).showAgencyFee,
      isTrue,
    );
  });

  blocTest<BriefFormBloc, BriefFormState>(
    'submit brief succeeds without fee invention',
    build: () {
      when(() => repo.submit(any())).thenAnswer(
        (_) async => const SubmitBriefResult(
          brief: brief,
          campaignId: 'c1',
          managedFeeMode: 'none',
          agencyFeeMinor: null,
        ),
      );
      return BriefFormBloc(repo);
    },
    act: (b) => b.add(
      const BriefFormSubmitted(
        brandId: 'b1',
        goals: 'Launch',
        budgetMajor: '1000',
      ),
    ),
    expect: () => [
      const BriefFormState(phase: BriefFormPhase.saving),
      isA<BriefFormState>()
          .having((s) => s.phase, 'phase', BriefFormPhase.success)
          .having((s) => s.result?.managedFeeMode, 'fee', 'none')
          .having((s) => s.result?.agencyFeeMinor, 'amount', isNull),
    ],
    verify: (_) {
      final body = verify(() => repo.submit(captureAny())).captured.single
          as Map<String, dynamic>;
      expect(body['budgetMinor'], 100000);
      expect(body.containsKey('agencyFee'), isFalse);
    },
  );

  blocTest<AgencyBriefsCubit, AgencyBriefsState>(
    'convert + assign actions',
    build: () {
      when(() => repo.agencyList(status: any(named: 'status'))).thenAnswer(
        (_) async => [brief],
      );
      when(() => repo.convert('br1')).thenAnswer(
        (_) async => const SubmitBriefResult(
          brief: Brief(
            id: 'br1',
            brandId: 'b1',
            goals: 'Launch',
            status: 'converted',
            campaignId: 'c1',
            managedFeeMode: 'none',
          ),
          campaignId: 'c1',
          managedFeeMode: 'none',
        ),
      );
      when(
        () => repo.assignInfluencers(
          campaignId: any(named: 'campaignId'),
          profileIds: any(named: 'profileIds'),
        ),
      ).thenAnswer((_) async {});
      return AgencyBriefsCubit(repo);
    },
    act: (c) async {
      await c.load();
      await c.convert('br1');
      await c.assign(campaignId: 'c1', profileIds: ['p1', 'p2']);
    },
    verify: (_) {
      verify(() => repo.convert('br1')).called(1);
      verify(
        () => repo.assignInfluencers(
          campaignId: 'c1',
          profileIds: ['p1', 'p2'],
        ),
      ).called(1);
    },
  );
}
