import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/utils/data_url.dart';
import '../../jobs/models/job_order_model.dart';
import '../../jobs/repositories/job_repository.dart';

/// Reactive form state for On-Site Completion Reports.
class ReportSignals {
  final selectedJobOrder = signal<JobOrderDto?>(null);
  final opticalPower = signal<double>(-19.5);
  final routerSerial = signal<String>('');
  final routerModel = signal<String>('Huawei 5v5');
  final napPort = signal<String>('PORT 001');
  final nap = signal<String?>(null);
  final remarks = signal<String>('');

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
    routerSerial.value = job.modemRouterSN ?? '';
    if (job.routerModel != null && job.routerModel!.isNotEmpty) {
      routerModel.value = job.routerModel!;
    } else {
      routerModel.value = 'Huawei 5v5';
    }
    if (job.portId != null && job.portId!.isNotEmpty) {
      napPort.value = job.portId!;
    } else {
      napPort.value = 'PORT 001';
    }
    if (job.nap != null && job.nap!.isNotEmpty) {
      nap.value = job.nap;
    } else if (job.napId != null) {
      nap.value = 'NAP-${job.napId}';
    } else {
      nap.value = null;
    }
    remarks.value = job.onsiteRemarks ?? '';
    // Start from what the job already carries; a fresh capture replaces it.
    photos.value = const {};
    signature.value = job.hasSignature ? job.clientSignature : null;
  }

  /// Submit report locally into Drift and initiate background sync.
  ///
  /// Saves on-site measurements, photos and signature without automatically
  /// updating the Job Order status. The job is marked Completed by the
  /// technician via the "Complete" action on the Job Order details screen.
  Future<bool> submitReport(JobRepository repository,
      {String? technicianEmail}) async {
    final job = selectedJobOrder.value;
    if (job == null) return false;

    isSubmitting.value = true;
    submissionMessage.value = null;

    try {
      await repository.saveCompletionReport(
        id: job.id,
        onsiteStatus: 'Done',
        onsiteRemarks: remarks.value.trim(),
        opticalPower: opticalPower.value,
        modemRouterSN: routerSerial.value.trim(),
        routerModel: routerModel.value.trim(),
        nap: nap.value?.trim(),
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
    routerModel.value = 'Huawei 5v5';
    napPort.value = 'PORT 001';
    remarks.value = '';
    nap.value = null;
    signature.value = null;
    photos.value = const {};
    submissionMessage.value = null;
  }
}
