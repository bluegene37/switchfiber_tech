import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'fiber_color_code_tool.dart';
import 'optical_budget_tool.dart';
import 'drop_cable_tool.dart';
import 'network_diagnostic_tool.dart';
import 'troubleshooting_guide_tool.dart';

/// Main Tech Toolkit Hub screen for Field ISP Technicians.
class ToolkitScreen extends StatelessWidget {
  const ToolkitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Technician Toolkit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Field calculators, splicing codes & diagnostics',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF3F2327), const Color(0xFF2B3035)]
                    : [AppTheme.primarySubtleBg, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.primarySubtleBorder,
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
                      const Text(
                        'ISP Field Engineer Suite',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'On-site fiber optics calibration, core splicing references, and network diagnostic tools.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                        ),
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
            subtitle: 'Calculate tube & core color mappings for 12F to 288F loose tube cables.',
            icon: Icons.palette_rounded,
            badge: 'Splicing Standard',
            color: const Color(0xFF0070BA),
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
            subtitle: 'Theoretical GPON/FTTH link attenuation, splitter loss, and power margin validation.',
            icon: Icons.speed_rounded,
            badge: 'OPM dBm Standard',
            color: AppTheme.primary,
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
            subtitle: 'Pole span distance calculations, sag factor, and installation Bill of Materials.',
            icon: Icons.cable_rounded,
            badge: 'Installation BOM',
            color: const Color(0xFF10B981),
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
            subtitle: 'Field ping latency, DNS lookup tests, and CGNAT (100.64.0.0/10) subnet helper.',
            icon: Icons.network_ping_rounded,
            badge: 'Connectivity Ping',
            color: const Color(0xFF8B5CF6),
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
            subtitle: 'Step-by-step decision trees for Red LOS, high attenuation, and OMCI sync issues.',
            icon: Icons.auto_stories_rounded,
            badge: 'Resolution Guide',
            color: const Color(0xFFF59E0B),
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TroubleshootingGuideTool()),
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
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, color: color, size: 24),
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
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                            ),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
