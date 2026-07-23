import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/contracts/domain/entities/contract_amendment.dart';
import 'package:monk_web/features/contracts/domain/entities/contract_template.dart';
import 'package:monk_web/features/contracts/domain/repositories/contract_repository.dart';
import 'package:monk_web/features/contracts/presentation/bloc/contracts_v2_bloc.dart';

class _MockContractRepo extends Mock implements ContractRepository {}

void main() {
  late _MockContractRepo repo;

  const template = ContractTemplate(
    id: 'tmpl_1',
    key: 'barter_standard',
    name: 'Barter Standard Agreement',
    body: 'Standard barter agreement terms for {{creator}}',
    parameters: ['creator', 'brand'],
    version: '1.0',
    isActive: true,
  );

  const amendment = ContractAmendment(
    id: 'amd_1',
    contractId: 'ct_1',
    collaborationId: 'col_1',
    title: 'Extend usage rights',
    reason: 'Additional ad campaign required',
    amendedTerms: 'Extended duration by 30 days',
    status: 'pending',
    requestedBy: 'brand_user',
  );

  const resolvedAmendment = ContractAmendment(
    id: 'amd_1',
    contractId: 'ct_1',
    collaborationId: 'col_1',
    title: 'Extend usage rights',
    reason: 'Additional ad campaign required',
    amendedTerms: 'Extended duration by 30 days',
    status: 'approved',
    requestedBy: 'brand_user',
  );

  setUp(() {
    repo = _MockContractRepo();
  });

  group('ContractsV2Bloc - Templates', () {
    blocTest<ContractsV2Bloc, ContractsV2State>(
      'loads contract templates successfully',
      build: () {
        when(() => repo.getTemplates())
            .thenAnswer((_) async => [template]);
        return ContractsV2Bloc(repo);
      },
      act: (bloc) => bloc.add(const LoadContractTemplatesRequested()),
      expect: () => [
        const ContractsV2State(loading: true),
        const ContractsV2State(loading: false, templates: [template]),
      ],
      verify: (_) {
        verify(() => repo.getTemplates()).called(1);
      },
    );

    blocTest<ContractsV2Bloc, ContractsV2State>(
      'creates contract template successfully',
      build: () {
        when(
          () => repo.createTemplate(any()),
        ).thenAnswer((_) async => template);
        return ContractsV2Bloc(repo);
      },
      act: (bloc) => bloc.add(const CreateContractTemplateSubmitted(
        key: 'barter_standard',
        name: 'Barter Standard Agreement',
        body: 'Standard barter agreement terms for {{creator}}',
        parameters: ['creator', 'brand'],
      )),
      expect: () => [
        const ContractsV2State(submitting: true),
        const ContractsV2State(
          submitting: false,
          templates: [template],
          infoMessage: 'Contract template created successfully',
        ),
      ],
    );

    blocTest<ContractsV2Bloc, ContractsV2State>(
      'handles failure on template creation',
      build: () {
        when(() => repo.createTemplate(any()))
            .thenThrow(const ServerFailure('Failed to create template'));
        return ContractsV2Bloc(repo);
      },
      act: (bloc) => bloc.add(const CreateContractTemplateSubmitted(
        key: 'invalid',
        name: 'Invalid',
        body: 'Body',
      )),
      expect: () => [
        const ContractsV2State(submitting: true),
        const ContractsV2State(
          submitting: false,
          failure: ServerFailure('Failed to create template'),
        ),
      ],
    );
  });

  group('ContractsV2Bloc - Amendments', () {
    blocTest<ContractsV2Bloc, ContractsV2State>(
      'loads contract amendments',
      build: () {
        when(() => repo.getAmendments('ct_1'))
            .thenAnswer((_) async => [amendment]);
        return ContractsV2Bloc(repo);
      },
      act: (bloc) => bloc.add(const LoadContractAmendmentsRequested('ct_1')),
      expect: () => [
        const ContractsV2State(loading: true),
        const ContractsV2State(loading: false, amendments: [amendment]),
      ],
    );

    blocTest<ContractsV2Bloc, ContractsV2State>(
      'requests contract amendment successfully',
      build: () {
        when(
          () => repo.requestAmendment(
            contractId: any(named: 'contractId'),
            collaborationId: any(named: 'collaborationId'),
            title: any(named: 'title'),
            reason: any(named: 'reason'),
            amendedTerms: any(named: 'amendedTerms'),
          ),
        ).thenAnswer((_) async => amendment);
        return ContractsV2Bloc(repo);
      },
      act: (bloc) => bloc.add(const RequestContractAmendmentSubmitted(
        contractId: 'ct_1',
        collaborationId: 'col_1',
        title: 'Extend usage rights',
        reason: 'Additional ad campaign required',
        amendedTerms: 'Extended duration by 30 days',
      )),
      expect: () => [
        const ContractsV2State(submitting: true),
        const ContractsV2State(
          submitting: false,
          amendments: [amendment],
          infoMessage: 'Amendment requested successfully',
        ),
      ],
    );

    blocTest<ContractsV2Bloc, ContractsV2State>(
      'responds to contract amendment successfully',
      seed: () => const ContractsV2State(amendments: [amendment]),
      build: () {
        when(
          () => repo.respondAmendment(
            contractId: any(named: 'contractId'),
            amendmentId: any(named: 'amendmentId'),
            status: any(named: 'status'),
            notes: any(named: 'notes'),
          ),
        ).thenAnswer((_) async => resolvedAmendment);
        return ContractsV2Bloc(repo);
      },
      act: (bloc) => bloc.add(const RespondContractAmendmentSubmitted(
        contractId: 'ct_1',
        amendmentId: 'amd_1',
        status: 'approved',
      )),
      expect: () => [
        const ContractsV2State(
          submitting: true,
          amendments: [amendment],
        ),
        const ContractsV2State(
          submitting: false,
          amendments: [resolvedAmendment],
          infoMessage: 'Amendment response recorded',
        ),
      ],
    );
  });
}
