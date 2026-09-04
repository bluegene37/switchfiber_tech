import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../models/field_troubleshooting_guide.dart';

/// Field Troubleshooting Guide: every issue in one scrollable list, each
/// expanding in place to its probable causes and step-by-step resolution.
///
/// This used to pick one issue from a horizontal chip strip and show only
/// that one. On site a technician wants to scan every symptom at a glance
/// and open the one that matches, so the list is vertical and the details
/// unfold under the issue rather than replacing the page.
class TroubleshootingGuideTool extends StatefulWidget {
  const TroubleshootingGuideTool({super.key});

  @override
  State<TroubleshootingGuideTool> createState() =>
      _TroubleshootingGuideToolState();
}

class _TroubleshootingGuideToolState extends State<TroubleshootingGuideTool> {
  /// Guides currently open. More than one may be open at once, since a
  /// technician often compares two symptoms. The list starts collapsed so all
  /// four issues fit on screen and can be scanned without scrolling.
  final Set<String> _expanded = {};

  void _toggle(String id) {
    setState(() {
      if (!_expanded.remove(id)) _expanded.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Field Troubleshooting', style: context.text.titleMedium),
            Text('Tap an issue to open its resolution steps',
                style: context.text.bodySmall),
          ],
        ),
      ),
      body: ListView(
        // The last issue's steps sit at the very bottom when it is open, so
        // the scroll has to clear the phone's navigation bar.
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        children: [
          for (final guide in TroubleshootingGuideItem.fieldGuides)
            _buildGuideCard(context, guide, isDark),
        ],
      ),
    );
  }

  Widget _buildGuideCard(
      BuildContext context, TroubleshootingGuideItem guide, bool isDark) {
    final isExpanded = _expanded.contains(guide.id);
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: always visible, tap to open or close.
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toggle(guide.id),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: guide.badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(guide.icon, color: guide.badgeColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guide.title, style: context.text.titleMedium),
                          const SizedBox(height: 2),
                          Text(guide.symptom, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.expand_more_rounded, color: muted),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Details: only built while the issue is open.
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Probable Root Causes:',
                    style: context.text.labelMedium!
                        .copyWith(color: AppTheme.secondaryInkOf(context)),
                  ),
                  const SizedBox(height: 6),
                  ...guide.probableCauses.map(
                    (cause) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: TextStyle(
                                  color: AppTheme.brandInkOf(context),
                                  fontWeight: FontWeight.w900)),
                          Expanded(
                              child:
                                  Text(cause, style: context.text.bodyMedium)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Recommended Step-by-Step Resolution:',
                    style: context.text.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  ...guide.actionSteps
                      .map((step) => _buildStep(context, step, isDark)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(
      BuildContext context, TroubleshootingStep step, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${step.stepNumber}',
                style: context.text.labelLarge!.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: context.text.titleSmall),
                const SizedBox(height: 4),
                Text(
                  step.action,
                  style: context.text.bodyMedium!
                      .copyWith(color: AppTheme.secondaryInkOf(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
