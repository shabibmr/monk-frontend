import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/disputes/domain/entities/data_erasure_request.dart';
import 'package:monk_web/features/disputes/domain/entities/dispute.dart';
import 'package:monk_web/features/disputes/domain/repositories/dispute_repository.dart';
import 'package:monk_web/features/disputes/presentation/bloc/disputes_bloc.dart';

class _MockDisputeRepo extends Mock implements DisputeRepository {}

void main() {
  late _MockDisputeRepo repo;

  const dispute = Dispute(
    id: 'disp_1',
    collaborationId: 'col_1',
    raisedBy: 'brand_1',
    reason: 'non_delivery',
    description: 'Deliverables not uploaded by deadline',
    status: 'open',
    paymentId: 'pay_123',
    evidenceUrls: ['https://cdn.example.com/proof.png'],
  );

  const resolvedDispute = Dispute(
    id: 'disp_1',
    collaborationId: 'col_1',
    raisedBy: 'brand_1',
    reason: 'non_delivery',
    description: 'Deliverables not uploaded by deadline',
    status: 'resolved_refund',
    paymentId: 'pay_123',
    evidenceUrls: ['https://cdn.example.com/proof.png'],
    adminNotes: 'Full refund processed to brand',
  );

  const erasureRequest = DataErasureRequest(
    id: 'er_1',
    userId: 'user_1',
    status: 'pending',
    reason: 'Closing account and revoking consent',
  );

  setUp(() {
    repo = _MockDisputeRepo();
  });

  group('DisputesBloc - Disputes', () {
    blocTest<DisputesBloc, DisputesState>(
      'loads disputes successfully',
      build: () {
        when(() => repo.getDisputes(collaborationId: any(named: 'collaborationId')))
            .thenAnswer((_) async => [dispute]);
        return DisputesBloc(repo);
      },
      act: (b) => b.add(const LoadDisputesRequested(collaborationId: 'col_1')),
      expect: () => [
        const DisputesState(loading: true),
        const DisputesState(loading: false, disputes: [dispute]),
      ],
    );

    blocTest<DisputesBloc, DisputesState>(
      'loads admin disputes list',
      build: () {
        when(() => repo.getAdminDisputes()).thenAnswer((_) async => [dispute]);
        return DisputesBloc(repo);
      },
      act: (b) => b.add(const LoadAdminDisputesRequested()),
      expect: () => [
        const DisputesState(loading: true),
        const DisputesState(loading: false, adminDisputes: [dispute]),
      ],
    );

    blocTest<DisputesBloc, DisputesState>(
      'files dispute successfully with payment freeze message',
      build: () {
        when(
          () => repo.fileDispute(
            collaborationId: any(named: 'collaborationId'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
            paymentId: any(named: 'paymentId'),
            evidenceUrls: any(named: 'evidenceUrls'),
          ),
        ).thenAnswer((_) async => dispute);
        return DisputesBloc(repo);
      },
      act: (b) => b.add(const FileDisputeSubmitted(
        collaborationId: 'col_1',
        reason: 'non_delivery',
        description: 'Deliverables not uploaded by deadline',
        paymentId: 'pay_123',
        evidenceUrls: ['https://cdn.example.com/proof.png'],
      )),
      expect: () => [
        const DisputesState(submitting: true),
        const DisputesState(
          submitting: false,
          activeDispute: dispute,
          disputes: [dispute],
          infoMessage:
              'Dispute filed successfully. Escrow payment frozen pending admin resolution.',
        ),
      ],
    );

    blocTest<DisputesBloc, DisputesState>(
      'resolves dispute successfully by admin',
      seed: () => const DisputesState(adminDisputes: [dispute]),
      build: () {
        when(
          () => repo.resolveDispute(
            disputeId: any(named: 'disputeId'),
            resolution: any(named: 'resolution'),
            notes: any(named: 'notes'),
          ),
        ).thenAnswer((_) async => resolvedDispute);
        return DisputesBloc(repo);
      },
      act: (b) => b.add(const ResolveDisputeSubmitted(
        disputeId: 'disp_1',
        resolution: 'resolved_refund',
        notes: 'Full refund processed to brand',
      )),
      expect: () => [
        const DisputesState(submitting: true, adminDisputes: [dispute]),
        const DisputesState(
          submitting: false,
          activeDispute: resolvedDispute,
          adminDisputes: [resolvedDispute],
          infoMessage: 'Dispute resolved successfully',
        ),
      ],
    );

    blocTest<DisputesBloc, DisputesState>(
      'handles failure when filing dispute',
      build: () {
        when(
          () => repo.fileDispute(
            collaborationId: any(named: 'collaborationId'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
            paymentId: any(named: 'paymentId'),
            evidenceUrls: any(named: 'evidenceUrls'),
          ),
        ).thenThrow(const ServerFailure('Failed to file dispute'));
        return DisputesBloc(repo);
      },
      act: (b) => b.add(const FileDisputeSubmitted(
        collaborationId: 'col_1',
        reason: 'other',
        description: 'Invalid',
      )),
      expect: () => [
        const DisputesState(submitting: true),
        const DisputesState(
          submitting: false,
          failure: ServerFailure('Failed to file dispute'),
        ),
      ],
    );
  });

  group('DisputesBloc - Data Erasure', () {
    blocTest<DisputesBloc, DisputesState>(
      'loads data erasure requests',
      build: () {
        when(() => repo.getDataErasureRequests())
            .thenAnswer((_) async => [erasureRequest]);
        return DisputesBloc(repo);
      },
      act: (b) => b.add(const LoadDataErasureRequestsRequested()),
      expect: () => [
        const DisputesState(loading: true),
        const DisputesState(loading: false, erasureRequests: [erasureRequest]),
      ],
    );

    blocTest<DisputesBloc, DisputesState>(
      'submits data erasure request successfully',
      build: () {
        when(() => repo.submitDataErasureRequest(any()))
            .thenAnswer((_) async => erasureRequest);
        return DisputesBloc(repo);
      },
      act: (b) => b.add(
          const SubmitDataErasureRequested('Closing account and revoking consent')),
      expect: () => [
        const DisputesState(submitting: true),
        const DisputesState(
          submitting: false,
          erasureRequests: [erasureRequest],
          infoMessage: 'Data erasure request submitted successfully',
        ),
      ],
    );
  });
}
