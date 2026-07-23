import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/licensing_grant.dart';
import '../../domain/repositories/licensing_repository.dart';

sealed class LicensingEvent extends Equatable {
  const LicensingEvent();
  @override
  List<Object?> get props => [];
}

class LoadLicensingGrantsRequested extends LicensingEvent {
  const LoadLicensingGrantsRequested({this.collaborationId});
  final String? collaborationId;

  @override
  List<Object?> get props => [collaborationId];
}

class LoadLicensingGrantDetailRequested extends LicensingEvent {
  const LoadLicensingGrantDetailRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class WizardStepChanged extends LicensingEvent {
  const WizardStepChanged(this.step);
  final int step;

  @override
  List<Object?> get props => [step];
}

class CreateLicensingGrantSubmitted extends LicensingEvent {
  const CreateLicensingGrantSubmitted({
    required this.collaborationId,
    required this.assetUrl,
    required this.scope,
    required this.territory,
    required this.durationDays,
    required this.fee,
    this.deliverableId,
  });

  final String collaborationId;
  final String assetUrl;
  final String scope;
  final String territory;
  final int durationDays;
  final double fee;
  final String? deliverableId;

  @override
  List<Object?> get props => [
        collaborationId,
        assetUrl,
        scope,
        territory,
        durationDays,
        fee,
        deliverableId,
      ];
}

class RevokeLicensingGrantSubmitted extends LicensingEvent {
  const RevokeLicensingGrantSubmitted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class LicensingState extends Equatable {
  const LicensingState({
    this.loading = false,
    this.submitting = false,
    this.grants = const [],
    this.activeGrant,
    this.wizardStep = 1,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool submitting;
  final List<LicensingGrant> grants;
  final LicensingGrant? activeGrant;
  final int wizardStep;
  final Failure? failure;
  final String? infoMessage;

  LicensingState copyWith({
    bool? loading,
    bool? submitting,
    List<LicensingGrant>? grants,
    LicensingGrant? activeGrant,
    int? wizardStep,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return LicensingState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      grants: grants ?? this.grants,
      activeGrant: activeGrant ?? this.activeGrant,
      wizardStep: wizardStep ?? this.wizardStep,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
        loading,
        submitting,
        grants,
        activeGrant,
        wizardStep,
        failure,
        infoMessage,
      ];
}

class LicensingBloc extends Bloc<LicensingEvent, LicensingState> {
  LicensingBloc(this._repo) : super(const LicensingState()) {
    on<LoadLicensingGrantsRequested>(_onLoadGrants);
    on<LoadLicensingGrantDetailRequested>(_onLoadGrantDetail);
    on<WizardStepChanged>(_onStepChanged);
    on<CreateLicensingGrantSubmitted>(_onCreateGrant);
    on<RevokeLicensingGrantSubmitted>(_onRevokeGrant);
  }

  final LicensingRepository _repo;

  Future<void> _onLoadGrants(
    LoadLicensingGrantsRequested event,
    Emitter<LicensingState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final list = await _repo.getGrants(collaborationId: event.collaborationId);
      emit(state.copyWith(loading: false, grants: list));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> _onLoadGrantDetail(
    LoadLicensingGrantDetailRequested event,
    Emitter<LicensingState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearFailure: true, clearInfo: true));
    try {
      final grant = await _repo.getGrant(event.id);
      emit(state.copyWith(loading: false, activeGrant: grant));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  void _onStepChanged(
    WizardStepChanged event,
    Emitter<LicensingState> emit,
  ) {
    emit(state.copyWith(wizardStep: event.step));
  }

  Future<void> _onCreateGrant(
    CreateLicensingGrantSubmitted event,
    Emitter<LicensingState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearFailure: true, clearInfo: true));
    try {
      final grant = await _repo.createGrant({
        'collaborationId': event.collaborationId,
        'assetUrl': event.assetUrl,
        'scope': event.scope,
        'territory': event.territory,
        'durationDays': event.durationDays,
        'fee': event.fee,
        if (event.deliverableId != null) 'deliverableId': event.deliverableId,
      });
      emit(state.copyWith(
        submitting: false,
        activeGrant: grant,
        grants: [...state.grants, grant],
        infoMessage: 'Licensing grant created successfully',
      ));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }

  Future<void> _onRevokeGrant(
    RevokeLicensingGrantSubmitted event,
    Emitter<LicensingState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearFailure: true, clearInfo: true));
    try {
      final updated = await _repo.revokeGrant(event.id);
      final list = state.grants.map((g) => g.id == updated.id ? updated : g).toList();
      emit(state.copyWith(
        submitting: false,
        activeGrant: updated,
        grants: list,
        infoMessage: 'Licensing grant revoked',
      ));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }
}
