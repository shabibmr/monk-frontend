import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/onboarding.dart';

enum OnboardingPhase { loading, ready, saving, oauthLaunch, completed, failure }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.phase = OnboardingPhase.loading,
    this.profileId,
    this.progress = const OnboardingProgress(),
    this.currentStep = 1,
    this.socialAccounts = const [],
    this.lastReferral,
    this.oauthUrl,
    this.failure,
    this.infoMessage,
    this.verificationStatus,
    this.justCompleted = false,
  });

  final OnboardingPhase phase;
  final String? profileId;
  final OnboardingProgress progress;
  final int currentStep;
  final List<SocialAccount> socialAccounts;
  final ReferralInvite? lastReferral;
  final String? oauthUrl;
  final Failure? failure;
  final String? infoMessage;
  final String? verificationStatus;

  /// True only for the state emitted right after the user confirms the final
  /// step. Loading an already-complete profile leaves this false so the wizard
  /// can be opened for review instead of redirecting to the dashboard.
  final bool justCompleted;

  OnboardingState copyWith({
    OnboardingPhase? phase,
    String? profileId,
    OnboardingProgress? progress,
    int? currentStep,
    List<SocialAccount>? socialAccounts,
    ReferralInvite? lastReferral,
    String? oauthUrl,
    Failure? failure,
    String? infoMessage,
    String? verificationStatus,
    bool justCompleted = false,
    bool clearFailure = false,
    bool clearOauth = false,
    bool clearMessage = false,
  }) {
    return OnboardingState(
      phase: phase ?? this.phase,
      profileId: profileId ?? this.profileId,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      socialAccounts: socialAccounts ?? this.socialAccounts,
      lastReferral: lastReferral ?? this.lastReferral,
      oauthUrl: clearOauth ? null : (oauthUrl ?? this.oauthUrl),
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearMessage ? null : (infoMessage ?? this.infoMessage),
      verificationStatus: verificationStatus ?? this.verificationStatus,
      // One-shot signal: never carried over into the next state.
      justCompleted: justCompleted,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        profileId,
        progress,
        currentStep,
        socialAccounts,
        lastReferral,
        oauthUrl,
        failure,
        infoMessage,
        verificationStatus,
        justCompleted,
      ];
}
