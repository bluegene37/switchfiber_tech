import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';

JobOrderDto job({String status = '', String? onsiteStatus}) =>
    JobOrderDto.fromJson({
      'id': 1,
      'status': status,
      'onsiteStatus': onsiteStatus,
    });

void main() {
  group('the two stages a job moves through', () {
    test('recognises Scheduled, Activated, and Completed', () {
      expect(job(status: 'Scheduled').jobStatus, JobStatus.scheduled);
      expect(job(status: 'Activated').jobStatus, JobStatus.activated);
      expect(job(status: 'Completed').jobStatus, JobStatus.completed);
    });

    test('tolerates casing and spacing from the backend', () {
      expect(job(status: 'scheduled').jobStatus, JobStatus.scheduled);
      expect(job(status: 'ACTIVATED').jobStatus, JobStatus.activated);
      expect(job(status: ' Activated ').jobStatus, JobStatus.activated);
      expect(job(status: 'completed').jobStatus, JobStatus.completed);
      expect(job(status: 'COMPLETED').jobStatus, JobStatus.completed);
      expect(job(status: ' Completed ').jobStatus, JobStatus.completed);
    });

    test('maps dispatch-ready office statuses to Scheduled', () {
      expect(job(status: 'Confirmed').jobStatus, JobStatus.scheduled);
      expect(job(status: 'Applied').jobStatus, JobStatus.scheduled);
      expect(job(status: 'Pending').jobStatus, JobStatus.scheduled);
    });

    test('folds statuses written by earlier app versions into the stages', () {
      // Still open work.
      expect(job(status: 'In Progress').jobStatus, JobStatus.scheduled);
      expect(job(status: 'inprogress').jobStatus, JobStatus.scheduled);
      // Finished legacy work.
      expect(job(status: 'Completed').jobStatus, JobStatus.completed);
    });

    test('an unknown backend status is left unmapped but readable', () {
      expect(job(status: 'Cancelled').jobStatus, isNull);
      expect(job(status: 'Cancelled').status, 'Cancelled');
    });
  });

  group('activation and terminal stages', () {
    test('Scheduled goes straight to Completed', () {
      expect(job(status: 'Scheduled').nextStatus, JobStatus.completed);
      expect(job(status: 'Confirmed').nextStatus, JobStatus.completed);
      expect(job(status: 'Scheduled').canActivate, isTrue);
    });

    test('Activated is terminal', () {
      expect(job(status: 'Activated').nextStatus, isNull);
      expect(job(status: 'Activated').canActivate, isFalse);
      expect(JobStatus.activated.next, isNull);
    });

    test('Completed is terminal', () {
      expect(job(status: 'Completed').nextStatus, isNull);
      expect(job(status: 'Completed').canActivate, isFalse);
      expect(JobStatus.completed.next, isNull);
    });

    test('sends back the exact wording the backend uses', () {
      expect(JobStatus.scheduled.wireValue, 'Scheduled');
      expect(JobStatus.activated.wireValue, 'Activated');
      expect(JobStatus.completed.wireValue, 'Completed');
    });
  });

  group('failed and rescheduled visits stay visible', () {
    test('an exception on site is surfaced regardless of job status', () {
      expect(job(status: 'Confirmed', onsiteStatus: 'Failed').siteException,
          SiteException.failed);
      expect(job(status: 'Confirmed', onsiteStatus: 'Reschedule').siteException,
          SiteException.reschedule);
    });

    test('a normal visit has no exception to flag', () {
      expect(
          job(status: 'Confirmed', onsiteStatus: 'Done').siteException, isNull);
      expect(job(status: 'Confirmed', onsiteStatus: '').siteException, isNull);
      expect(job(status: 'Confirmed').siteException, isNull);
    });
  });
}
