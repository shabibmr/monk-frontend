import 'package:equatable/equatable.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class FetchBillingDetailsStarted extends BillingEvent {
  const FetchBillingDetailsStarted();
}

class UpgradePlanRequested extends BillingEvent {
  const UpgradePlanRequested(this.planId);

  final String planId;

  @override
  List<Object?> get props => [planId];
}
