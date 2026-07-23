import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/contracts/domain/entities/contract.dart';
import 'package:monk_web/features/contracts/domain/repositories/contract_repository.dart';
import 'package:monk_web/features/contracts/presentation/bloc/contract_bloc.dart';

class _MockRepo extends Mock implements ContractRepository {}

void main() {
  late _MockRepo repo;

  const rights = UsageRights(
    organicReuse: true,
    paidAmplification: false,
    durationDays: 90,
    territory: 'IN',
    channels: ['instagram', 'youtube'],
    exclusivityCategory: 'beauty',
    exclusivityDays: 30,
  );

  const generated = Contract(
    id: 'ct1',
    collaborationId: 'col1',
    status: 'generated',
    contentHash: 'hash-abc',
    templateKey: 'contract_lite',
    templateVersion: '1',
    usageRights: rights,
  );

  const accepted = Contract(
    id: 'ct1',
    collaborationId: 'col1',
    status: 'accepted',
    contentHash: 'hash-abc',
    templateKey: 'contract_lite',
    templateVersion: '1',
    usageRights: rights,
    bothPartiesAccepted: true,
    acceptances: [
      ContractAcceptance(
        party: 'brand',
        acceptedByUserId: 'u1',
        contentHash: 'hash-abc',
        acceptedAt: '2026-07-16T12:00:00.000Z',
      ),
    ],
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('usage-rights fields render from API entity', () {
    expect(generated.usageRights?.organicReuse, isTrue);
    expect(generated.usageRights?.paidAmplification, isFalse);
    expect(generated.usageRights?.durationDays, 90);
    expect(generated.usageRights?.territory, 'IN');
    expect(generated.usageRights?.channels, ['instagram', 'youtube']);
  });

  blocTest<ContractBloc, ContractState>(
    'accept disabled without checkbox',
    build: () {
      when(() => repo.get('col1')).thenAnswer((_) async => generated);
      return ContractBloc(repo);
    },
    act: (b) async {
      b.add(const ContractLoaded('col1'));
      await Future<void>.delayed(Duration.zero);
      b.add(const ContractAcceptSubmitted());
    },
    wait: const Duration(milliseconds: 50),
    verify: (b) {
      expect(b.state.canAccept, isFalse);
      expect(b.state.failure, isA<ValidationFailure>());
      verifyNever(
        () => repo.accept(
          collaborationId: any(named: 'collaborationId'),
          contentHash: any(named: 'contentHash'),
        ),
      );
    },
  );

  blocTest<ContractBloc, ContractState>(
    'accept success stores receipt UI data',
    build: () {
      when(() => repo.get('col1')).thenAnswer((_) async => generated);
      when(
        () => repo.accept(
          collaborationId: any(named: 'collaborationId'),
          contentHash: any(named: 'contentHash'),
        ),
      ).thenAnswer((_) async => accepted);
      return ContractBloc(repo);
    },
    act: (b) async {
      b.add(const ContractLoaded('col1'));
      await Future<void>.delayed(Duration.zero);
      b.add(const ContractAgreeToggled(true));
      b.add(const ContractAcceptSubmitted());
    },
    wait: const Duration(milliseconds: 50),
    verify: (b) {
      expect(b.state.showReceipt, isTrue);
      expect(b.state.contract?.acceptances.single.contentHash, 'hash-abc');
      expect(b.state.contract?.acceptances.single.acceptedAt, isNotNull);
      expect(b.state.contract?.isReadOnly, isTrue);
      verify(
        () => repo.accept(
          collaborationId: 'col1',
          contentHash: 'hash-abc',
        ),
      ).called(1);
    },
  );
}
