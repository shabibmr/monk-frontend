import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';

// ── Events ──────────────────────────────────────────────────

sealed class BrandOnboardingEvent extends Equatable {
  const BrandOnboardingEvent();
  @override
  List<Object?> get props => [];
}

class BrandOnboardingStarted extends BrandOnboardingEvent {
  const BrandOnboardingStarted();
}

class BrandOnboardingSubmitted extends BrandOnboardingEvent {
  const BrandOnboardingSubmitted(this.fields);
  final Map<String, dynamic> fields;
  @override
  List<Object?> get props => [fields];
}

class BrandInviteSubmitted extends BrandOnboardingEvent {
  const BrandInviteSubmitted({
    required this.email,
    required this.memberRole,
    required this.permissions,
  });
  final String email;
  final String memberRole;
  final List<String> permissions;
  @override
  List<Object?> get props => [email, memberRole, permissions];
}

class BrandOnboardingFinished extends BrandOnboardingEvent {
  const BrandOnboardingFinished();
}

// ── State ───────────────────────────────────────────────────

enum BrandOnboardingPhase {
  loading,
  form,
  team,
  saving,
  done,
  failure,
}

class BrandOnboardingState extends Equatable {
  const BrandOnboardingState({
    this.phase = BrandOnboardingPhase.loading,
    this.brand,
    this.failure,
    this.infoMessage,
    this.devInviteToken,
  });

  final BrandOnboardingPhase phase;
  final Brand? brand;
  final Failure? failure;
  final String? infoMessage;
  final String? devInviteToken;

  BrandOnboardingState copyWith({
    BrandOnboardingPhase? phase,
    Brand? brand,
    Failure? failure,
    String? infoMessage,
    String? devInviteToken,
    bool clearFailure = false,
    bool clearMessage = false,
  }) {
    return BrandOnboardingState(
      phase: phase ?? this.phase,
      brand: brand ?? this.brand,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearMessage ? null : (infoMessage ?? this.infoMessage),
      devInviteToken: devInviteToken ?? this.devInviteToken,
    );
  }

  @override
  List<Object?> get props =>
      [phase, brand, failure, infoMessage, devInviteToken];
}

// ── Bloc ────────────────────────────────────────────────────

class BrandOnboardingBloc
    extends Bloc<BrandOnboardingEvent, BrandOnboardingState> {
  BrandOnboardingBloc({
    required BrandRepository repository,
    required SessionCubit sessionCubit,
  })  : _repo = repository,
        _session = sessionCubit,
        super(const BrandOnboardingState()) {
    on<BrandOnboardingStarted>(_onStart);
    on<BrandOnboardingSubmitted>(_onSubmit);
    on<BrandInviteSubmitted>(_onInvite);
    on<BrandOnboardingFinished>(_onFinish);
  }

  final BrandRepository _repo;
  final SessionCubit _session;

  Future<void> _onStart(
    BrandOnboardingStarted event,
    Emitter<BrandOnboardingState> emit,
  ) async {
    emit(state.copyWith(phase: BrandOnboardingPhase.loading));
    try {
      final brands = await _repo.listMine();
      if (brands.isNotEmpty) {
        final brand = brands.first;
        _session.setActiveBrand(brand.id);
        _session.setBrandOnboardingComplete(true);
        emit(
          state.copyWith(
            phase: BrandOnboardingPhase.team,
            brand: brand,
          ),
        );
        return;
      }
      _session.setBrandOnboardingComplete(false);
      emit(state.copyWith(phase: BrandOnboardingPhase.form));
    } on Failure catch (f) {
      emit(state.copyWith(phase: BrandOnboardingPhase.failure, failure: f));
    }
  }

  Future<void> _onSubmit(
    BrandOnboardingSubmitted event,
    Emitter<BrandOnboardingState> emit,
  ) async {
    emit(state.copyWith(phase: BrandOnboardingPhase.saving, clearFailure: true));
    try {
      final brand = state.brand == null
          ? await _repo.create(event.fields)
          : await _repo.update(state.brand!.id, event.fields);
      _session.setActiveBrand(brand.id);
      _session.setBrandOnboardingComplete(true);
      emit(
        state.copyWith(
          phase: BrandOnboardingPhase.team,
          brand: brand,
          infoMessage: 'Company profile saved',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: BrandOnboardingPhase.failure, failure: f));
    }
  }

  Future<void> _onInvite(
    BrandInviteSubmitted event,
    Emitter<BrandOnboardingState> emit,
  ) async {
    final brand = state.brand;
    if (brand == null) return;
    emit(state.copyWith(phase: BrandOnboardingPhase.saving, clearFailure: true));
    try {
      final res = await _repo.inviteMember(
        brandId: brand.id,
        email: event.email,
        memberRole: event.memberRole,
        permissions: event.permissions,
      );
      emit(
        state.copyWith(
          phase: BrandOnboardingPhase.team,
          infoMessage: 'Invite sent to ${event.email}',
          devInviteToken: res.inviteTokenDev,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: BrandOnboardingPhase.failure, failure: f));
    }
  }

  Future<void> _onFinish(
    BrandOnboardingFinished event,
    Emitter<BrandOnboardingState> emit,
  ) async {
    _session.setBrandOnboardingComplete(true);
    if (state.brand != null) {
      _session.setActiveBrand(state.brand!.id);
    }
    emit(state.copyWith(phase: BrandOnboardingPhase.done));
  }
}
