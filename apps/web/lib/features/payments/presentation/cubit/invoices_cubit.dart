import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class InvoicesState extends Equatable {
  const InvoicesState({
    this.loading = false,
    this.items = const [],
    this.selected,
    this.failure,
  });

  final bool loading;
  final List<Invoice> items;
  final Invoice? selected;
  final Failure? failure;

  InvoicesState copyWith({
    bool? loading,
    List<Invoice>? items,
    Invoice? selected,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return InvoicesState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      selected: selected ?? this.selected,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [loading, items, selected, failure];
}

class InvoicesCubit extends Cubit<InvoicesState> {
  InvoicesCubit(this._repo) : super(const InvoicesState());
  final PaymentRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final items = await _repo.listInvoices();
      emit(state.copyWith(loading: false, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> open(String id) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final inv = await _repo.getInvoice(id);
      emit(state.copyWith(loading: false, selected: inv));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }
}
