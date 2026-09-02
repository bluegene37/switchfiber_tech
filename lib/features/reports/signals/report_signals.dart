import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/utils/data_url.dart';
import '../../jobs/models/job_order_model.dart';
import '../../jobs/repositories/job_repository.dart';

/// Reactive form state for On-Site Completion Reports.
class ReportSignals {
  final selectedJobOrder = signal<JobOrderDto?>(null);
  final opticalPower = signal<double>(-19.5);
  final routerSerial = signal<String>('HWTC8829104');
  final routerModel = signal<String>('Huawei HG8145V5');
  final napPort = signal<String>('Port 2');
  final remarks = signal<String>(
      'Fiber drop cable installed. Power verified. Client speedtest 100Mbps symmetrical.');

  /// Photo proofs by field, as data URLs. A missing key means untouched (the
  /// server's value stands); an empty string means the technician removed it.
  final photos = signal<Map<JobPhoto, String>>(const {});

  /// The subscriber's signature as a PNG data URL, or null when not captured.
  final signature = signal<String?>(null);

  final isSubmitting = signal<bool>(false);
  final submissionMessage = signal<String?>(null);

  // Computeds
  late final ReadonlySignal<bool> hasSignature =
      computed(() => DataUrl.isDataUrl(signature.value));

  late final ReadonlySignal<int> attachedPhotoCount = computed(
    () => photos.value.values.where((v) => v.trim().isNotEmpty).length,
  );

  late final ReadonlySignal<bool> isFormValid = computed(() {
    return selectedJobOrder.value != null &&
        routerSerial.value.trim().isNotEmpty &&
        hasSignature.value;
  });

  /// The photo currently held for [photo]: this session's capture, else what
  /// the job already carries.
  String? photoFor(JobPhoto photo) {
    final session = photos.value[photo];
    if (session != null) return session.isEmpty ? null : session;
    return selectedJobOrder.value?.imageFor(photo);
  }

  void setPhoto(JobPhoto photo, String? dataUrl) {
    photos.value = {...photos.value, photo: dataUrl ?? ''};
  }

  void setSignature(String? dataUrl) {
    signature.value = dataUrl;
  }

  /// Pre-fill report form with selected Job Order data
  void setJobOrder(JobOrderDto job) {
    selectedJobOrder.value = job;
    opticalPower.value = job.opticalPower ?? -19.5;
    if (job.modemRouterSN != null && job.modemRouterSN!.isNotEmpty) {
      routerSerial.value = job.modemRouterSN!;
    }
    if (job.routerModel != null && job.routerModel!.isNotEmpty) {
      routerModel.value = job.routerModel!;
    }
    if (job.portId != null && job.portId!.isNotEmpty) {
      napPort.value = job.portId!;
    }
    // Start from what the job already carries; a fresh capture replaces it.
    photos.value = const {};
    signature.value = job.hasSignature ? job.clientSignature : null;
  }

  /// Submit report locally into Drift and initiate background sync.
  ///
  /// A completion report is how a job gets Activated with full detail, so it
  /// also stamps the technician who did the work.
  Future<bool> submitReport(JobRepository repository,
      {String? technicianEmail}) async {
    final job = selectedJobOrder.value;
    if (job == null) return false;

    isSubmitting.value = true;
    submissionMessage.value = null;

    try {
      await repository.saveCompletionReport(
        id: job.id,
        status: JobStatus.activated.wireValue,
        onsiteStatus: 'Done',
        onsiteRemarks: remarks.value.trim(),
        opticalPower: opticalPower.value,
        modemRouterSN: routerSerial.value.trim(),
        routerModel: routerModel.value.trim(),
        boxReadingImage: _finalPhoto(job, JobPhoto.boxReading),
        routerReadingImage: _finalPhoto(job, JobPhoto.routerReading),
        setupImage: _finalPhoto(job, JobPhoto.setup),
        speedtestImage: _finalPhoto(job, JobPhoto.speedtest),
        portLabelImage: _finalPhoto(job, JobPhoto.portLabel),
        signedContractImage: _finalPhoto(job, JobPhoto.signedContract),
        houseFront: _finalPhoto(job, JobPhoto.houseFront),
        clientSignature: signature.value ?? job.clientSignature,
        assignedEmail: (technicianEmail?.trim().isEmpty ?? true)
            ? null
            : technicianEmail!.trim(),
      );

      submissionMessage.value =
          'Completion report saved to Drift SQLite & queued for sync!';
      return true;
    } catch (e) {
      submissionMessage.value = 'Failed to save report: $e';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// What gets written for [photo]: the session's capture or removal when
  /// there is one, otherwise the job's existing value untouched.
  String? _finalPhoto(JobOrderDto job, JobPhoto photo) =>
      photos.value[photo] ?? job.imageFor(photo);

  /// Reset form state
  void reset() {
    selectedJobOrder.value = null;
    opticalPower.value = -19.5;
    routerSerial.value = '';
    remarks.value = '';
    signature.value = null;
    photos.value = const {};
    submissionMessage.value = null;
  }
}
