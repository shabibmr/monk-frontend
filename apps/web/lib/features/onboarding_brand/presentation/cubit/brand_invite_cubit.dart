import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/brand_repository.dart';

class BrandInviteState extends Equatable {
  const BrandInviteState({
    this.loading = false,
    this.success = false,
    this.failure,
  });

  final bool loading;
  final bool success;
  final Failure? failure;

  @override
  List<Object?> get props => [loading, success, failure];
}

class BrandInviteCubit extends Cubit<BrandInviteState> {
  BrandInviteCubit(this._repo) : super(const BrandInviteState());

  final BrandRepository _repo;

  Future<void> accept(String token) async {
    emit(const BrandInviteState(loading: true));
    try {
      await _repo.acceptInvite(token);
      emit(const BrandInviteState(success: true));
    } on Failure catch (f) {
      emit(BrandInviteState(failure: f));
    }
  }
}
