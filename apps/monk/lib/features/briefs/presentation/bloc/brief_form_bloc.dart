import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/brief.dart';
import '../../domain/repositories/brief_repository.dart';

class BriefFormSubmitted extends Equatable {
  const BriefFormSubmitted({
    required this.brandId,
    required this.goals,
    this.budgetMajor,
    this.currency = 'INR',
    this.productDescription,
    this.name,
  });

  final String brandId;
  final String goals;
  final String? budgetMajor;
  final String currency;
  final String? productDescription;
  final String? name;

  @override
  List<Object?> get props =>
      [brandId, goals, budgetMajor, currency, productDescription, name];
}

enum BriefFormPhase { idle, saving, success, failure }

class BriefFormState extends Equatable {
  const BriefFormState({
    this.phase = BriefFormPhase.idle,
    this.result,
    this.failure,
  });

  final BriefFormPhase phase;
  final SubmitBriefResult? result;
  final Failure? failure;

  @override
  List<Object?> get props => [phase, result, failure];
}

class BriefFormBloc extends Bloc<BriefFormSubmitted, BriefFormState> {
  BriefFormBloc(this._repo) : super(const BriefFormState()) {
    on<BriefFormSubmitted>(_onSubmit);
  }

  final BriefRepository _repo;

  Future<void> _onSubmit(
    BriefFormSubmitted event,
    Emitter<BriefFormState> emit,
  ) async {
    emit(const BriefFormState(phase: BriefFormPhase.saving));
    try {
      int? budgetMinor;
      if (event.budgetMajor != null && event.budgetMajor!.trim().isNotEmpty) {
        final major = double.tryParse(event.budgetMajor!.trim()) ?? 0;
        budgetMinor = (major * 100).round();
      }
      final result = await _repo.submit({
        'brandId': event.brandId,
        'goals': event.goals,
        'currency': event.currency,
        if (budgetMinor != null) 'budgetMinor': budgetMinor,
        if (event.productDescription != null)
          'productDescription': event.productDescription,
        if (event.name != null) 'name': event.name,
      });
      // Invariant: never invent fee when API returns none
      if (result.managedFeeMode == 'none' && result.agencyFeeMinor != null) {
        // Still display only API values; do not invent extra fee rows
      }
      emit(BriefFormState(phase: BriefFormPhase.success, result: result));
    } on Failure catch (f) {
      emit(BriefFormState(phase: BriefFormPhase.failure, failure: f));
    }
  }
}
