import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_text.dart';
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
  final double _sagPercentage = 8.0;
  final double _facadeLoopMeters = 3.0;
  double _indoorRunMeters = 10.0;
  final double _serviceLoopMeters = 4.0;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Drop Cable Estimator', style: context.text.titleLarge),
            Text('Span calculations & Bill of Materials (BOM)',
                style: context.text.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Copy BOM to Clipboard',
            onPressed: () {
              final buffer = StringBuffer();
              buffer.writeln('=== SWITCH FIBER INSTALLATION BOM ===');
              buffer.writeln(
                  'Calculated Drop Length: ${totalMeters.toStringAsFixed(1)}m (Spans: $_poleSpans)');
              buffer.writeln('------------------------------------');
              for (final item in bomItems) {
                buffer.writeln('• ${item.name}: ${item.quantity}');
              }
              Clipboard.setData(ClipboardData(text: buffer.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('BOM checklist copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor:
                      isDark ? AppTheme.darkCard : AppTheme.darkSlate,
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
                color:
                    isDark ? AppTheme.borderDark : AppTheme.primarySubtleBorder,
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
                          style: context.text.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalMeters.ceil()} Meters',
                          style: context.text.headlineSmall!.copyWith(
                            color: AppTheme.brandInkOf(context),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkInput : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.borderDark
                              : AppTheme.borderLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('Exact Length', style: context.text.labelSmall),
                          Text(
                            '${totalMeters.toStringAsFixed(1)} m',
                            style: context.text.titleSmall,
                          ),
                        ],
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
                    _buildSubstat(context, 'Aerial Span',
                        '${estimator.aerialSpanLength.toStringAsFixed(1)}m'),
                    _buildSubstat(context, 'Indoor Run',
                        '${_indoorRunMeters.toStringAsFixed(1)}m'),
                    _buildSubstat(context, 'Coil/Slack',
                        '${(_facadeLoopMeters + _serviceLoopMeters).toStringAsFixed(1)}m'),
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
                  Row(
                    children: [
                      const Icon(Icons.cable_rounded,
                          size: 18, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Span & Route Parameters',
                        style: context.text.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Pole Spans Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pole Spans (Pole to Pole):',
                          style: context.text.bodySmall),
                      Text('$_poleSpans spans',
                          style: context.text.titleSmall!
                              .copyWith(color: AppTheme.brandInkOf(context))),
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
                      Text('Avg Span Distance (Meters):',
                          style: context.text.bodySmall),
                      Text('${_averageSpanMeters.toStringAsFixed(0)} m',
                          style: context.text.titleSmall!
                              .copyWith(color: AppTheme.brandInkOf(context))),
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
                      Text('Indoor Conduit Run to ONT:',
                          style: context.text.bodySmall),
                      Text('${_indoorRunMeters.toStringAsFixed(0)} m',
                          style: context.text.titleSmall!
                              .copyWith(color: AppTheme.brandInkOf(context))),
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
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 18, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Bill of Materials Checklist',
                        style: context.text.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bomItems.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: isDark
                            ? AppTheme.borderDark
                            : AppTheme.borderLight),
                    itemBuilder: (context, index) {
                      final item = bomItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkInput
                                    : AppTheme.primarySubtleBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.category,
                                style: context.text.labelSmall!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.brandInkOf(context)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.name,
                                style: context.text.titleSmall,
                              ),
                            ),
                            Text(
                              item.quantity,
                              style: context.text.titleSmall,
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

  Widget _buildSubstat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: context.text.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: context.text.titleSmall),
      ],
    );
  }
}
