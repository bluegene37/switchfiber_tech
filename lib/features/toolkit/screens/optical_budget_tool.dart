import 'package:flutter/material.dart';
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Optical Link Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text('GPON / FTTH loss calculation & power meter validation', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THEORETICAL ONT RX POWER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${budget.expectedRxPower.toStringAsFixed(2)} dBm',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: status.color,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatPill('Total Loss', '-${budget.totalCalculatedLoss.toStringAsFixed(2)} dB', isDark),
                    _buildStatPill('OLT Tx', '+${_oltTxPower.toStringAsFixed(1)} dBm', isDark),
                    _buildStatPill('Optics Margin', '${(budget.expectedRxPower - (-27.0)).toStringAsFixed(1)} dB', isDark),
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
                  const Row(
                    children: [
                      Icon(Icons.speed_rounded, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Compare with Actual Meter Reading',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _measuredController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Variance', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted)),
                              Text(
                                '${budget.variance! >= 0 ? "+" : ""}${budget.variance!.toStringAsFixed(1)} dB',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: budget.variance!.abs() > 3.0 ? AppTheme.warning : AppTheme.success,
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
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Link Parameters',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // OLT Tx Power Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('OLT Port Tx Power (Class B+/C+):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('+${_oltTxPower.toStringAsFixed(1)} dBm', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary)),
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
                      const Text('Fiber Route Distance:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${_fiberDistanceKm.toStringAsFixed(1)} km (${(_fiberDistanceKm * 0.35).toStringAsFixed(2)} dB)', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary)),
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
                    value: _lcpSplitter,
                    decoration: const InputDecoration(labelText: 'LCP Cabinet Splitter (Stage 1)'),
                    items: SplitterRatio.values.map((r) => DropdownMenuItem(value: r, child: Text('${r.label} (-${r.insertionLossDb} dB)'))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _lcpSplitter = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // NAP Splitter Dropdown
                  DropdownButtonFormField<SplitterRatio?>(
                    value: _napSplitter,
                    decoration: const InputDecoration(labelText: 'NAP Box Splitter (Stage 2)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None (Direct / Single Stage)')),
                      ...SplitterRatio.values.map((r) => DropdownMenuItem(value: r, child: Text('${r.label} (-${r.insertionLossDb} dB)'))),
                    ],
                    onChanged: (v) => setState(() => _napSplitter = v),
                  ),
                  const SizedBox(height: 14),

                  // Splice & Connector counts
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _spliceCount,
                          decoration: const InputDecoration(labelText: 'Fusion Splices'),
                          items: List.generate(10, (i) => DropdownMenuItem(value: i, child: Text('$i splices (${(i * 0.05).toStringAsFixed(2)} dB)'))),
                          onChanged: (v) {
                            if (v != null) setState(() => _spliceCount = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _connectorCount,
                          decoration: const InputDecoration(labelText: 'SC/APC Pairs'),
                          items: List.generate(6, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} pairs (${((i + 1) * 0.3).toStringAsFixed(1)} dB)'))),
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

  Widget _buildStatPill(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
