import 'package:equatable/equatable.dart';

import '../../domain/entities/fraud_risk_report.dart';

enum FraudStatus { initial, loading, success, error }

class FraudState extends Equatable {
  const FraudState({
    this.status = FraudStatus.initial,
    this.report,
    this.errorMessage,
    this.isDismissed = false,
  });

  final FraudStatus status;
  final FraudRiskReport? report;
  final String? errorMessage;
  final bool isDismissed;

  bool get isLoading => status == FraudStatus.loading;
  bool get isSuccess => status == FraudStatus.success;
  bool get hasError => status == FraudStatus.error;

  FraudState copyWith({
    FraudStatus? status,
    FraudRiskReport? report,
    String? errorMessage,
    bool? isDismissed,
  }) {
    return FraudState(
      status: status ?? this.status,
      report: report ?? this.report,
      errorMessage: errorMessage ?? this.errorMessage,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  @override
  List<Object?> get props => [status, report, errorMessage, isDismissed];
}
