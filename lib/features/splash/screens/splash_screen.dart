import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Branded Splash Screen displaying the official Switch Fiber logo and initializing the terminal environment.
///
/// Purely presentational: it reports completion through [onComplete] and never
/// routes by itself, so that auth state stays the single source of truth for
/// which screen is shown.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration minDuration;

  const SplashScreen({
    super.key,
    required this.onComplete,
    this.minDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for minimum aesthetic duration or async tasks
    await Future.delayed(widget.minDuration);
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkSlate : AppTheme.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                Container(
                  width: 110,
                  height: 110,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppTheme.darkCard : AppTheme.primarySubtleBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppTheme.borderDark
                          : AppTheme.primarySubtleBorder,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.wifi_tethering_rounded,
                      size: 54,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // App Brand Name
                Text(
                  'Switch Fiber',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.white : AppTheme.darkSlate,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),

                // App Subtitle / Role Tag
                const Text(
                  'Field Technician Terminal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 48),

                // Subtle Loading Indicator
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
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
