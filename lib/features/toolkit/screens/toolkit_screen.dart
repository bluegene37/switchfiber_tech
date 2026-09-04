import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import 'fiber_color_code_tool.dart';
import 'optical_budget_tool.dart';
import 'drop_cable_tool.dart';
import 'network_diagnostic_tool.dart';
import 'troubleshooting_guide_tool.dart';
import '../../diagnostics/screens/radius_disconnections_screen.dart';

/// Main Tech Toolkit Hub screen for Field ISP Technicians with iOS styling.
class ToolkitScreen extends StatelessWidget {
  const ToolkitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technician Toolkit',
          style: context.text.titleMedium,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isDark ? AppTheme.borderDark : AppTheme.borderLight,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.handyman_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ISP Field Engineer Suite',
                        style: context.text.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'On-site fiber optics calibration, core splicing references, and network diagnostic tools.',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Fiber Color Code Calculator Card
          _buildToolCard(
            context: context,
            title: 'Fiber Color Code (TIA-598-C)',
            subtitle:
                'Calculate tube & core color mappings for 12F to 288F loose tube cables.',
            icon: Icons.palette_rounded,
            badge: 'Splicing Standard',
            color: const Color(0xFF0070BA),
            badgeTextColor: AppTheme.infoInkOf(context),
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FiberColorCodeTool()),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Optical Link Budget & Loss Calculator Card
          _buildToolCard(
            context: context,
            title: 'Optical Link Budget Calculator',
            subtitle:
                'Theoretical GPON/FTTH link attenuation, splitter loss, and power margin validation.',
            icon: Icons.speed_rounded,
            badge: 'OPM dBm Standard',
            color: AppTheme.primary,
            badgeTextColor: AppTheme.brandInkOf(context),
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OpticalBudgetTool()),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Drop Cable & BOM Estimator Card
          _buildToolCard(
            context: context,
            title: 'Drop Cable & Materials Estimator',
            subtitle:
                'Pole span distance calculations, sag factor, and installation Bill of Materials.',
            icon: Icons.cable_rounded,
            badge: 'Installation BOM',
            color: const Color(0xFF10B981),
            badgeTextColor: AppTheme.successInkOf(context),
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DropCableTool()),
            ),
          ),
          const SizedBox(height: 12),

          // 4. Network Diagnostics & Ping Card
          _buildToolCard(
            context: context,
            title: 'Network & DNS Diagnostics',
            subtitle:
                'Field ping latency, DNS lookup tests, and CGNAT (100.64.0.0/10) subnet helper.',
            icon: Icons.network_ping_rounded,
            badge: 'Connectivity Ping',
            color: const Color(0xFF8B5CF6),
            badgeTextColor: AppTheme.violetInkOf(context),
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NetworkDiagnosticTool()),
            ),
          ),
          const SizedBox(height: 12),

          // 5. Troubleshooting & LOS Decision Guide Card
          _buildToolCard(
            context: context,
            title: 'Field Troubleshooting Guide',
            subtitle:
                'Step-by-step decision trees for Red LOS, high attenuation, and OMCI sync issues.',
            icon: Icons.auto_stories_rounded,
            badge: 'Resolution Guide',
            color: const Color(0xFFF59E0B),
            badgeTextColor: AppTheme.warningInkOf(context),
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TroubleshootingGuideTool()),
            ),
          ),
          const SizedBox(height: 12),

          // 6. Subscriber Disconnections & RADIUS Control Card
          _buildToolCard(
            context: context,
            title: 'Subscriber Disconnections & RADIUS',
            subtitle:
                'Review RADIUS PPPoE accounts and toggle live line connection/disconnection state.',
            icon: CupertinoIcons.wifi_slash,
            badge: 'Live RADIUS',
            color: const Color(0xFFEF4444),
            badgeTextColor: AppTheme.dangerInkOf(context),
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const RadiusDisconnectionsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color color,
    required Color badgeTextColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // iOS Squircle Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: context.text.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkInput
                                    : AppTheme.fillLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.borderDark
                                      : AppTheme.borderLight,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                badge,
                                style: context.text.labelSmall!.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: badgeTextColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(
                    CupertinoIcons.chevron_forward,
                    color: AppTheme.secondaryInkOf(context),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
