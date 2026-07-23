import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/fraud/domain/entities/fraud_risk_report.dart';
import 'package:monk_web/features/fraud/domain/repositories/fraud_repository.dart';
import 'package:monk_web/features/fraud/presentation/bloc/fraud_bloc.dart';
import 'package:monk_web/features/fraud/presentation/bloc/fraud_event.dart';
import 'package:monk_web/features/fraud/presentation/bloc/fraud_state.dart';

class _MockFraudRepository extends Mock implements FraudRepository {}

void main() {
  late _MockFraudRepository repo;

  const mockReport = FraudRiskReport(
    entityId: 'c123',
    riskScore: 0.82,
    isDuplicate: true,
    flaggedReasons: ['Multiple accounts sharing tax ID', 'High engagement anomaly'],
    recommendation: 'Manual review required by compliance team before payout.',
    riskLevel: 'high',
  );

  setUp(() {
    repo = _MockFraudRepository();
  });

  group('FraudBloc', () {
    blocTest<FraudBloc, FraudState>(
      'fetches fraud risk report successfully and emits success state',
      build: () {
        when(() => repo.getFraudRiskReport('c123'))
            .thenAnswer((_) async => mockReport);
        return FraudBloc(repo);
      },
      act: (bloc) => bloc.add(const FetchFraudReportEvent('c123')),
      expect: () => [
        const FraudState(status: FraudStatus.loading),
        const FraudState(
          status: FraudStatus.success,
          report: mockReport,
        ),
      ],
      verify: (_) {
        verify(() => repo.getFraudRiskReport('c123')).called(1);
      },
    );

    blocTest<FraudBloc, FraudState>(
      'dismisses fraud warning banner',
      seed: () => const FraudState(
        status: FraudStatus.success,
        report: mockReport,
      ),
      build: () => FraudBloc(repo),
      act: (bloc) => bloc.add(const DismissFraudWarningEvent()),
      expect: () => [
        const FraudState(
          status: FraudStatus.success,
          report: mockReport,
          isDismissed: true,
        ),
      ],
    );

    blocTest<FraudBloc, FraudState>(
      'handles fetch errors gracefully and emits error state',
      build: () {
        when(() => repo.getFraudRiskReport('invalid'))
            .thenThrow(Exception('Failed to fetch fraud score'));
        return FraudBloc(repo);
      },
      act: (bloc) => bloc.add(const FetchFraudReportEvent('invalid')),
      expect: () => [
        const FraudState(status: FraudStatus.loading),
        const FraudState(
          status: FraudStatus.error,
          errorMessage: 'Failed to fetch fraud score',
        ),
      ],
    );
  });
}
