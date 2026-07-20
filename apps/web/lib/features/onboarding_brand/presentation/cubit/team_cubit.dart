import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';

class TeamState extends Equatable {
  const TeamState({
    this.loading = false,
    this.members = const [],
    this.failure,
    this.devInviteToken,
    this.infoMessage,
  });

  final bool loading;
  final List<BrandMember> members;
  final Failure? failure;
  final String? devInviteToken;
  final String? infoMessage;

  TeamState copyWith({
    bool? loading,
    List<BrandMember>? members,
    Failure? failure,
    String? devInviteToken,
    String? infoMessage,
    bool clearFailure = false,
  }) {
    return TeamState(
      loading: loading ?? this.loading,
      members: members ?? this.members,
      failure: clearFailure ? null : (failure ?? this.failure),
      devInviteToken: devInviteToken ?? this.devInviteToken,
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }

  @override
  List<Object?> get props =>
      [loading, members, failure, devInviteToken, infoMessage];
}

class TeamCubit extends Cubit<TeamState> {
  TeamCubit(this._repo, this.brandId) : super(const TeamState());

  final BrandRepository _repo;
  final String brandId;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final members = await _repo.listMembers(brandId);
      emit(state.copyWith(loading: false, members: members));
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> invite({
    required String email,
    required String memberRole,
    required List<String> permissions,
  }) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final res = await _repo.inviteMember(
        brandId: brandId,
        email: email,
        memberRole: memberRole,
        permissions: permissions,
      );
      final members = await _repo.listMembers(brandId);
      emit(
        state.copyWith(
          loading: false,
          members: members,
          devInviteToken: res.inviteTokenDev,
          infoMessage: 'Invite sent',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }

  Future<void> revoke(String memberId) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      await _repo.removeMember(brandId: brandId, memberId: memberId);
      await load();
    } on Failure catch (f) {
      emit(state.copyWith(loading: false, failure: f));
    }
  }
}
