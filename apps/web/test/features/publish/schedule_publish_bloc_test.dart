import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monk_web/core/errors/failures.dart';
import 'package:monk_web/features/publish/domain/entities/publish_schedule.dart';
import 'package:monk_web/features/publish/domain/repositories/publish_repository.dart';
import 'package:monk_web/features/publish/presentation/bloc/schedule_publish_bloc.dart';

class _MockRepo extends Mock implements PublishRepository {}

void main() {
  late _MockRepo repo;

  final scheduledTime = DateTime(2026, 8, 1, 10, 0);

  final testSchedule = PublishSchedule(
    id: 'sched_1',
    deliverableId: 'deliv_1',
    collaborationId: 'collab_1',
    scheduledAt: scheduledTime,
    status: PublishScheduleStatus.scheduled,
    platform: 'instagram',
    approvalStatus: 'approved',
    notes: 'Publishing summer reel',
  );

  final cancelledSchedule = PublishSchedule(
    id: 'sched_1',
    deliverableId: 'deliv_1',
    collaborationId: 'collab_1',
    scheduledAt: scheduledTime,
    status: PublishScheduleStatus.cancelled,
    platform: 'instagram',
    approvalStatus: 'approved',
  );

  setUp(() {
    repo = _MockRepo();
  });

  blocTest<SchedulePublishBloc, SchedulePublishState>(
    'loads existing schedule for deliverable',
    build: () {
      when(() => repo.getSchedule('deliv_1'))
          .thenAnswer((_) async => testSchedule);
      return SchedulePublishBloc(repo);
    },
    act: (b) => b.add(const LoadScheduleRequested(
      deliverableId: 'deliv_1',
      approvalStatus: 'approved',
    )),
    expect: () => [
      const SchedulePublishState(
        deliverableId: 'deliv_1',
        approvalStatus: 'approved',
        isLoading: true,
      ),
      SchedulePublishState(
        deliverableId: 'deliv_1',
        approvalStatus: 'approved',
        isLoading: false,
        schedule: testSchedule,
      ),
    ],
  );

  blocTest<SchedulePublishBloc, SchedulePublishState>(
    'INVARIANT: rejects submission when content is NOT approved',
    build: () => SchedulePublishBloc(repo),
    act: (b) async {
      b.add(const LoadScheduleRequested(
        deliverableId: 'deliv_1',
        approvalStatus: 'pending',
      ));
      await Future<void>.delayed(Duration.zero);
      b.add(SubmitScheduleRequested(
        deliverableId: 'deliv_1',
        scheduledAt: scheduledTime,
        platform: 'instagram',
      ));
    },
    skip: 2, // skip loading state changes
    expect: () => [
      isA<SchedulePublishState>()
          .having((s) => s.failure, 'failure', isA<ValidationFailure>())
          .having((s) => s.failure?.errorCode, 'code', 'APPROVAL_REQUIRED'),
    ],
    verify: (_) {
      verifyNever(() => repo.schedulePublish(
            deliverableId: any(named: 'deliverableId'),
            scheduledAt: any(named: 'scheduledAt'),
            platform: any(named: 'platform'),
            notes: any(named: 'notes'),
          ));
    },
  );

  blocTest<SchedulePublishBloc, SchedulePublishState>(
    'allows submission when content is approved',
    build: () {
      when(() => repo.schedulePublish(
            deliverableId: 'deliv_1',
            scheduledAt: scheduledTime,
            platform: 'instagram',
            notes: 'Publishing summer reel',
          )).thenAnswer((_) async => testSchedule);
      return SchedulePublishBloc(repo);
    },
    act: (b) async {
      b.add(const LoadScheduleRequested(
        deliverableId: 'deliv_1',
        approvalStatus: 'approved',
      ));
      await Future<void>.delayed(Duration.zero);
      b.add(SubmitScheduleRequested(
        deliverableId: 'deliv_1',
        scheduledAt: scheduledTime,
        platform: 'instagram',
        notes: 'Publishing summer reel',
      ));
    },
    skip: 2,
    expect: () => [
      isA<SchedulePublishState>()
          .having((s) => s.isSubmitting, 'isSubmitting', isTrue),
      isA<SchedulePublishState>()
          .having((s) => s.isSubmitting, 'isSubmitting', isFalse)
          .having((s) => s.schedule, 'schedule', testSchedule)
          .having((s) => s.successMessage, 'msg', 'Publish schedule set successfully'),
    ],
  );

  blocTest<SchedulePublishBloc, SchedulePublishState>(
    'cancels schedule successfully',
    build: () {
      when(() => repo.cancelSchedule('sched_1'))
          .thenAnswer((_) async => cancelledSchedule);
      return SchedulePublishBloc(repo);
    },
    act: (b) => b.add(const CancelScheduleRequested('sched_1')),
    expect: () => [
      isA<SchedulePublishState>()
          .having((s) => s.isSubmitting, 'isSubmitting', isTrue),
      isA<SchedulePublishState>()
          .having((s) => s.isSubmitting, 'isSubmitting', isFalse)
          .having((s) => s.schedule, 'schedule', cancelledSchedule)
          .having((s) => s.successMessage, 'msg', 'Publish schedule cancelled'),
    ],
  );
}
