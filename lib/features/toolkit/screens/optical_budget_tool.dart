import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../models/optical_budget_model.dart';

/// Interactive Optical Link Budget & Loss Calculator for GPON FTTH Technicians.
class OpticalBudgetTool extends StatefulWidget {
  const OpticalBudgetTool({super.key});

  @override
  State<OpticalBudgetTool> createState() => _OpticalBudgetToolState();
}

class _OpticalBudgetToolState extends State<OpticalBudgetTool> {
  double _oltTxPower = 4.0;
  double _fiberDistanceKm = 2.5;
  SplitterRatio _lcpSplitter = SplitterRatio.ratio1x4;
  SplitterRatio? _napSplitter = SplitterRatio.ratio1x8;
  int _spliceCount = 4;
  int _connectorCount = 2;
  final TextEditingController _measuredController = TextEditingController();
  double? _measuredRxPower;

  @override
  void dispose() {
    _measuredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final budget = OpticalBudgetModel(
      oltTxPower: _oltTxPower,
      fiberDistanceKm: _fiberDistanceKm,
      fiberAttenuationPerKm: 0.35,
      lcpSplitter: _lcpSplitter,
      napSplitter: _napSplitter,
      fusionSpliceCount: _spliceCount,
      connectorCount: _connectorCount,
      measuredRxPower: _measuredRxPower,
    );

    final status = budget.status;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Optical Link Budget', style: context.text.titleMedium),
            Text('GPON / FTTH loss calculation & power meter validation',
                style: context.text.bodySmall),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Result Power Gauge Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THEORETICAL ONT RX POWER',
                            style: context.text.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${budget.expectedRxPower.toStringAsFixed(2)} dBm',
                            style: context.text.headlineSmall!.copyWith(
                              color: switch (status) {
                                OpticalPowerStatus.optimal =>
                                  AppTheme.successInkOf(context),
                                OpticalPowerStatus.marginal =>
                                  AppTheme.warningInkOf(context),
                                OpticalPowerStatus.faulty =>
                                  AppTheme.dangerInkOf(context),
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.label,
                        style: context.text.labelLarge!.copyWith(
                          color: AppTheme.darkSlate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                    height: 1,
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: _buildStatPill(context, 'Total Loss',
                            '-${budget.totalCalculatedLoss.toStringAsFixed(2)} dB')),
                    Expanded(
                        child: _buildStatPill(context, 'OLT Tx',
                            '+${_oltTxPower.toStringAsFixed(1)} dBm')),
                    Expanded(
                        child: _buildStatPill(context, 'Optics Margin',
                            '${(budget.expectedRxPower - (-27.0)).toStringAsFixed(1)} dB')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Field Power Meter Validation Card
          Card(
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
                          'Compare with Actual Meter Reading',
                          style: context.text.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _measuredController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Actual OPM Reading (dBm)',
                            hintText: 'e.g. -19.4',
                            prefixIcon: Icon(Icons.flash_on_rounded, size: 20),
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val);
                            setState(() => _measuredRxPower = parsed);
                          },
                        ),
                      ),
                      if (_measuredRxPower != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppTheme.darkInput : AppTheme.lightBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Variance', style: context.text.labelSmall),
                              Text(
                                '${budget.variance! >= 0 ? "+" : ""}${budget.variance!.toStringAsFixed(1)} dB',
                                style: context.text.titleSmall!.copyWith(
                                  color: budget.variance!.abs() > 3.0
                                      ? AppTheme.warningInkOf(context)
                                      : AppTheme.successInkOf(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Network Link Configuration Inputs
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded,
                          size: 18, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Link Parameters',
                        style: context.text.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // OLT Tx Power Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text('OLT Port Tx Power (Class B+/C+):',
                              style: context.text.bodySmall)),
                      const SizedBox(width: 8),
                      Text('+${_oltTxPower.toStringAsFixed(1)} dBm',
                          style: context.text.titleSmall!
                              .copyWith(color: AppTheme.brandInkOf(context))),
                    ],
                  ),
                  Slider(
                    value: _oltTxPower,
                    min: 1.0,
                    max: 8.0,
                    divisions: 14,
                    label: '+${_oltTxPower.toStringAsFixed(1)} dBm',
                    onChanged: (v) => setState(() => _oltTxPower = v),
                  ),

                  // Fiber Distance Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text('Fiber Route Distance:',
                              style: context.text.bodySmall)),
                      const SizedBox(width: 8),
                      Text(
                          '${_fiberDistanceKm.toStringAsFixed(1)} km (${(_fiberDistanceKm * 0.35).toStringAsFixed(2)} dB)',
                          style: context.text.titleSmall!
                              .copyWith(color: AppTheme.brandInkOf(context))),
                    ],
                  ),
                  Slider(
                    value: _fiberDistanceKm,
                    min: 0.5,
                    max: 15.0,
                    divisions: 29,
                    label: '${_fiberDistanceKm.toStringAsFixed(1)} km',
                    onChanged: (v) => setState(() => _fiberDistanceKm = v),
                  ),

                  const SizedBox(height: 10),

                  // LCP Splitter Dropdown
                  DropdownButtonFormField<SplitterRatio>(
                    isExpanded: true,
                    initialValue: _lcpSplitter,
                    decoration: const InputDecoration(
                        labelText: 'LCP Cabinet Splitter (Stage 1)'),
                    items: SplitterRatio.values
                        .map((r) => DropdownMenuItem(
                            value: r,
                            child:
                                Text('${r.label} (-${r.insertionLossDb} dB)')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _lcpSplitter = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // NAP Splitter Dropdown
                  DropdownButtonFormField<SplitterRatio?>(
                    isExpanded: true,
                    initialValue: _napSplitter,
                    decoration: const InputDecoration(
                        labelText: 'NAP Box Splitter (Stage 2)'),
                    items: [
                      const DropdownMenuItem(
                          value: null,
                          child: Text('None (Direct / Single Stage)')),
                      ...SplitterRatio.values.map((r) => DropdownMenuItem(
                          value: r,
                          child:
                              Text('${r.label} (-${r.insertionLossDb} dB)'))),
                    ],
                    onChanged: (v) => setState(() => _napSplitter = v),
                  ),
                  const SizedBox(height: 14),

                  // Splice & Connector counts
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _spliceCount,
                          decoration: const InputDecoration(
                              labelText: 'Fusion Splices'),
                          items: List.generate(
                              10,
                              (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text(
                                      '$i splices (${(i * 0.05).toStringAsFixed(2)} dB)'))),
                          onChanged: (v) {
                            if (v != null) setState(() => _spliceCount = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _connectorCount,
                          decoration:
                              const InputDecoration(labelText: 'SC/APC Pairs'),
                          items: List.generate(
                              6,
                              (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(
                                      '${i + 1} pairs (${((i + 1) * 0.3).toStringAsFixed(1)} dB)'))),
                          onChanged: (v) {
                            if (v != null) setState(() => _connectorCount = v);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: context.text.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: context.text.titleSmall),
      ],
    );
  }
}
