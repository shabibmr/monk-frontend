import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.loading = false,
    this.brand,
    this.profile,
    this.manager,
    this.failure,
  });

  final bool loading;
  final BrandDashboard? brand;
  final ProfileDashboard? profile;
  final ManagerDashboard? manager;
  final Failure? failure;

  DashboardState copyWith({
    bool? loading,
    BrandDashboard? brand,
    ProfileDashboard? profile,
    ManagerDashboard? manager,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      brand: brand ?? this.brand,
      profile: profile ?? this.profile,
      manager: manager ?? this.manager,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [loading, brand, profile, manager, failure];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repo) : super(const DashboardState());
  final DashboardRepository _repo;

  Future<void> loadBrand(String brandId) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final d = await _repo.brandDashboard(brandId);
      emit(state.copyWith(loading: false, brand: d));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> loadProfile(String profileId) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final d = await _repo.profileDashboard(profileId);
      emit(state.copyWith(loading: false, profile: d));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> loadManager() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final d = await _repo.managerDashboard();
      emit(state.copyWith(loading: false, manager: d));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }
}
