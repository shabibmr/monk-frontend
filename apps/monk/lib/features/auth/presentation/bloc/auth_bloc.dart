import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../onboarding_brand/domain/repositories/brand_repository.dart';
import '../../../onboarding_influencer/domain/repositories/influencer_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required SessionCubit sessionCubit,
    InfluencerRepository? influencerRepository,
    BrandRepository? brandRepository,
  })  : _repo = authRepository,
        _session = sessionCubit,
        _influencerRepo = influencerRepository,
        _brandRepo = brandRepository,
        super(const AuthState()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthVerifyEmailRequested>(_onVerify);
    on<AuthForgotPasswordRequested>(_onForgot);
    on<AuthResetPasswordRequested>(_onReset);
    on<AuthSessionCleared>(_onCleared);
    on<AuthRestoreRequested>(_onRestore);
  }

  final AuthRepository _repo;
  final SessionCubit _session;
  final InfluencerRepository? _influencerRepo;
  final BrandRepository? _brandRepo;

  Future<void> _refreshOnboardingFlag() async {
    final role = _session.state.role;
    if (role == UserRole.influencer) {
      final repo = _influencerRepo;
      if (repo == null) return;
      try {
        final status = await repo.loadOnboarding();
        _session.setOnboardingComplete(status.completed);
      } catch (_) {
        // Non-fatal: leave flag unknown until wizard loads.
      }
      return;
    }
    if (role == UserRole.brandUser) {
      final repo = _brandRepo;
      if (repo == null) return;
      try {
        final brands = await repo.listMine();
        _session.setBrandOnboardingComplete(brands.isNotEmpty);
        if (brands.isNotEmpty) {
          _session.setActiveBrand(brands.first.id);
        }
      } catch (_) {
        // Non-fatal.
      }
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearFailure: true));
    try {
      final session = await _repo.login(
        email: event.email,
        password: event.password,
      );
      await _refreshOnboardingFlag();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: session.user,
          clearFailure: true,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: AuthStatus.failure, failure: f));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearFailure: true));
    try {
      final user = await _repo.register(
        email: event.email,
        password: event.password,
        role: event.role,
        acceptTerms: event.acceptTerms,
        fullName: event.fullName,
      );
      emit(
        state.copyWith(
          status: AuthStatus.message,
          user: user,
          infoMessage:
              'Account created. Check your email to verify before signing in.',
          clearFailure: true,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: AuthStatus.failure, failure: f));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await _repo.logout();
    emit(
      const AuthState(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> _onVerify(
    AuthVerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearFailure: true));
    try {
      await _repo.verifyEmail(token: event.token);
      emit(
        state.copyWith(
          status: AuthStatus.message,
          infoMessage: 'Email verified. You can sign in now.',
          clearFailure: true,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: AuthStatus.failure, failure: f));
    }
  }

  Future<void> _onForgot(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearFailure: true));
    try {
      await _repo.forgotPassword(email: event.email);
      emit(
        state.copyWith(
          status: AuthStatus.message,
          infoMessage: 'If that email exists, a reset link is on the way.',
          clearFailure: true,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: AuthStatus.failure, failure: f));
    }
  }

  Future<void> _onReset(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearFailure: true));
    try {
      await _repo.resetPassword(
        token: event.token,
        password: event.password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.message,
          infoMessage: 'Password updated. Sign in with your new password.',
          clearFailure: true,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: AuthStatus.failure, failure: f));
    }
  }

  Future<void> _onCleared(
    AuthSessionCleared event,
    Emitter<AuthState> emit,
  ) async {
    await _session.clear();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onRestore(
    AuthRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearFailure: true));
    try {
      final user = await _repo.restoreSession();
      if (user == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }
      await _refreshOnboardingFlag();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearFailure: true,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          failure: f,
          clearUser: true,
        ),
      );
    }
  }
}
