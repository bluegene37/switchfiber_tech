import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';

JobOrderDto job({String status = '', String? onsiteStatus}) =>
    JobOrderDto.fromJson({
      'id': 1,
      'status': status,
      'onsiteStatus': onsiteStatus,
    });

void main() {
  group('the job statuses the technician works with', () {
    test('recognises Scheduled, In Progress, Completed and Activated', () {
      expect(job(status: 'Scheduled').jobStatus, JobStatus.scheduled);
      expect(job(status: 'In Progress').jobStatus, JobStatus.inProgress);
      expect(job(status: 'Completed').jobStatus, JobStatus.completed);
      expect(job(status: 'Activated').jobStatus, JobStatus.activated);
    });

    test('tolerates casing and spacing from the backend', () {
      expect(job(status: 'scheduled').jobStatus, JobStatus.scheduled);
      expect(job(status: 'in progress').jobStatus, JobStatus.inProgress);
      expect(job(status: 'INPROGRESS').jobStatus, JobStatus.inProgress);
      expect(job(status: 'in-progress').jobStatus, JobStatus.inProgress);
      expect(job(status: ' Completed ').jobStatus, JobStatus.completed);
    });

    test('maps dispatch-ready statuses to scheduled', () {
      expect(job(status: 'Confirmed').jobStatus, JobStatus.scheduled);
      expect(job(status: 'Applied').jobStatus, JobStatus.scheduled);
      expect(job(status: 'Pending').jobStatus, JobStatus.scheduled);
    });

    test('the raw status is still readable for display under All', () {
      expect(job(status: 'Confirmed').status, 'Confirmed');
    });
  });

  group('advancing a job through the workflow', () {
    test('Scheduled advances to In Progress', () {
      expect(job(status: 'Scheduled').nextStatus, JobStatus.inProgress);
      expect(job(status: 'Confirmed').nextStatus, JobStatus.inProgress);
      expect(job(status: 'Applied').nextStatus, JobStatus.inProgress);
    });

    test('runs In Progress -> Completed -> Activated', () {
      expect(job(status: 'In Progress').nextStatus, JobStatus.completed);
      expect(job(status: 'Completed').nextStatus, JobStatus.activated);
    });

    test('Activated is terminal and does not cycle back around', () {
      expect(job(status: 'Activated').nextStatus, isNull);
    });

    test('sends back the exact wording the backend uses', () {
      expect(JobStatus.inProgress.wireValue, 'In Progress');
      expect(JobStatus.completed.wireValue, 'Completed');
      expect(JobStatus.activated.wireValue, 'Activated');
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
      expect(
          job(status: 'In Progress', onsiteStatus: 'In Progress').siteException,
          isNull);
      expect(job(status: 'Confirmed', onsiteStatus: '').siteException, isNull);
      expect(job(status: 'Confirmed').siteException, isNull);
    });
  });
}
