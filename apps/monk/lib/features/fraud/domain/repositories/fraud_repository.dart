import '../entities/fraud_risk_report.dart';

abstract class FraudRepository {
  Future<FraudRiskReport> getFraudRiskReport(String entityId);
}
