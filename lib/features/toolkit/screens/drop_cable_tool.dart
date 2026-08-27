import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../models/drop_cable_estimator_model.dart';

/// Interactive Drop Cable & Bill of Materials (BOM) Estimator for Field Installations.
class DropCableTool extends StatefulWidget {
  const DropCableTool({super.key});

  @override
  State<DropCableTool> createState() => _DropCableToolState();
}

class _DropCableToolState extends State<DropCableTool> {
  int _poleSpans = 2;
  double _averageSpanMeters = 35.0;
  double _sagPercentage = 8.0;
  double _facadeLoopMeters = 3.0;
  double _indoorRunMeters = 10.0;
  double _serviceLoopMeters = 4.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final estimator = DropCableEstimatorModel(
      poleSpans: _poleSpans,
      averageSpanMeters: _averageSpanMeters,
      sagPercentage: _sagPercentage,
      facadeDripLoopMeters: _facadeLoopMeters,
      indoorRunMeters: _indoorRunMeters,
      serviceLoopMeters: _serviceLoopMeters,
    );

    final totalMeters = estimator.totalMeters;
    final bomItems = estimator.recommendedBOM;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Drop Cable Estimator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text('Span calculations & Bill of Materials (BOM)', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Copy BOM to Clipboard',
            onPressed: () {
              final buffer = StringBuffer();
              buffer.writeln('=== SWITCH FIBER INSTALLATION BOM ===');
              buffer.writeln('Calculated Drop Length: ${totalMeters.toStringAsFixed(1)}m (Spans: $_poleSpans)');
              buffer.writeln('------------------------------------');
              for (final item in bomItems) {
                buffer.writeln('• ${item.name}: ${item.quantity}');
              }
              Clipboard.setData(ClipboardData(text: buffer.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('BOM checklist copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: isDark ? AppTheme.darkCard : AppTheme.darkSlate,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Total Cable Requirement Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2B3035), const Color(0xFF25292E)]
                    : [Colors.white, AppTheme.primarySubtleBg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.primarySubtleBorder,
                width: 1.5,
              ),
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
                          'RECOMMENDED DROP WIRE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalMeters.ceil()} Meters',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkInput : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('Exact Length', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          Text(
                            '${totalMeters.toStringAsFixed(1)} m',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
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
                    _buildSubstat('Aerial Span', '${estimator.aerialSpanLength.toStringAsFixed(1)}m', isDark),
                    _buildSubstat('Indoor Run', '${_indoorRunMeters.toStringAsFixed(1)}m', isDark),
                    _buildSubstat('Coil/Slack', '${(_facadeLoopMeters + _serviceLoopMeters).toStringAsFixed(1)}m', isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Installation Parameters Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cable_rounded, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Span & Route Parameters',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Pole Spans Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pole Spans (Pole to Pole):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('$_poleSpans spans', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary)),
                    ],
                  ),
                  Slider(
                    value: _poleSpans.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: '$_poleSpans spans',
                    onChanged: (v) => setState(() => _poleSpans = v.toInt()),
                  ),

                  // Average Span Distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Avg Span Distance (Meters):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${_averageSpanMeters.toStringAsFixed(0)} m', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary)),
                    ],
                  ),
                  Slider(
                    value: _averageSpanMeters,
                    min: 20,
                    max: 60,
                    divisions: 8,
                    label: '${_averageSpanMeters.toStringAsFixed(0)} m',
                    onChanged: (v) => setState(() => _averageSpanMeters = v),
                  ),

                  // Indoor Run
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Indoor Conduit Run to ONT:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${_indoorRunMeters.toStringAsFixed(0)} m', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary)),
                    ],
                  ),
                  Slider(
                    value: _indoorRunMeters,
                    min: 2,
                    max: 30,
                    divisions: 14,
                    label: '${_indoorRunMeters.toStringAsFixed(0)} m',
                    onChanged: (v) => setState(() => _indoorRunMeters = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Recommended Bill of Materials (BOM)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Bill of Materials Checklist',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bomItems.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    itemBuilder: (context, index) {
                      final item = bomItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkInput : AppTheme.primarySubtleBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.category,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              item.quantity,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
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
