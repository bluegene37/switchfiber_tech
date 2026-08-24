import 'package:signals_flutter/signals_flutter.dart';
import '../../jobs/models/job_order_model.dart';
import '../../jobs/repositories/job_repository.dart';

/// Reactive form state for On-Site Completion Reports.
class ReportSignals {
  final selectedJobOrder = signal<JobOrderDto?>(null);
  final opticalPower = signal<double>(-19.5);
  final routerSerial = signal<String>('HWTC8829104');
  final routerModel = signal<String>('Huawei HG8145V5');
  final napPort = signal<String>('Port 2');
  final remarks = signal<String>('Fiber drop cable installed. Power verified. Client speedtest 100Mbps symmetrical.');
  final boxPhotoAttached = signal<bool>(true);
  final routerPhotoAttached = signal<bool>(true);
  final hasSignature = signal<bool>(true);
  final isSubmitting = signal<bool>(false);
  final submissionMessage = signal<String?>(null);

  // Computeds
  late final ReadonlySignal<bool> isFormValid = computed(() {
    return selectedJobOrder.value != null &&
        routerSerial.value.trim().isNotEmpty &&
        hasSignature.value;
  });

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
  }

  /// Submit report locally into Drift and initiate background sync
  Future<bool> submitReport(JobRepository repository) async {
    final job = selectedJobOrder.value;
    if (job == null) return false;

    isSubmitting.value = true;
    submissionMessage.value = null;

    try {
      await repository.saveCompletionReport(
        id: job.id,
        status: 'completed',
        onsiteStatus: 'Completed',
        onsiteRemarks: remarks.value.trim(),
        opticalPower: opticalPower.value,
        modemRouterSN: routerSerial.value.trim(),
        routerModel: routerModel.value.trim(),
        boxReadingImage: boxPhotoAttached.value ? 'data:image/jpeg;base64,mock_box_reading' : null,
        routerReadingImage: routerPhotoAttached.value ? 'data:image/jpeg;base64,mock_router_reading' : null,
        clientSignature: hasSignature.value ? 'data:image/png;base64,mock_signature' : null,
      );

      submissionMessage.value = 'Completion report saved to Drift SQLite & queued for sync!';
      return true;
    } catch (e) {
      submissionMessage.value = 'Failed to save report: $e';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Reset form state
  void reset() {
    selectedJobOrder.value = null;
    opticalPower.value = -19.5;
    routerSerial.value = '';
    remarks.value = '';
    hasSignature.value = false;
    boxPhotoAttached.value = false;
    routerPhotoAttached.value = false;
    submissionMessage.value = null;
  }
}
