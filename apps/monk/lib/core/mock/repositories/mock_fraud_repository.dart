import '../../../features/fraud/domain/entities/fraud_risk_report.dart';
import '../../../features/fraud/domain/repositories/fraud_repository.dart';
import '../mock_ids.dart';
import '../mock_seed_store.dart';

/// Offline demo implementation of [FraudRepository].
class MockFraudRepository implements FraudRepository {
  MockFraudRepository(this.store);

  final MockSeedStore store;

  static const _key = 'fraud_reports';

  @override
  Future<FraudRiskReport> getFraudRiskReport(String entityId) async {
    await store.delay();

    final cached = store.findWhere<FraudRiskReport>(
      _key,
      (r) => r.entityId == entityId,
    );
    if (cached != null) return cached;

    // Deterministic canned reports for known demo entities.
    final FraudRiskReport report;
    if (entityId == MockIds.influencer1 || entityId == MockIds.creator1) {
      report = FraudRiskReport(
        entityId: entityId,
        riskScore: 0.12,
        isDuplicate: false,
        flaggedReasons: const [],
        recommendation: 'Proceed with standard workflow.',
        riskLevel: 'low',
      );
    } else if (entityId == MockIds.influencer3 ||
        entityId.contains('fresh')) {
      report = FraudRiskReport(
        entityId: entityId,
        riskScore: 0.58,
        isDuplicate: false,
        flaggedReasons: const [
          'Recent account creation',
          'Limited engagement history',
        ],
        recommendation: 'Request additional verification before funding.',
        riskLevel: 'medium',
      );
    } else if (entityId.contains('dup') || entityId.contains('fraud')) {
      report = FraudRiskReport(
        entityId: entityId,
        riskScore: 0.91,
        isDuplicate: true,
        flaggedReasons: const [
          'Possible duplicate profile',
          'Suspicious payment instrument pattern',
        ],
        recommendation: 'Block payout and escalate to compliance.',
        riskLevel: 'high',
      );
    } else {
      report = FraudRiskReport(
        entityId: entityId,
        riskScore: 0.22,
        isDuplicate: false,
        flaggedReasons: const [],
        recommendation: 'Proceed with standard workflow.',
        riskLevel: 'low',
      );
    }

    store.add(_key, report);
    return report;
  }
}
