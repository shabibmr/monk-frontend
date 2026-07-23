import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/kyc/domain/entities/kyc.dart';
import 'package:monk_web/features/kyc/domain/repositories/kyc_repository.dart';
import 'package:monk_web/features/kyc/presentation/bloc/verification_bloc.dart';

class _MockKycRepo extends Mock implements KycRepository {}

void main() {
  late _MockKycRepo repo;

  const pending = KycRecord(
    id: 'k1',
    status: 'pending',
    influencerProfileId: 'p1',
  );

  setUp(() {
    repo = _MockKycRepo();
  });

  blocTest<VerificationBloc, VerificationState>(
    'loads queue',
    build: () {
      when(() => repo.adminQueue()).thenAnswer(
        (_) async => (
          influencers: const <QueueInfluencer>[],
          kyc: [pending],
        ),
      );
      when(() => repo.rejectionTemplates())
          .thenAnswer((_) async => const <RejectionTemplate>[]);
      return VerificationBloc(repo);
    },
    act: (b) => b.add(const VerificationQueueLoaded()),
    expect: () => [
      isA<VerificationState>()
          .having((s) => s.phase, 'phase', VerificationPhase.loading),
      isA<VerificationState>()
          .having((s) => s.phase, 'phase', VerificationPhase.ready)
          .having((s) => s.kyc.length, 'kyc', 1),
    ],
  );

  blocTest<VerificationBloc, VerificationState>(
    'approve refreshes queue',
    build: () {
      when(() => repo.adminApprove('k1')).thenAnswer(
        (_) async => const KycRecord(id: 'k1', status: 'approved'),
      );
      when(() => repo.adminQueue()).thenAnswer(
        (_) async => (
          influencers: const <QueueInfluencer>[],
          kyc: const <KycRecord>[],
        ),
      );
      when(() => repo.rejectionTemplates())
          .thenAnswer((_) async => const <RejectionTemplate>[]);
      return VerificationBloc(repo);
    },
    seed: () => const VerificationState(
      phase: VerificationPhase.ready,
      kyc: [pending],
      selectedKycId: 'k1',
    ),
    act: (b) => b.add(const VerificationApproved('k1')),
    expect: () => [
      isA<VerificationState>()
          .having((s) => s.phase, 'phase', VerificationPhase.acting),
      isA<VerificationState>()
          .having((s) => s.phase, 'phase', VerificationPhase.ready)
          .having((s) => s.kyc, 'kyc', isEmpty)
          .having((s) => s.infoMessage, 'msg', 'KYC approved'),
    ],
  );

  blocTest<VerificationBloc, VerificationState>(
    'reject refreshes queue',
    build: () {
      when(
        () => repo.adminReject(
          'k1',
          templateKey: any(named: 'templateKey'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer(
        (_) async => const KycRecord(id: 'k1', status: 'rejected'),
      );
      when(() => repo.adminQueue()).thenAnswer(
        (_) async => (
          influencers: const <QueueInfluencer>[],
          kyc: const <KycRecord>[],
        ),
      );
      return VerificationBloc(repo);
    },
    seed: () => const VerificationState(
      phase: VerificationPhase.ready,
      kyc: [pending],
    ),
    act: (b) => b.add(
      const VerificationRejected('k1', reason: 'Incomplete docs'),
    ),
    expect: () => [
      isA<VerificationState>()
          .having((s) => s.phase, 'phase', VerificationPhase.acting),
      isA<VerificationState>()
          .having((s) => s.phase, 'phase', VerificationPhase.ready)
          .having((s) => s.infoMessage, 'msg', 'KYC rejected'),
    ],
  );
}
