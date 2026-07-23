import 'package:equatable/equatable.dart';

class OperatorMetrics extends Equatable {
  const OperatorMetrics({
    required this.operatorId,
    required this.name,
    required this.activeBriefs,
    required this.completedCampaigns,
    required this.onTimeDeliveryRatePct,
  });

  final String operatorId;
  final String name;
  final int activeBriefs;
  final int completedCampaigns;
  final double onTimeDeliveryRatePct;

  @override
  List<Object?> get props => [
        operatorId,
        name,
        activeBriefs,
        completedCampaigns,
        onTimeDeliveryRatePct,
      ];
}

class AgencyOperatorReport extends Equatable {
  const AgencyOperatorReport({
    required this.totalActiveBriefs,
    required this.deliveredOnTimeCount,
    required this.pendingApprovalAssetsCount,
    required this.avgTurnaroundDays,
    required this.operators,
  });

  final int totalActiveBriefs;
  final int deliveredOnTimeCount;
  final int pendingApprovalAssetsCount;
  final double avgTurnaroundDays;
  final List<OperatorMetrics> operators;

  @override
  List<Object?> get props => [
        totalActiveBriefs,
        deliveredOnTimeCount,
        pendingApprovalAssetsCount,
        avgTurnaroundDays,
        operators,
      ];
}
