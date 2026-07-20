import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository.dart';

sealed class CampaignFormEvent extends Equatable {
  const CampaignFormEvent();
  @override
  List<Object?> get props => [];
}

class CampaignFormSubmitted extends CampaignFormEvent {
  const CampaignFormSubmitted({
    required this.brandId,
    required this.name,
    required this.code,
    required this.objective,
    required this.mode,
    this.budgetMajor,
    this.currency = 'INR',
  });

  final String brandId;
  final String name;
  final String code;
  final String objective;
  final String mode;
  final String? budgetMajor;
  final String currency;

  @override
  List<Object?> get props =>
      [brandId, name, code, objective, mode, budgetMajor, currency];
}

enum CampaignFormPhase { idle, saving, success, failure }

class CampaignFormState extends Equatable {
  const CampaignFormState({
    this.phase = CampaignFormPhase.idle,
    this.created,
    this.failure,
    this.mode = 'self_serve',
  });

  final CampaignFormPhase phase;
  final Campaign? created;
  final Failure? failure;
  final String mode;

  @override
  List<Object?> get props => [phase, created, failure, mode];
}

class CampaignFormBloc extends Bloc<CampaignFormEvent, CampaignFormState> {
  CampaignFormBloc(this._repo) : super(const CampaignFormState()) {
    on<CampaignFormSubmitted>(_onSubmit);
  }

  final CampaignRepository _repo;

  Future<void> _onSubmit(
    CampaignFormSubmitted event,
    Emitter<CampaignFormState> emit,
  ) async {
    // Guard: never send licensing collab from P1 UI
    if (!campaignModes.contains(event.mode)) {
      emit(
        CampaignFormState(
          phase: CampaignFormPhase.failure,
          failure: const ValidationFailure('Invalid campaign mode'),
          mode: event.mode,
        ),
      );
      return;
    }
    emit(CampaignFormState(phase: CampaignFormPhase.saving, mode: event.mode));
    try {
      int? budgetMinor;
      if (event.budgetMajor != null && event.budgetMajor!.trim().isNotEmpty) {
        final major = double.tryParse(event.budgetMajor!.trim()) ?? 0;
        budgetMinor = (major * 100).round();
      }
      final created = await _repo.create({
        'brandId': event.brandId,
        'name': event.name,
        'code': event.code,
        'objective': event.objective,
        'mode': event.mode,
        'currency': event.currency,
        'permittedCollabTypes': ['paid'], // never licensing in P1 UI
        if (budgetMinor != null) 'budgetTotalMinor': budgetMinor,
      });
      emit(
        CampaignFormState(
          phase: CampaignFormPhase.success,
          created: created,
          mode: event.mode,
        ),
      );
    } on Failure catch (f) {
      emit(
        CampaignFormState(
          phase: CampaignFormPhase.failure,
          failure: f,
          mode: event.mode,
        ),
      );
    }
  }
}
