import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../jobs/models/job_order_model.dart';
import '../../jobs/signals/jobs_signals.dart';
import '../signals/report_signals.dart';
import '../widgets/optical_power_gauge.dart';

/// On-Site Completion Report form screen for optical power validation and subscriber sign-off.
class CreateReportScreen extends StatefulWidget {
  final JobsSignals jobsSignals;
  final ReportSignals reportSignals;
  final VoidCallback? onReportSubmitted;

  const CreateReportScreen({
    super.key,
    required this.jobsSignals,
    required this.reportSignals,
    this.onReportSubmitted,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serialController;
  late final TextEditingController _remarksController;
  late final TextEditingController _dbmController;

  @override
  void initState() {
    super.initState();
    final rep = widget.reportSignals;
    _serialController = TextEditingController(text: rep.routerSerial.value);
    _remarksController = TextEditingController(text: rep.remarks.value);
    _dbmController =
        TextEditingController(text: rep.opticalPower.value.toStringAsFixed(1));

    // Auto-select first available job order if none selected
    if (rep.selectedJobOrder.value == null &&
        widget.jobsSignals.allJobs.value.isNotEmpty) {
      rep.setJobOrder(widget.jobsSignals.allJobs.value.first);
      _serialController.text = rep.routerSerial.value;
      _dbmController.text = rep.opticalPower.value.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    _remarksController.dispose();
    _dbmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final rep = widget.reportSignals;
    rep.routerSerial.value = _serialController.text.trim();
    rep.remarks.value = _remarksController.text.trim();

    final success = await rep.submitReport(widget.jobsSignals.repository);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rep.submissionMessage.value ??
                      'Report submitted successfully!',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      widget.onReportSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rep = widget.reportSignals;
    final jobs = widget.jobsSignals;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Field Completion Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Optical calibration & subscriber hand-off',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Target Job Order Selector
              _buildJobOrderSelector(jobs, rep),
              const SizedBox(height: 16),

              // 2. Optical Power Reading Gauge & Input
              _buildOpticalPowerSection(rep),
              const SizedBox(height: 16),

              // 3. Hardware & Port Details
              _buildHardwareSection(rep),
              const SizedBox(height: 16),

              // 4. Photo Proof Attachments
              _buildPhotoProofSection(rep),
              const SizedBox(height: 16),

              // 5. On-site Remarks
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Technician On-Site Remarks',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Enter fiber splice details, cable distance, speedtest results...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 6. Customer Electronic Sign-Off
              _buildCustomerSignOffSection(rep),
              const SizedBox(height: 24),

              // Submit Button
              SignalBuilder(
                builder: (context) {
                  final submitting = rep.isSubmitting.value;
                  final valid = rep.isFormValid.value;

                  return ElevatedButton(
                    onPressed: submitting || !valid ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Save Report & Mark Completed',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobOrderSelector(JobsSignals jobs, ReportSignals rep) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Select Target Job Order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SignalBuilder(
              builder: (context) {
                final jobList = jobs.allJobs.value;
                final selected = rep.selectedJobOrder.value;

                if (jobList.isEmpty) {
                  return const Text(
                    'No job orders available.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  );
                }

                return DropdownButtonFormField<JobOrderDto>(
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  items: jobList.map((j) {
                    return DropdownMenuItem<JobOrderDto>(
                      value: j,
                      child: Text(
                        '${j.ticketNumber} — ${j.customerName} (${j.address})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (newJob) {
                    if (newJob != null) {
                      rep.setJobOrder(newJob);
                      _serialController.text = rep.routerSerial.value;
                      _dbmController.text =
                          rep.opticalPower.value.toStringAsFixed(1);
                    }
                  },
                  validator: (val) =>
                      val == null ? 'Please select a job order' : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpticalPowerSection(ReportSignals rep) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.speed_rounded, size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Optical Power Meter Reading (dBm)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live Quality Gauge
            SignalBuilder(
              builder: (context) {
                return OpticalPowerGauge(
                    opticalPowerDbm: rep.opticalPower.value);
              },
            ),

            const SizedBox(height: 16),

            // Slider & Manual Text Input Row
            Row(
              children: [
                Expanded(
                  child: SignalBuilder(
                    builder: (context) {
                      final dbm = rep.opticalPower.value;
                      return Slider(
                        value: dbm,
                        min: -35.0,
                        max: -8.0,
                        divisions: 54,
                        activeColor: AppTheme.primary,
                        onChanged: (val) {
                          rep.opticalPower.value =
                              double.parse(val.toStringAsFixed(1));
                          _dbmController.text = val.toStringAsFixed(1);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    controller: _dbmController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      suffixText: 'dBm',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed >= -40 && parsed <= 0) {
                        rep.opticalPower.value = parsed;
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHardwareSection(ReportSignals rep) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.router_rounded, size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Hardware & Terminal Assignment',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Router SN
            TextFormField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: 'Modem / ONT Serial Number (SN)',
                prefixIcon: Icon(Icons.qr_code_scanner_rounded, size: 20),
                hintText: 'e.g. HWTC12345678 or ZTE8839001',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter modem/router serial number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Router Model & Port Row
            Row(
              children: [
                Expanded(
                  child: SignalBuilder(
                    builder: (context) {
                      final models = [
                        'Huawei HG8145V5',
                        'Huawei EG8145V5',
                        'ZTE F670L',
                        'FiberHome AN5506',
                      ];
                      return DropdownButtonFormField<String>(
                        initialValue: models.contains(rep.routerModel.value)
                            ? rep.routerModel.value
                            : models.first,
                        decoration: const InputDecoration(
                          labelText: 'ONT Model',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: models.map((m) {
                          return DropdownMenuItem(
                              value: m,
                              child: Text(m,
                                  style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) rep.routerModel.value = val;
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SignalBuilder(
                    builder: (context) {
                      final ports = [
                        'Port 1',
                        'Port 2',
                        'Port 3',
                        'Port 4',
                        'Port 5',
                        'Port 6',
                        'Port 7',
                        'Port 8',
                      ];
                      return DropdownButtonFormField<String>(
                        initialValue: ports.contains(rep.napPort.value)
                            ? rep.napPort.value
                            : ports.first,
                        decoration: const InputDecoration(
                          labelText: 'NAP Port',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: ports.map((p) {
                          return DropdownMenuItem(
                              value: p,
                              child: Text(p,
                                  style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) rep.napPort.value = val;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoProofSection(ReportSignals rep) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.camera_alt_outlined,
                    size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'On-Site Photo Proofs',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SignalBuilder(
                    builder: (context) {
                      final attached = rep.boxPhotoAttached.value;
                      return _buildPhotoTile(
                        label: 'NAP Box Reading',
                        isAttached: attached,
                        onToggle: () {
                          rep.boxPhotoAttached.value = !attached;
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SignalBuilder(
                    builder: (context) {
                      final attached = rep.routerPhotoAttached.value;
                      return _buildPhotoTile(
                        label: 'ONT Rx Reading',
                        isAttached: attached,
                        onToggle: () {
                          rep.routerPhotoAttached.value = !attached;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile({
    required String label,
    required bool isAttached,
    required VoidCallback onToggle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAttached
              ? (isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg)
              : (isDark ? AppTheme.darkInput : AppTheme.lightBg),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAttached
                ? AppTheme.primary
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: isAttached ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isAttached
                  ? Icons.check_circle_rounded
                  : Icons.add_a_photo_outlined,
              size: 26,
              color: isAttached
                  ? AppTheme.primary
                  : (isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isAttached ? FontWeight.w700 : FontWeight.w500,
                color: isAttached
                    ? (isDark
                        ? const Color(0xFFFF8591)
                        : AppTheme.primaryActive)
                    : (isDark ? Colors.white : AppTheme.darkSlate),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isAttached ? 'Attached ✓' : 'Tap to attach',
              style: TextStyle(
                fontSize: 10,
                color: isAttached
                    ? AppTheme.primary
                    : (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSignOffSection(ReportSignals rep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.draw_rounded, size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Customer Sign-Off & Acceptance',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Subscriber acknowledges proper optical installation and functional internet connectivity.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            SignalBuilder(
              builder: (context) {
                final signed = rep.hasSignature.value;
                return Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: signed
                        ? (isDark
                            ? const Color(0xFF059669).withValues(alpha: 0.25)
                            : AppTheme.successSubtle)
                        : (isDark ? AppTheme.darkInput : AppTheme.lightBg),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: signed
                          ? (isDark
                              ? const Color(0xFF059669).withValues(alpha: 0.4)
                              : AppTheme.success)
                          : (isDark
                              ? AppTheme.borderDark
                              : AppTheme.borderLight),
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      rep.hasSignature.value = !signed;
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            signed
                                ? Icons.verified_rounded
                                : Icons.touch_app_rounded,
                            color: signed
                                ? (isDark
                                    ? const Color(0xFF4ADE80)
                                    : AppTheme.success)
                                : (isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textMuted),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            signed
                                ? 'Signature Captured & Verified (Tap to clear)'
                                : 'Tap to Capture Subscriber Signature',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: signed
                                  ? (isDark
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFF166534))
                                  : (isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
