import 'package:equatable/equatable.dart';

class OnboardingProgress extends Equatable {
  const OnboardingProgress({
    this.step1 = false,
    this.step2 = false,
    this.step3 = false,
    this.step4 = false,
    this.step5 = false,
    this.step6 = false,
  });

  final bool step1;
  final bool step2;
  final bool step3;
  final bool step4;
  final bool step5;
  final bool step6;

  Set<int> get completedSteps {
    final s = <int>{};
    if (step1) s.add(1);
    if (step2) s.add(2);
    if (step3) s.add(3);
    if (step4) s.add(4);
    if (step5) s.add(5);
    if (step6) s.add(6);
    return s;
  }

  @override
  List<Object?> get props => [step1, step2, step3, step4, step5, step6];
}

class OnboardingStatus extends Equatable {
  const OnboardingStatus({
    required this.profileId,
    required this.progress,
    required this.nextStep,
    required this.completed,
    this.verificationStatus,
  });

  final String profileId;
  final OnboardingProgress progress;
  final int nextStep;
  final bool completed;
  final String? verificationStatus;

  @override
  List<Object?> get props =>
      [profileId, progress, nextStep, completed, verificationStatus];
}

class SocialAccount extends Equatable {
  const SocialAccount({
    required this.id,
    required this.platform,
    this.handle,
    this.followersCount,
    this.declaredOnly,
  });

  final String id;
  final String platform;
  final String? handle;
  final int? followersCount;
  final bool? declaredOnly;

  @override
  List<Object?> get props =>
      [id, platform, handle, followersCount, declaredOnly];
}

class ReferralInvite extends Equatable {
  const ReferralInvite({
    required this.id,
    required this.code,
    this.inviteeEmail,
    this.note,
  });

  final String id;
  final String code;
  final String? inviteeEmail;
  final String? note;

  @override
  List<Object?> get props => [id, code, inviteeEmail, note];
}

class PricingLine extends Equatable {
  const PricingLine({
    required this.deliverableType,
    required this.priceMinor,
    required this.currency,
  });

  final String deliverableType;
  final int priceMinor;
  final String currency;

  @override
  List<Object?> get props => [deliverableType, priceMinor, currency];
}

/// Convert major-unit decimal string to integer minor units (scale 2).
int majorToMinor(String major) {
  final cleaned = major.trim().replaceAll(',', '');
  if (cleaned.isEmpty) return 0;
  final parts = cleaned.split('.');
  final whole = int.tryParse(parts[0]) ?? 0;
  var frac = 0;
  if (parts.length > 1) {
    final f = parts[1].padRight(2, '0').substring(0, 2);
    frac = int.tryParse(f) ?? 0;
  }
  return whole * 100 + (whole < 0 ? -frac : frac);
}
