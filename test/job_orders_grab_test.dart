import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';

void main() {
  group('Job Order Status Helpers & Grab Transitions', () {
    test('Identifies scheduled jobs and grab eligibility', () {
      final scheduledJob = JobOrderDto(
        id: 201,
        ticketNumber: 'SF-2026-TEST1',
        customerName: 'Juan Dela Cruz',
        address: '123 Rizal St.',
        status: 'scheduled',
      );

      expect(scheduledJob.jobStatus, JobStatus.scheduled);
      expect(scheduledJob.isScheduled, isTrue);
      expect(scheduledJob.isInProgress, isFalse);
      expect(scheduledJob.canGrab, isTrue);
      expect(scheduledJob.nextStatus, JobStatus.inProgress);
    });

    test('Identifies in-progress jobs', () {
      final inProgressJob = JobOrderDto(
        id: 202,
        ticketNumber: 'SF-2026-TEST2',
        customerName: 'Maria Clara',
        address: '456 Ibarra Ave.',
        status: 'inprogress',
      );

      expect(inProgressJob.jobStatus, JobStatus.inProgress);
      expect(inProgressJob.isScheduled, isFalse);
      expect(inProgressJob.isInProgress, isTrue);
      expect(inProgressJob.canGrab, isFalse);
      expect(inProgressJob.nextStatus, JobStatus.completed);
    });

    test('Terminal activated status does not advance further', () {
      final activatedJob = JobOrderDto(
        id: 203,
        ticketNumber: 'SF-2026-TEST3',
        customerName: 'Crisostomo Ibarra',
        address: '789 San Diego St.',
        status: 'activated',
      );

      expect(activatedJob.jobStatus, JobStatus.activated);
      expect(activatedJob.isActivated, isTrue);
      expect(activatedJob.nextStatus, isNull);
    });
  });
}
