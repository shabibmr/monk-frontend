import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/contract_amendment.dart';
import '../../domain/entities/contract_template.dart';
import '../../domain/repositories/contract_repository.dart';

sealed class ContractsV2Event extends Equatable {
  const ContractsV2Event();
  @override
  List<Object?> get props => [];
}

class LoadContractTemplatesRequested extends ContractsV2Event {
  const LoadContractTemplatesRequested();
}

class CreateContractTemplateSubmitted extends ContractsV2Event {
  const CreateContractTemplateSubmitted({
    required this.key,
    required this.name,
    required this.body,
    this.parameters = const [],
    this.version = '1.0',
  });

  final String key;
  final String name;
  final String body;
  final List<String> parameters;
  final String version;

  @override
  List<Object?> get props => [key, name, body, parameters, version];
}

class DeleteContractTemplateSubmitted extends ContractsV2Event {
  const DeleteContractTemplateSubmitted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class LoadContractAmendmentsRequested extends ContractsV2Event {
  const LoadContractAmendmentsRequested(this.contractId);
  final String contractId;

  @override
  List<Object?> get props => [contractId];
}

class RequestContractAmendmentSubmitted extends ContractsV2Event {
  const RequestContractAmendmentSubmitted({
    required this.contractId,
    required this.collaborationId,
    required this.title,
    required this.reason,
    required this.amendedTerms,
  });

  final String contractId;
  final String collaborationId;
  final String title;
  final String reason;
  final String amendedTerms;

  @override
  List<Object?> get props => [
        contractId,
        collaborationId,
        title,
        reason,
        amendedTerms,
      ];
}

class RespondContractAmendmentSubmitted extends ContractsV2Event {
  const RespondContractAmendmentSubmitted({
    required this.contractId,
    required this.amendmentId,
    required this.status,
    this.notes,
  });

  final String contractId;
  final String amendmentId;
  final String status;
  final String? notes;

  @override
  List<Object?> get props => [contractId, amendmentId, status, notes];
}

class ContractsV2State extends Equatable {
  const ContractsV2State({
    this.loading = false,
    this.submitting = false,
    this.templates = const [],
    this.amendments = const [],
    this.failure,
    this.infoMessage,
  });

  final bool loading;
  final bool submitting;
  final List<ContractTemplate> templates;
  final List<ContractAmendment> amendments;
  final Failure? failure;
  final String? infoMessage;

  ContractsV2State copyWith({
    bool? loading,
    bool? submitting,
    List<ContractTemplate>? templates,
    List<ContractAmendment>? amendments,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
    bool clearInfo = false,
  }) {
    return ContractsV2State(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      templates: templates ?? this.templates,
      amendments: amendments ?? this.amendments,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
        loading,
        submitting,
        templates,
        amendments,
        failure,
        infoMessage,
      ];
}

class ContractsV2Bloc extends Bloc<ContractsV2Event, ContractsV2State> {
  ContractsV2Bloc(this._repo) : super(const ContractsV2State()) {
    on<LoadContractTemplatesRequested>(_onLoadTemplates);
    on<CreateContractTemplateSubmitted>(_onCreateTemplate);
    on<DeleteContractTemplateSubmitted>(_onDeleteTemplate);
    on<LoadContractAmendmentsRequested>(_onLoadAmendments);
    on<RequestContractAmendmentSubmitted>(_onRequestAmendment);
    on<RespondContractAmendmentSubmitted>(_onRespondAmendment);
  }

  final ContractRepository _repo;

  Future<void> _onLoadTemplates(
    LoadContractTemplatesRequested event,
    Emitter<ContractsV2State> emit,
  ) async {
    emit(state.copyWith(
      loading: true,
      clearFailure: true,
      clearInfo: true,
    ));
    try {
      final list = await _repo.getTemplates();
      emit(state.copyWith(loading: false, templates: list));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> _onCreateTemplate(
    CreateContractTemplateSubmitted event,
    Emitter<ContractsV2State> emit,
  ) async {
    emit(state.copyWith(
      submitting: true,
      clearFailure: true,
      clearInfo: true,
    ));
    try {
      final newT = await _repo.createTemplate({
        'key': event.key,
        'name': event.name,
        'body': event.body,
        'parameters': event.parameters,
        'version': event.version,
      });
      emit(state.copyWith(
        submitting: false,
        templates: [...state.templates, newT],
        infoMessage: 'Contract template created successfully',
      ));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }

  Future<void> _onDeleteTemplate(
    DeleteContractTemplateSubmitted event,
    Emitter<ContractsV2State> emit,
  ) async {
    emit(state.copyWith(
      submitting: true,
      clearFailure: true,
      clearInfo: true,
    ));
    try {
      await _repo.deleteTemplate(event.id);
      final updated = state.templates.where((t) => t.id != event.id).toList();
      emit(state.copyWith(
        submitting: false,
        templates: updated,
        infoMessage: 'Template deleted',
      ));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }

  Future<void> _onLoadAmendments(
    LoadContractAmendmentsRequested event,
    Emitter<ContractsV2State> emit,
  ) async {
    emit(state.copyWith(
      loading: true,
      clearFailure: true,
      clearInfo: true,
    ));
    try {
      final list = await _repo.getAmendments(event.contractId);
      emit(state.copyWith(loading: false, amendments: list));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> _onRequestAmendment(
    RequestContractAmendmentSubmitted event,
    Emitter<ContractsV2State> emit,
  ) async {
    emit(state.copyWith(
      submitting: true,
      clearFailure: true,
      clearInfo: true,
    ));
    try {
      final newA = await _repo.requestAmendment(
        contractId: event.contractId,
        collaborationId: event.collaborationId,
        title: event.title,
        reason: event.reason,
        amendedTerms: event.amendedTerms,
      );
      emit(state.copyWith(
        submitting: false,
        amendments: [...state.amendments, newA],
        infoMessage: 'Amendment requested successfully',
      ));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }

  Future<void> _onRespondAmendment(
    RespondContractAmendmentSubmitted event,
    Emitter<ContractsV2State> emit,
  ) async {
    emit(state.copyWith(
      submitting: true,
      clearFailure: true,
      clearInfo: true,
    ));
    try {
      final updated = await _repo.respondAmendment(
        contractId: event.contractId,
        amendmentId: event.amendmentId,
        status: event.status,
        notes: event.notes,
      );
      final list = state.amendments.map((a) {
        return a.id == updated.id ? updated : a;
      }).toList();
      emit(state.copyWith(
        submitting: false,
        amendments: list,
        infoMessage: 'Amendment response recorded',
      ));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, failure: f));
    }
  }
}
