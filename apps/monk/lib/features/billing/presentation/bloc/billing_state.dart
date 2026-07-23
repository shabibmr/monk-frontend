import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/billing_invoice.dart';
import '../../domain/entities/subscription_details.dart';
import '../../domain/entities/subscription_plan.dart';

enum BillingPhase { initial, loading, ready, failure }

class BillingState extends Equatable {
  const BillingState({
    this.phase = BillingPhase.initial,
    this.subscription,
    this.availablePlans = const [],
    this.invoices = const [],
    this.actionSuccessMessage,
    this.failure,
    this.isUpgrading = false,
  });

  final BillingPhase phase;
  final SubscriptionDetails? subscription;
  final List<SubscriptionPlan> availablePlans;
  final List<BillingInvoice> invoices;
  final String? actionSuccessMessage;
  final Failure? failure;
  final bool isUpgrading;

  BillingState copyWith({
    BillingPhase? phase,
    SubscriptionDetails? subscription,
    List<SubscriptionPlan>? availablePlans,
    List<BillingInvoice>? invoices,
    String? actionSuccessMessage,
    Failure? failure,
    bool? isUpgrading,
  }) {
    return BillingState(
      phase: phase ?? this.phase,
      subscription: subscription ?? this.subscription,
      availablePlans: availablePlans ?? this.availablePlans,
      invoices: invoices ?? this.invoices,
      actionSuccessMessage: actionSuccessMessage,
      failure: failure,
      isUpgrading: isUpgrading ?? this.isUpgrading,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        subscription,
        availablePlans,
        invoices,
        actionSuccessMessage,
        failure,
        isUpgrading,
      ];
}
