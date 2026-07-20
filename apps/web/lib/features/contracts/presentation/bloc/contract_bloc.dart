import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/contract.dart';
import '../../domain/repositories/contract_repository.dart';

sealed class ContractEvent extends Equatable {
  const ContractEvent();
  @override
  List<Object?> get props => [];
}

class ContractLoaded extends ContractEvent {
  const ContractLoaded(this.collaborationId);
  final String collaborationId;
  @override
  List<Object?> get props => [collaborationId];
}

class ContractAgreeToggled extends ContractEvent {
  const ContractAgreeToggled(this.agreed);
  final bool agreed;
  @override
  List<Object?> get props => [agreed];
}

class ContractAcceptSubmitted extends ContractEvent {
  const ContractAcceptSubmitted();
}

class ContractState extends Equatable {
  const ContractState({
    this.loading = false,
    this.accepting = false,
    this.agreed = false,
    this.contract,
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool accepting;
  final bool agreed;
  final Contract? contract;
  final Failure? failure;
  final String? infoMessage;

  bool get canAccept =>
      agreed &&
      contract != null &&
      !contract!.isReadOnly &&
      !accepting &&
      contract!.contentHash.isNotEmpty;

  bool get showReceipt =>
      contract != null && contract!.acceptances.isNotEmpty;

  ContractState copyWith({
    bool? loading,
    bool? accepting,
    bool? agreed,
    Contract? contract,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return ContractState(
      loading: loading ?? this.loading,
      accepting: accepting ?? this.accepting,
      agreed: agreed ?? this.agreed,
      contract: contract ?? this.contract,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props =>
      [loading, accepting, agreed, contract, failure, infoMessage];
}

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  ContractBloc(this._repo) : super(const ContractState()) {
    on<ContractLoaded>(_onLoad);
    on<ContractAgreeToggled>(_onAgree);
    on<ContractAcceptSubmitted>(_onAccept);
  }

  final ContractRepository _repo;
  String? _collaborationId;

  Future<void> _onLoad(
    ContractLoaded event,
    Emitter<ContractState> emit,
  ) async {
    _collaborationId = event.collaborationId;
    emit(
      state.copyWith(
        loading: true,
        clearFailure: true,
        clearInfo: true,
        agreed: false,
      ),
    );
    try {
      final c = await _repo.get(event.collaborationId);
      emit(
        state.copyWith(
          loading: false,
          contract: c,
          agreed: c.isReadOnly,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  void _onAgree(ContractAgreeToggled event, Emitter<ContractState> emit) {
    if (state.contract?.isReadOnly == true) return;
    emit(state.copyWith(agreed: event.agreed, clearFailure: true));
  }

  Future<void> _onAccept(
    ContractAcceptSubmitted event,
    Emitter<ContractState> emit,
  ) async {
    final id = _collaborationId;
    final contract = state.contract;
    if (id == null || contract == null) return;
    if (!state.canAccept) {
      emit(
        state.copyWith(
          failure: const ValidationFailure(
            'Agree to terms before accepting',
            errorCode: 'CONTRACT_CHECKBOX_REQUIRED',
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(accepting: true, clearFailure: true, clearInfo: true));
    try {
      final updated = await _repo.accept(
        collaborationId: id,
        contentHash: contract.contentHash,
      );
      emit(
        state.copyWith(
          accepting: false,
          contract: updated,
          agreed: true,
          infoMessage: 'Contract acceptance recorded',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(accepting: false, failure: f));
    }
  }
}
