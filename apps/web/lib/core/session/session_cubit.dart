import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../features/auth/domain/entities/user.dart';
import 'token_store.dart';

class SessionState extends Equatable {
  const SessionState({
    this.user,
    this.activeBrandId,
    this.activeProfileId,
    this.activeProfileName,
    this.managerPermissions = const [],
    this.isManagerContext = false,
    this.hydrated = false,
    this.influencerOnboardingComplete,
    this.brandOnboardingComplete,
  });

  final User? user;
  final String? activeBrandId;
  final String? activeProfileId;
  final String? activeProfileName;
  final List<String> managerPermissions;
  final bool isManagerContext;
  final bool hydrated;

  /// null = unknown / not loaded; true/false after onboarding API check.
  final bool? influencerOnboardingComplete;
  final bool? brandOnboardingComplete;

  bool get isAuthenticated => user != null;
  UserRole? get role => user?.role;
  bool get needsEmailVerification =>
      user?.status == UserStatus.pendingEmail;

  bool get needsInfluencerOnboarding =>
      role == UserRole.influencer && influencerOnboardingComplete == false;

  bool get needsBrandOnboarding =>
      role == UserRole.brandUser && brandOnboardingComplete == false;

  SessionState copyWith({
    User? user,
    String? activeBrandId,
    String? activeProfileId,
    String? activeProfileName,
    List<String>? managerPermissions,
    bool? isManagerContext,
    bool? hydrated,
    bool? influencerOnboardingComplete,
    bool? brandOnboardingComplete,
    bool clearUser = false,
    bool clearBrand = false,
    bool clearProfile = false,
    bool clearOnboarding = false,
  }) {
    return SessionState(
      user: clearUser ? null : (user ?? this.user),
      activeBrandId: clearBrand ? null : (activeBrandId ?? this.activeBrandId),
      activeProfileId:
          clearProfile ? null : (activeProfileId ?? this.activeProfileId),
      activeProfileName:
          clearProfile ? null : (activeProfileName ?? this.activeProfileName),
      managerPermissions: clearProfile
          ? const []
          : (managerPermissions ?? this.managerPermissions),
      isManagerContext: clearProfile
          ? false
          : (isManagerContext ?? this.isManagerContext),
      hydrated: hydrated ?? this.hydrated,
      influencerOnboardingComplete: clearOnboarding
          ? null
          : (influencerOnboardingComplete ??
              this.influencerOnboardingComplete),
      brandOnboardingComplete: clearOnboarding
          ? null
          : (brandOnboardingComplete ?? this.brandOnboardingComplete),
    );
  }

  @override
  List<Object?> get props => [
        user,
        activeBrandId,
        activeProfileId,
        activeProfileName,
        managerPermissions,
        isManagerContext,
        hydrated,
        influencerOnboardingComplete,
        brandOnboardingComplete,
      ];
}

/// Global session: user, role, brand/profile context.
/// Implements [Listenable] for go_router refreshListenable.
class SessionCubit extends Cubit<SessionState> implements Listenable {
  SessionCubit(this._tokenStore) : super(const SessionState());

  final TokenStore _tokenStore;
  final ObserverList<VoidCallback> _listeners = ObserverList();

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notify() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  @override
  void onChange(Change<SessionState> change) {
    super.onChange(change);
    _notify();
  }

  Future<void> hydrate() async {
    // Tokens alone don't restore user — AuthBloc restore will set user.
    emit(state.copyWith(hydrated: true));
  }

  void setSession(User user) {
    emit(state.copyWith(user: user, hydrated: true));
  }

  void setOnboardingComplete(bool complete) {
    emit(state.copyWith(influencerOnboardingComplete: complete));
  }

  void setBrandOnboardingComplete(bool complete) {
    emit(state.copyWith(brandOnboardingComplete: complete));
  }

  void setActiveBrand(String? brandId) {
    emit(state.copyWith(activeBrandId: brandId, clearBrand: brandId == null));
  }

  void setActiveProfile({
    required String? profileId,
    required bool isManagerContext,
    String? displayName,
    List<String> permissions = const [],
  }) {
    if (profileId == null) {
      emit(
        state.copyWith(
          clearProfile: true,
          isManagerContext: false,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        activeProfileId: profileId,
        activeProfileName: displayName,
        managerPermissions: permissions,
        isManagerContext: isManagerContext,
      ),
    );
  }

  Future<void> clear() async {
    await _tokenStore.clear();
    emit(const SessionState(hydrated: true));
  }

  String? roleHomePath() {
    final role = state.role;
    if (role == null) return null;
    switch (role) {
      case UserRole.brandUser:
        return '/b/dashboard';
      case UserRole.influencer:
        return '/c/dashboard';
      case UserRole.manager:
        return '/c/roster';
      case UserRole.agencyOperator:
        return '/a/agency/briefs';
      case UserRole.admin:
        return '/a/dashboard';
    }
  }
}
