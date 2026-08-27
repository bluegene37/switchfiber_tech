import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/fiber_color_code.dart';

/// Interactive Fiber Color Code Calculator & Reference Chart (TIA-598-C Standard).
class FiberColorCodeTool extends StatefulWidget {
  const FiberColorCodeTool({super.key});

  @override
  State<FiberColorCodeTool> createState() => _FiberColorCodeToolState();
}

class _FiberColorCodeToolState extends State<FiberColorCodeTool> {
  final TextEditingController _coreController = TextEditingController(text: '1');
  int _selectedCore = 1;
  int _fibersPerTube = 12;

  @override
  void dispose() {
    _coreController.dispose();
    super.dispose();
  }

  void _updateCore(int value) {
    if (value < 1) value = 1;
    if (value > 288) value = 288;
    setState(() {
      _selectedCore = value;
      _coreController.text = value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = FiberColorCalculator.calculate(
      _selectedCore,
      fibersPerTube: _fibersPerTube,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fiber Color Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text('TIA-598-C Standard loose tube & core lookup', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Core Calculator Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.colorize_rounded, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Core Number to Color Lookup',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Core number input & Fibers per tube selector
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _coreController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Fiber Core #',
                            hintText: '1 - 288',
                            prefixIcon: Icon(Icons.tag_rounded, size: 20),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed >= 1) {
                              setState(() => _selectedCore = parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<int>(
                          value: _fibersPerTube,
                          decoration: const InputDecoration(
                            labelText: 'Fibers/Tube',
                          ),
                          items: const [
                            DropdownMenuItem(value: 6, child: Text('6F Tube')),
                            DropdownMenuItem(value: 12, child: Text('12F Tube')),
                            DropdownMenuItem(value: 24, child: Text('24F Tube')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _fibersPerTube = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick +/- stepper buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickChip('-12', () => _updateCore(_selectedCore - 12)),
                      _buildQuickChip('-1', () => _updateCore(_selectedCore - 1)),
                      _buildQuickChip('+1', () => _updateCore(_selectedCore + 1)),
                      _buildQuickChip('+12', () => _updateCore(_selectedCore + 12)),
                      _buildQuickChip('Core 1', () => _updateCore(1)),
                      _buildQuickChip('Core 24', () => _updateCore(24)),
                      _buildQuickChip('Core 48', () => _updateCore(48)),
                      _buildQuickChip('Core 96', () => _updateCore(96)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Calculation Visual Result Card
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
                Text(
                  'FIBER CORE #$_selectedCore IDENTIFICATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    // Tube Result Block
                    Expanded(
                      child: _buildResultBlock(
                        title: 'TUBE #${result.tubeNumber}',
                        colorName: result.tubeColor.name,
                        color: result.tubeColor.color,
                        textColor: result.tubeColor.textColor,
                        extraInfo: result.hasTubeStripe ? 'With Stripe' : 'Solid Tube',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Fiber Result Block
                    Expanded(
                      child: _buildResultBlock(
                        title: 'FIBER #${result.fiberIndexInTube}',
                        colorName: result.fiberColor.name,
                        color: result.fiberColor.color,
                        textColor: result.fiberColor.textColor,
                        extraInfo: 'Pos ${result.fiberColor.position} in Tube',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Complete Standard 12-Color Reference Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.palette_rounded, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'TIA-598 Standard 12-Color Sequence',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Memory Mnemonic: "BL-OR-GR-BR-SL-WH-RD-BK-YE-VI-RO-AQ"',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 12 Colors Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 8,
                      childAspectRatio: 3.2,
                    ),
                    itemCount: FiberColor.standard12.length,
                    itemBuilder: (context, index) {
                      final item = FiberColor.standard12[index];
                      final isCurrentFiber = result.fiberColor.position == item.position;

                      return InkWell(
                        onTap: () => _updateCore(item.position),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrentFiber
                                  ? AppTheme.primary
                                  : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                              width: isCurrentFiber ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: item.name == 'White'
                                        ? const Color(0xFFADB5BD)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.position}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: item.textColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '#${item.position} ${item.name}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isCurrentFiber
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isCurrentFiber
                                            ? AppTheme.primary
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildResultBlock({
    required String title,
    required String colorName,
    required Color color,
    required Color textColor,
    required String extraInfo,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkInput : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorName == 'White' ? const Color(0xFFADB5BD) : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              colorName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            extraInfo,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
