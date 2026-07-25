import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../domain/entities/onboarding.dart';
import '../../domain/repositories/influencer_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({
    required InfluencerRepository repository,
    required SessionCubit sessionCubit,
  })  : _repo = repository,
        _session = sessionCubit,
        super(const OnboardingState()) {
    on<OnboardingStarted>(_onStart);
    on<OnboardingGoToStep>(_onGo);
    on<OnboardingSavePlatforms>(_onPlatforms);
    on<OnboardingRefreshSocial>(_onRefreshSocial);
    on<OnboardingManualSocial>(_onManual);
    on<OnboardingStartOAuth>(_onOAuth);
    on<OnboardingContinueFromSocial>(_onSocialContinue);
    on<OnboardingSaveCategoriesPricing>(_onCategories);
    on<OnboardingSaveTeam>(_onTeam);
    on<OnboardingConfirmComplete>(_onComplete);
  }

  final InfluencerRepository _repo;
  final SessionCubit _session;

  Future<void> _onStart(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(phase: OnboardingPhase.loading, clearFailure: true));
    try {
      final status = await _repo.loadOnboarding();
      _session.setOnboardingComplete(status.completed);
      if (status.completed) {
        // Already complete: show the summary, do not redirect (justCompleted
        // stays false).
        emit(
          state.copyWith(
            phase: OnboardingPhase.completed,
            profileId: status.profileId,
            progress: status.progress,
            currentStep: 6,
            verificationStatus: status.verificationStatus,
          ),
        );
        return;
      }
      final step = status.nextStep.clamp(1, 6);
      emit(
        state.copyWith(
          phase: OnboardingPhase.ready,
          profileId: status.profileId,
          progress: status.progress,
          currentStep: step < 1 ? 2 : step,
          verificationStatus: status.verificationStatus,
        ),
      );
      if (step == 3 || status.progress.step2) {
        add(const OnboardingRefreshSocial());
      }
    } on Failure catch (f) {
      emit(state.copyWith(phase: OnboardingPhase.failure, failure: f));
    }
  }

  void _onGo(OnboardingGoToStep event, Emitter<OnboardingState> emit) {
    // Backward always OK; forward only to current or completed+1 max.
    if (event.step < 1 || event.step > 6) return;
    if (event.step > state.currentStep) return;
    emit(state.copyWith(currentStep: event.step, clearFailure: true));
  }

  Future<void> _onPlatforms(
    OnboardingSavePlatforms event,
    Emitter<OnboardingState> emit,
  ) async {
    final id = state.profileId;
    if (id == null) return;
    emit(state.copyWith(phase: OnboardingPhase.saving, clearFailure: true));
    try {
      await _repo.savePlatforms(
        profileId: id,
        primaryPlatform: event.primaryPlatform,
        secondaryPlatform: event.secondaryPlatform,
        mainRegion: event.mainRegion,
        secondaryRegion: event.secondaryRegion,
        blogUrl: event.blogUrl,
        country: event.country,
        city: event.city,
      );
      final status = await _repo.loadOnboarding();
      emit(
        state.copyWith(
          phase: OnboardingPhase.ready,
          progress: status.progress,
          currentStep: 3,
          infoMessage: 'Progress saved',
        ),
      );
      add(const OnboardingRefreshSocial());
    } on Failure catch (f) {
      emit(state.copyWith(phase: OnboardingPhase.failure, failure: f));
    }
  }

  Future<void> _onRefreshSocial(
    OnboardingRefreshSocial event,
    Emitter<OnboardingState> emit,
  ) async {
    final id = state.profileId;
    if (id == null) return;
    try {
      final accounts = await _repo.listSocial(id);
      emit(state.copyWith(socialAccounts: accounts));
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  Future<void> _onManual(
    OnboardingManualSocial event,
    Emitter<OnboardingState> emit,
  ) async {
    final id = state.profileId;
    if (id == null) return;
    emit(state.copyWith(phase: OnboardingPhase.saving, clearFailure: true));
    try {
      await _repo.manualSocial(
        profileId: id,
        platform: event.platform,
        handle: event.handle,
      );
      final accounts = await _repo.listSocial(id);
      final status = await _repo.loadOnboarding();
      emit(
        state.copyWith(
          phase: OnboardingPhase.ready,
          socialAccounts: accounts,
          progress: status.progress,
          infoMessage: 'Account declared',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: OnboardingPhase.failure, failure: f));
    }
  }

  Future<void> _onOAuth(
    OnboardingStartOAuth event,
    Emitter<OnboardingState> emit,
  ) async {
    final id = state.profileId;
    if (id == null) return;
    emit(state.copyWith(phase: OnboardingPhase.saving, clearFailure: true));
    try {
      final url = await _repo.startOAuth(
        profileId: id,
        platform: event.platform,
      );
      emit(
        state.copyWith(
          phase: OnboardingPhase.oauthLaunch,
          oauthUrl: url,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: OnboardingPhase.failure, failure: f));
    }
  }

  Future<void> _onSocialContinue(
    OnboardingContinueFromSocial event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(currentStep: 4, phase: OnboardingPhase.ready));
  }

  Future<void> _onCategories(
    OnboardingSaveCategoriesPricing event,
    Emitter<OnboardingState> emit,
  ) async {
    final id = state.profileId;
    if (id == null) return;
    emit(state.copyWith(phase: OnboardingPhase.saving, clearFailure: true));
    try {
      await _repo.saveCategoriesPricing(
        profileId: id,
        mainCategory: event.mainCategory,
        secondaryCategories: event.secondaryCategories,
        audienceGender: event.audienceGender,
        ageRanges: event.ageRanges,
        monetization: event.monetization,
        openToBarter: event.openToBarter,
        licensingAvailable: event.licensingAvailable,
        biography: event.biography,
        displayName: event.displayName,
        pricing: event.pricing,
      );
      final status = await _repo.loadOnboarding();
      emit(
        state.copyWith(
          phase: OnboardingPhase.ready,
          progress: status.progress,
          currentStep: 5,
          infoMessage: 'Progress saved',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: OnboardingPhase.failure, failure: f));
    }
  }

  Future<void> _onTeam(
    OnboardingSaveTeam event,
    Emitter<OnboardingState> emit,
  ) async {
    final id = state.profileId;
    if (id == null) return;
    emit(state.copyWith(phase: OnboardingPhase.saving, clearFailure: true));
    try {
      if (event.managerEmail != null && event.managerEmail!.isNotEmpty) {
        await _repo.inviteManager(profileId: id, email: event.managerEmail!);
      }
      ReferralInvite? invite;
      if (event.referralEmail != null && event.referralEmail!.isNotEmpty) {
        invite = await _repo.createReferral(
          profileId: id,
          email: event.referralEmail,
        );
      } else if (!event.skip) {
        // Creating any referral marks step 5
        invite = await _repo.createReferral(profileId: id);
      } else {
        invite = await _repo.createReferral(profileId: id);
      }
      final status = await _repo.loadOnboarding();
      emit(
        state.copyWith(
          phase: OnboardingPhase.ready,
          progress: status.progress,
          currentStep: 6,
          lastReferral: invite,
          infoMessage: 'Progress saved',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: OnboardingPhase.failure, failure: f));
    }
  }

  Future<void> _onComplete(
    OnboardingConfirmComplete event,
    Emitter<OnboardingState> emit,
  ) async {
    final id = state.profileId;
    if (id == null) return;
    emit(state.copyWith(phase: OnboardingPhase.saving, clearFailure: true));
    try {
      await _repo.completeOnboarding(id);
      _session.setOnboardingComplete(true);
      final status = await _repo.loadOnboarding();
      emit(
        state.copyWith(
          phase: OnboardingPhase.completed,
          progress: status.progress,
          verificationStatus: status.verificationStatus,
          justCompleted: true,
          infoMessage: 'Onboarding complete — pending verification',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: OnboardingPhase.failure, failure: f));
    }
  }
}
