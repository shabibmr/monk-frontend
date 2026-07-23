import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/brief.dart';
import '../../domain/repositories/brief_repository.dart';

class BriefListState extends Equatable {
  const BriefListState({
    this.loading = false,
    this.items = const [],
    this.failure,
  });

  final bool loading;
  final List<Brief> items;
  final Failure? failure;

  @override
  List<Object?> get props => [loading, items, failure];
}

class BriefListCubit extends Cubit<BriefListState> {
  BriefListCubit(this._repo) : super(const BriefListState());
  final BriefRepository _repo;

  Future<void> load() async {
    emit(const BriefListState(loading: true));
    try {
      final items = await _repo.listMine();
      emit(BriefListState(items: items));
    } on Failure catch (f) {
      emit(BriefListState(failure: f));
    }
  }
}
