import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/services/image_capture_service.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/data_url.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../catalogs/models/catalog_model.dart';
import '../../catalogs/services/catalog_service.dart';
import '../../jobs/models/job_order_model.dart';
import '../../jobs/signals/jobs_signals.dart';
import '../signals/report_signals.dart';
import '../widgets/optical_power_gauge.dart';
import '../widgets/photo_capture_tile.dart';
import '../widgets/signature_pad.dart';

/// On-Site Completion Report form screen for optical power validation and subscriber sign-off.
class CreateReportScreen extends StatefulWidget {
  final JobsSignals jobsSignals;
  final ReportSignals reportSignals;

  /// Photo source; injected so tests can hand over an image without a camera.
  final Future<String?> Function(ImageSource source)? pickImage;
  final VoidCallback? onReportSubmitted;

  const CreateReportScreen({
    super.key,
    required this.jobsSignals,
    required this.reportSignals,
    this.onReportSubmitted,
    this.pickImage,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hardwareSectionKey = GlobalKey();
  final _signOffSectionKey = GlobalKey();
  final _signatureController = SignatureController();
  late final TextEditingController _serialController;
  late final TextEditingController _remarksController;
  late final TextEditingController _dbmController;
  List<RouterDto> _availableRouters = CatalogService.fallbackRouters;
  List<NapDto> _availableNaps = CatalogService.fallbackNaps;

  @override
  void initState() {
    super.initState();
    final rep = widget.reportSignals;
    _serialController = TextEditingController(text: rep.routerSerial.value);
    _remarksController = TextEditingController(text: rep.remarks.value);
    _dbmController =
        TextEditingController(text: rep.opticalPower.value.toStringAsFixed(1));

    _loadCatalog();

    // Auto-select first available job order if none selected
    if (rep.selectedJobOrder.value == null &&
        widget.jobsSignals.allJobs.value.isNotEmpty) {
      rep.setJobOrder(widget.jobsSignals.allJobs.value.first);
      _serialController.text = rep.routerSerial.value;
      _dbmController.text = rep.opticalPower.value.toStringAsFixed(1);
    }
  }

  Future<void> _loadCatalog() async {
    final routersFuture = CatalogService.instance.getRouters();
    final napsFuture = CatalogService.instance.getNaps();
    final results = await Future.wait([routersFuture, napsFuture]);
    if (!mounted) return;
    setState(() {
      _availableRouters = results[0] as List<RouterDto>;
      _availableNaps = results[1] as List<NapDto>;
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _serialController.dispose();
    _remarksController.dispose();
    _dbmController.dispose();
    super.dispose();
  }

  Future<String?> _pick(ImageSource source) =>
      (widget.pickImage ?? ImageCaptureService.instance.pickAsDataUrl)(source);

  /// Export the pad after every stroke so the signature is ready to submit
  /// the moment the subscriber lifts their finger.
  Future<void> _captureSignature() async {
    final dataUrl = await _signatureController.toDataUrl();
    if (!mounted) return;
    widget.reportSignals.setSignature(dataUrl);
  }

  Future<void> _handleSubmit() async {
    final rep = widget.reportSignals;

    // Check 1: Modem / Router Serial Number
    if (_serialController.text.trim().isEmpty) {
      if (_hardwareSectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          _hardwareSectionKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      _formKey.currentState?.validate();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Modem / Router Serial Number is required.'),
              ),
            ],
          ),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check 2: Form validation
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Please correct the highlighted form errors.'),
              ),
            ],
          ),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check 3: Customer Signature
    if (_signatureController.isEmpty && !rep.hasSignature.value) {
      if (_signOffSectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          _signOffSectionKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Customer signature is required before saving report.'),
              ),
            ],
          ),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_signatureController.isEmpty) {
      rep.setSignature(await _signatureController.toDataUrl());
      if (!mounted) return;
    }
    rep.routerSerial.value = _serialController.text.trim();
    rep.remarks.value = _remarksController.text.trim();

    final success = await rep.submitReport(
      widget.jobsSignals.repository,
      technicianEmail: widget.jobsSignals.technicianEmail.value,
    );

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
                  style: context.text.bodySmall!.copyWith(color: Colors.white),
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Field Completion Report',
              style: context.text.titleMedium,
            ),
            Text(
              'Optical calibration & subscriber hand-off',
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        // The submit button sits at the very bottom, so the scroll has to
        // clear the phone's navigation bar or it stays half covered.
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Target Job Order Selector
              _buildJobOrderSummary(rep),
              const SizedBox(height: 16),

              // 2. Optical Power Reading Gauge & Input
              _buildOpticalPowerSection(rep),
              const SizedBox(height: 16),

              // 3. Hardware & Port Details
              KeyedSubtree(
                key: _hardwareSectionKey,
                child: _buildHardwareSection(rep),
              ),
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
                      Text(
                        'Technician On-Site Remarks',
                        style: context.text.titleMedium,
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
              KeyedSubtree(
                key: _signOffSectionKey,
                child: _buildCustomerSignOffSection(rep),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SignalBuilder(
                builder: (context) {
                  final submitting = rep.isSubmitting.value;

                  return ElevatedButton(
                    onPressed: submitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(52),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Save Completion Report',
                                style: context.text.titleSmall!.copyWith(
                                  color: Colors.white,
                                ),
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

  /// A report always belongs to the job order the technician opened, so the
  /// job is shown read-only rather than as a picker. Letting it be changed
  /// here allowed a report to be filed against the wrong job.
  Widget _buildJobOrderSummary(ReportSignals rep) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SignalBuilder(
          builder: (context) {
            final job = rep.selectedJobOrder.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded,
                        size: 18, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Job Order',
                        style: context.text.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (job == null)
                  Text(
                    'No job order is linked to this report.',
                    style: context.text.bodySmall,
                  )
                else ...[
                  Text(
                    job.ticketNumber,
                    style: context.text.titleSmall!.copyWith(
                      color: AppTheme.brandInkOf(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.customerName,
                    style: context.text.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    job.address,
                    style: context.text.bodySmall,
                  ),
                ],
              ],
            );
          },
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
            Row(
              children: [
                const Icon(Icons.speed_rounded,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Optical Power Meter Reading (dBm)',
                    style: context.text.titleMedium,
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.router_rounded,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hardware & Terminal Assignment',
                    style: context.text.titleMedium,
                  ),
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
                      final models =
                          _availableRouters.map((r) => r.compactName).toList();
                      if (!models.contains(rep.routerModel.value) &&
                          rep.routerModel.value.isNotEmpty) {
                        models.insert(0, rep.routerModel.value);
                      }
                      if (models.isEmpty) {
                        models.addAll([
                          'Huawei 5v5',
                          'UT-KING UT-XP6486-S',
                          'ZTE F670L',
                        ]);
                      }

                      return DropdownButtonFormField<String>(
                        // Without this the button sizes to its widest item
                        // ('UT-KING UT-XP6486-S') and overflows the column it
                        // shares with the NAP port field.
                        isExpanded: true,
                        initialValue: models.contains(rep.routerModel.value)
                            ? rep.routerModel.value
                            : models.first,
                        decoration: const InputDecoration(
                          labelText: 'Approved ONT Model',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: models.map((m) {
                          return DropdownMenuItem(
                              value: m,
                              child: Text(m,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.bodySmall));
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
                        isExpanded: true,
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
                              child: Text(p, style: context.text.bodySmall));
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
            const SizedBox(height: 12),

            // NAP Box Dropdown with Filter in List
            SignalBuilder(
              builder: (context) {
                final selected = rep.nap.value;
                return InkWell(
                  key: const ValueKey('nap_dropdown_field'),
                  onTap: () => _showNapFilterDialog(context, rep, isDark),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'NAP Box',
                      hintText: 'Select or filter NAP...',
                      prefixIcon: Icon(Icons.hub_rounded, size: 20),
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded, size: 24),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    child: Text(
                      selected?.isNotEmpty == true
                          ? selected!
                          : 'Select or filter NAP (e.g. NAP 001)...',
                      style: context.text.bodyMedium!.copyWith(
                        fontWeight: selected?.isNotEmpty == true
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected?.isNotEmpty == true
                            ? null
                            : AppTheme.secondaryInkOf(context),
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

  void _showNapFilterDialog(
      BuildContext context, ReportSignals rep, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NapFilterBottomSheet(
        availableNaps: _availableNaps,
        selectedNap: rep.nap.value,
        onSelect: (napName) {
          rep.nap.value = napName;
        },
      ),
    );
  }

  static IconData _iconFor(JobPhoto photo) => switch (photo) {
        JobPhoto.boxReading => Icons.speed_rounded,
        JobPhoto.routerReading => Icons.router_rounded,
        JobPhoto.setup => Icons.settings_input_antenna_rounded,
        JobPhoto.speedtest => Icons.network_check_rounded,
        JobPhoto.portLabel => Icons.label_rounded,
        JobPhoto.signedContract => Icons.description_rounded,
        JobPhoto.houseFront => Icons.house_rounded,
      };

  Widget _buildPhotoProofSection(ReportSignals rep) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt_outlined,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'On-Site Photo Proofs',
                    style: context.text.titleMedium,
                  ),
                ),
                SignalBuilder(
                  builder: (context) {
                    final job = rep.selectedJobOrder.value;
                    final count = JobPhoto.values
                        .where((p) => rep.photoFor(p)?.isNotEmpty == true)
                        .length;
                    final label = '$count / ${JobPhoto.values.length}';
                    return Text(
                      job == null ? '' : label,
                      style: context.text.bodySmall!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Photos are compressed on the phone and saved with the job order.',
              style: context.text.labelSmall,
            ),
            const SizedBox(height: 12),
            SignalBuilder(
              builder: (context) {
                // Read so the grid rebuilds when any photo changes.
                rep.photos.value;
                rep.selectedJobOrder.value;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.98,
                  ),
                  itemCount: JobPhoto.values.length,
                  itemBuilder: (context, index) {
                    final photo = JobPhoto.values[index];
                    return PhotoCaptureTile(
                      key: ValueKey(photo),
                      label: photo.label,
                      hint: photo.hint,
                      icon: _iconFor(photo),
                      value: rep.photoFor(photo),
                      pick: _pick,
                      onChanged: (v) => rep.setPhoto(photo, v),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSignOffSection(ReportSignals rep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.draw_rounded,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Customer Sign-Off & Acceptance',
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Subscriber acknowledges proper optical installation and functional internet connectivity.',
              style: context.text.bodySmall,
            ),
            const SizedBox(height: 12),
            SignalBuilder(
              builder: (context) {
                final existing = rep.signature.value;
                final existingBytes = DataUrl.decode(existing);
                final padHasInk = !_signatureController.isEmpty;

                // A signature already on the job is shown as-is until the
                // technician chooses to capture a new one.
                if (existingBytes != null && !padHasInk) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.success.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.memory(existingBytes,
                            cacheWidth: 600, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded,
                              size: 20, color: AppTheme.success),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Signature captured',
                              style: context.text.labelMedium!.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.successInkOf(context),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              rep.setSignature(null);
                              _signatureController.clear();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 24),
                            label: const Text('Sign again'),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SignaturePad(
                      controller: _signatureController,
                      onStrokeEnd: _captureSignature,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          padHasInk
                              ? Icons.check_circle_rounded
                              : Icons.touch_app_rounded,
                          size: 20,
                          color: padHasInk ? AppTheme.success : muted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            padHasInk
                                ? 'Signature captured'
                                : 'Ask the subscriber to sign in the box above',
                            style: context.text.labelMedium!.copyWith(
                              color: padHasInk
                                  ? AppTheme.successInkOf(context)
                                  : AppTheme.secondaryInkOf(context),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: padHasInk
                              ? () {
                                  _signatureController.clear();
                                  rep.setSignature(null);
                                }
                              : null,
                          icon: const Icon(Icons.backspace_outlined, size: 24),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NapFilterBottomSheet extends StatefulWidget {
  final List<NapDto> availableNaps;
  final String? selectedNap;
  final ValueChanged<String> onSelect;

  const _NapFilterBottomSheet({
    required this.availableNaps,
    required this.selectedNap,
    required this.onSelect,
  });

  @override
  State<_NapFilterBottomSheet> createState() => _NapFilterBottomSheetState();
}

class _NapFilterBottomSheetState extends State<_NapFilterBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final textTheme = Theme.of(context).textTheme;

    final filtered = widget.availableNaps.where((n) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return n.name.toLowerCase().contains(q) ||
          n.description.toLowerCase().contains(q);
    }).toList();

    return Material(
      color: bg,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.hub_rounded,
                      size: 22, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Select NAP Box',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Filter in list input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchField(
                controller: _searchController,
                hintText: 'Filter NAP list (e.g. 001, test)...',
                onChanged: (val) {
                  setState(() => _query = val.trim());
                },
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),

            // NAP items list
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 40,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textMuted),
                          const SizedBox(height: 8),
                          Text(
                            'No NAP matching "$_query"',
                            style: context.text.bodyMedium!.copyWith(
                              color: AppTheme.secondaryInkOf(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        final isSelected = widget.selectedNap == item.name;
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary.withValues(alpha: 0.15)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.04)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.hub_rounded,
                              size: 20,
                              color: isSelected
                                  ? AppTheme.primary
                                  : (isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textMuted),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: context.text.titleSmall!.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.brandInkOf(context)
                                  : null,
                            ),
                          ),
                          subtitle: item.description.isNotEmpty
                              ? Text(
                                  item.description,
                                  style: context.text.bodySmall,
                                )
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded,
                                  color: AppTheme.primary, size: 20)
                              : null,
                          onTap: () {
                            widget.onSelect(item.name);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
