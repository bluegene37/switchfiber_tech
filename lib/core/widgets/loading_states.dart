import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Phases the technician data screens move through on first load:
/// a "downloading" indicator while the API fetch runs, a short skeleton
/// pass while Drift hydrates the list, then the real data.
enum DataLoadPhase { downloading, skeleton, ready }

/// Full-area indicator shown while records are being downloaded from the API.
class DownloadingIndicator extends StatelessWidget {
  final String title;
  final String subtitle;

  const DownloadingIndicator({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.cloud_download_rounded,
                    size: 28,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded placeholder block used to compose skeleton cards.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Pulsing list of placeholder cards shown while Drift hydrates the screen.
class SkeletonCardList extends StatefulWidget {
  final int cardCount;

  const SkeletonCardList({super.key, this.cardCount = 5});

  @override
  State<SkeletonCardList> createState() => _SkeletonCardListState();
}

class _SkeletonCardListState extends State<SkeletonCardList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _pulse,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: widget.cardCount,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SkeletonBox(width: 40, height: 40, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonBox(width: 140, height: 14),
                        SizedBox(height: 8),
                        SkeletonBox(width: 90, height: 10),
                      ],
                    ),
                  ),
                  const SkeletonBox(width: 64, height: 22, radius: 11),
                ],
              ),
              const SizedBox(height: 14),
              const SkeletonBox(height: 10),
              const SizedBox(height: 8),
              const SkeletonBox(width: 220, height: 10),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(child: SkeletonBox(height: 34, radius: 10)),
                  SizedBox(width: 10),
                  Expanded(child: SkeletonBox(height: 34, radius: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
