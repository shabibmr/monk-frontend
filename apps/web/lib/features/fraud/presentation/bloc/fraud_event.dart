import 'package:equatable/equatable.dart';

abstract class FraudEvent extends Equatable {
  const FraudEvent();

  @override
  List<Object?> get props => [];
}

class FetchFraudReportEvent extends FraudEvent {
  const FetchFraudReportEvent(this.entityId);

  final String entityId;

  @override
  List<Object?> get props => [entityId];
}

class DismissFraudWarningEvent extends FraudEvent {
  const DismissFraudWarningEvent();
}
