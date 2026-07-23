import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/licensing/domain/entities/licensing_grant.dart';
import 'package:monk_web/features/licensing/domain/repositories/licensing_repository.dart';
import 'package:monk_web/features/licensing/presentation/bloc/licensing_bloc.dart';

class _MockLicensingRepo extends Mock implements LicensingRepository {}

void main() {
  late _MockLicensingRepo repo;

  const grant = LicensingGrant(
    id: 'lg_1',
    collaborationId: 'col_1',
    assetUrl: 'https://cdn.example.com/assets/1.mp4',
    token: 'tok_abc123',
    scope: 'digital_and_social',
    territory: 'Worldwide',
    durationDays: 365,
    fee: 500.0,
    status: 'active',
  );

  const revokedGrant = LicensingGrant(
    id: 'lg_1',
    collaborationId: 'col_1',
    assetUrl: 'https://cdn.example.com/assets/1.mp4',
    token: 'tok_abc123',
    scope: 'digital_and_social',
    territory: 'Worldwide',
    durationDays: 365,
    fee: 500.0,
    status: 'revoked',
  );

  setUp(() {
    repo = _MockLicensingRepo();
  });

  group('LicensingBloc', () {
    blocTest<LicensingBloc, LicensingState>(
      'loads grants successfully',
      build: () {
        when(() => repo.getGrants(collaborationId: any(named: 'collaborationId')))
            .thenAnswer((_) async => [grant]);
        return LicensingBloc(repo);
      },
      act: (b) => b.add(const LoadLicensingGrantsRequested(collaborationId: 'col_1')),
      expect: () => [
        const LicensingState(loading: true),
        const LicensingState(loading: false, grants: [grant]),
      ],
      verify: (_) {
        verify(() => repo.getGrants(collaborationId: 'col_1')).called(1);
      },
    );

    blocTest<LicensingBloc, LicensingState>(
      'loads single grant detail successfully',
      build: () {
        when(() => repo.getGrant('lg_1')).thenAnswer((_) async => grant);
        return LicensingBloc(repo);
      },
      act: (b) => b.add(const LoadLicensingGrantDetailRequested('lg_1')),
      expect: () => [
        const LicensingState(loading: true),
        const LicensingState(loading: false, activeGrant: grant),
      ],
    );

    blocTest<LicensingBloc, LicensingState>(
      'updates wizard step',
      build: () => LicensingBloc(repo),
      act: (b) => b.add(const WizardStepChanged(2)),
      expect: () => [
        const LicensingState(wizardStep: 2),
      ],
    );

    blocTest<LicensingBloc, LicensingState>(
      'creates licensing grant successfully',
      build: () {
        when(() => repo.createGrant(any())).thenAnswer((_) async => grant);
        return LicensingBloc(repo);
      },
      act: (b) => b.add(const CreateLicensingGrantSubmitted(
        collaborationId: 'col_1',
        assetUrl: 'https://cdn.example.com/assets/1.mp4',
        scope: 'digital_and_social',
        territory: 'Worldwide',
        durationDays: 365,
        fee: 500.0,
      )),
      expect: () => [
        const LicensingState(submitting: true),
        const LicensingState(
          submitting: false,
          activeGrant: grant,
          grants: [grant],
          infoMessage: 'Licensing grant created successfully',
        ),
      ],
    );

    blocTest<LicensingBloc, LicensingState>(
      'revokes licensing grant successfully',
      seed: () => const LicensingState(grants: [grant]),
      build: () {
        when(() => repo.revokeGrant('lg_1'))
            .thenAnswer((_) async => revokedGrant);
        return LicensingBloc(repo);
      },
      act: (b) => b.add(const RevokeLicensingGrantSubmitted('lg_1')),
      expect: () => [
        const LicensingState(submitting: true, grants: [grant]),
        const LicensingState(
          submitting: false,
          activeGrant: revokedGrant,
          grants: [revokedGrant],
          infoMessage: 'Licensing grant revoked',
        ),
      ],
    );

    blocTest<LicensingBloc, LicensingState>(
      'handles failure when creating grant',
      build: () {
        when(() => repo.createGrant(any()))
            .thenThrow(const ServerFailure('Failed to create grant'));
        return LicensingBloc(repo);
      },
      act: (b) => b.add(const CreateLicensingGrantSubmitted(
        collaborationId: 'col_1',
        assetUrl: 'invalid',
        scope: 'digital',
        territory: 'Worldwide',
        durationDays: 30,
        fee: 100,
      )),
      expect: () => [
        const LicensingState(submitting: true),
        const LicensingState(
          submitting: false,
          failure: ServerFailure('Failed to create grant'),
        ),
      ],
    );
  });
}
