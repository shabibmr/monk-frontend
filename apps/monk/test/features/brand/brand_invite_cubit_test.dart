import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/onboarding_brand/domain/repositories/brand_repository.dart';
import 'package:monk_web/features/onboarding_brand/presentation/cubit/brand_invite_cubit.dart';

class _MockBrandRepo extends Mock implements BrandRepository {}

void main() {
  late _MockBrandRepo repo;

  setUp(() {
    repo = _MockBrandRepo();
  });

  blocTest<BrandInviteCubit, BrandInviteState>(
    'accept invite happy path',
    build: () {
      when(() => repo.acceptInvite(any())).thenAnswer((_) async {});
      return BrandInviteCubit(repo);
    },
    act: (c) => c.accept('token-abc'),
    expect: () => [
      const BrandInviteState(loading: true),
      const BrandInviteState(success: true),
    ],
  );

  blocTest<BrandInviteCubit, BrandInviteState>(
    'accept invite failure',
    build: () {
      when(() => repo.acceptInvite(any())).thenThrow(
        const NotFoundFailure('Invite not found'),
      );
      return BrandInviteCubit(repo);
    },
    act: (c) => c.accept('bad'),
    expect: () => [
      const BrandInviteState(loading: true),
      isA<BrandInviteState>()
          .having((s) => s.failure, 'failure', isA<NotFoundFailure>()),
    ],
  );
}
