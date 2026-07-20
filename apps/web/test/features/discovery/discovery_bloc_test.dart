import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/features/discovery/domain/entities/discovery.dart';
import 'package:monk_web/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:monk_web/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:monk_web/features/discovery/presentation/cubit/shortlist_cubit.dart';

class _MockRepo extends Mock implements DiscoveryRepository {}

void main() {
  late _MockRepo repo;

  const creator = DiscoveryInfluencer(
    id: 'p1',
    displayName: 'Asha',
    country: 'IN',
  );

  setUp(() {
    repo = _MockRepo();
    registerFallbackValue(const DiscoveryFilters());
  });

  blocTest<DiscoveryBloc, DiscoveryState>(
    'loads discovery results',
    build: () {
      when(() => repo.search(any(), cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => (items: [creator], nextCursor: null),
      );
      return DiscoveryBloc(repo, debounce: Duration.zero);
    },
    act: (b) => b.add(const DiscoveryStarted()),
    expect: () => [
      isA<DiscoveryState>()
          .having((s) => s.phase, 'phase', DiscoveryPhase.loading),
      isA<DiscoveryState>()
          .having((s) => s.phase, 'phase', DiscoveryPhase.ready)
          .having((s) => s.items.length, 'len', 1),
    ],
  );

  blocTest<DiscoveryBloc, DiscoveryState>(
    'debounce query still searches',
    build: () {
      when(() => repo.search(any(), cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => (items: [creator], nextCursor: null),
      );
      return DiscoveryBloc(repo, debounce: const Duration(milliseconds: 10));
    },
    act: (b) async {
      b.add(const DiscoveryQueryChanged('ash'));
      await Future<void>.delayed(const Duration(milliseconds: 30));
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<DiscoveryState>()
          .having((s) => s.filters.q, 'q', 'ash'),
      isA<DiscoveryState>()
          .having((s) => s.phase, 'phase', DiscoveryPhase.loading),
      isA<DiscoveryState>()
          .having((s) => s.phase, 'phase', DiscoveryPhase.ready),
    ],
  );

  blocTest<DiscoveryBloc, DiscoveryState>(
    'empty results stay ready',
    build: () {
      when(() => repo.search(any(), cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => (items: <DiscoveryInfluencer>[], nextCursor: null),
      );
      return DiscoveryBloc(repo, debounce: Duration.zero);
    },
    act: (b) => b.add(const DiscoveryStarted()),
    expect: () => [
      isA<DiscoveryState>()
          .having((s) => s.phase, 'phase', DiscoveryPhase.loading),
      isA<DiscoveryState>()
          .having((s) => s.phase, 'phase', DiscoveryPhase.ready)
          .having((s) => s.items, 'items', isEmpty),
    ],
  );

  blocTest<ShortlistCubit, ShortlistState>(
    'add and remove shortlist items',
    build: () {
      when(() => repo.listShortlists('b1')).thenAnswer(
        (_) async => [const Shortlist(id: 's1', name: 'Q1')],
      );
      when(() => repo.listItems('b1', 's1')).thenAnswer(
        (_) async => const [
          ShortlistItem(id: 'i1', influencerProfileId: 'p1'),
        ],
      );
      when(
        () => repo.addItem(
          brandId: any(named: 'brandId'),
          shortlistId: any(named: 'shortlistId'),
          influencerProfileId: any(named: 'influencerProfileId'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => repo.removeItem(
          brandId: any(named: 'brandId'),
          shortlistId: any(named: 'shortlistId'),
          itemId: any(named: 'itemId'),
        ),
      ).thenAnswer((_) async {});
      return ShortlistCubit(repo, 'b1');
    },
    act: (c) async {
      await c.load();
      await c.addInfluencer('p2');
      await c.removeItem('i1');
    },
    verify: (_) {
      verify(
        () => repo.addItem(
          brandId: 'b1',
          shortlistId: 's1',
          influencerProfileId: 'p2',
        ),
      ).called(1);
      verify(
        () => repo.removeItem(
          brandId: 'b1',
          shortlistId: 's1',
          itemId: 'i1',
        ),
      ).called(1);
    },
  );
}
