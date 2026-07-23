import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/kyc.dart';
import '../../domain/repositories/kyc_repository.dart';

sealed class KycEvent extends Equatable {
  const KycEvent();
  @override
  List<Object?> get props => [];
}

class KycLoadRequested extends KycEvent {
  const KycLoadRequested({
    required this.profileId,
    this.country,
  });
  final String profileId;
  final String? country;
  @override
  List<Object?> get props => [profileId, country];
}

class KycSubmitted extends KycEvent {
  const KycSubmitted({
    this.identityDocFileId,
    this.accountNumber,
    this.ifsc,
    this.iban,
    this.panNumber,
    this.gstRegistered,
    this.gstNumber,
    this.uaeLicenseNumber,
    this.uaeDocFileId,
    this.uaeAuthority,
    this.uaeExpiryDate,
  });

  final String? identityDocFileId;
  final String? accountNumber;
  final String? ifsc;
  final String? iban;
  final String? panNumber;
  final bool? gstRegistered;
  final String? gstNumber;
  final String? uaeLicenseNumber;
  final String? uaeDocFileId;
  final String? uaeAuthority;
  final String? uaeExpiryDate;
}

enum KycPhase { loading, ready, saving, failure, submitted }

class KycState extends Equatable {
  const KycState({
    this.phase = KycPhase.loading,
    this.profileId,
    this.country,
    this.records = const [],
    this.licenses = const [],
    this.failure,
    this.infoMessage,
  });

  final KycPhase phase;
  final String? profileId;
  final String? country;
  final List<KycRecord> records;
  final List<MediaLicense> licenses;
  final Failure? failure;
  final String? infoMessage;

  bool get showIndia => showIndiaFields(country);
  bool get showUae => showUaeLicenseFields(country);

  KycState copyWith({
    KycPhase? phase,
    String? profileId,
    String? country,
    List<KycRecord>? records,
    List<MediaLicense>? licenses,
    Failure? failure,
    String? infoMessage,
    bool clearFailure = false,
  }) {
    return KycState(
      phase: phase ?? this.phase,
      profileId: profileId ?? this.profileId,
      country: country ?? this.country,
      records: records ?? this.records,
      licenses: licenses ?? this.licenses,
      failure: clearFailure ? null : (failure ?? this.failure),
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }

  @override
  List<Object?> get props =>
      [phase, profileId, country, records, licenses, failure, infoMessage];
}

class KycBloc extends Bloc<KycEvent, KycState> {
  KycBloc(this._repo) : super(const KycState()) {
    on<KycLoadRequested>(_onLoad);
    on<KycSubmitted>(_onSubmit);
  }

  final KycRepository _repo;

  Future<void> _onLoad(KycLoadRequested event, Emitter<KycState> emit) async {
    emit(
      state.copyWith(
        phase: KycPhase.loading,
        profileId: event.profileId,
        country: event.country,
        clearFailure: true,
      ),
    );
    try {
      final res = await _repo.getMyKyc(event.profileId);
      emit(
        state.copyWith(
          phase: KycPhase.ready,
          records: res.records,
          licenses: res.licenses,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: KycPhase.failure, failure: f));
    }
  }

  Future<void> _onSubmit(KycSubmitted event, Emitter<KycState> emit) async {
    final profileId = state.profileId;
    if (profileId == null) return;
    emit(state.copyWith(phase: KycPhase.saving, clearFailure: true));
    try {
      await _repo.submit(
        profileId: profileId,
        identityDocFileId: event.identityDocFileId,
        accountNumber: event.accountNumber,
        ifsc: event.ifsc,
        iban: event.iban,
        panNumber: event.panNumber,
        gstRegistered: event.gstRegistered,
        gstNumber: event.gstNumber,
        uaeLicenseNumber: event.uaeLicenseNumber,
        uaeDocFileId: event.uaeDocFileId,
        uaeAuthority: event.uaeAuthority,
        uaeExpiryDate: event.uaeExpiryDate,
      );
      final res = await _repo.getMyKyc(profileId);
      emit(
        state.copyWith(
          phase: KycPhase.submitted,
          records: res.records,
          licenses: res.licenses,
          infoMessage: 'KYC submitted for review',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(phase: KycPhase.failure, failure: f));
    }
  }
}
