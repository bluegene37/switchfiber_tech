import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The one search field for every list in the app.
///
/// Reads its height and padding from the theme so it is at least 52 dp and
/// grows with the phone's text size instead of clipping. The clear button is
/// a real 48 dp target. Five screens used to hand-build a 38 dp capsule with a
/// 16 px icon and dense zero-padding text; this replaces all of them.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;

  /// Fired on every keystroke and with an empty string when cleared, so the
  /// owning screen resets its filter in one place.
  final ValueChanged<String> onChanged;

  static const double minHeight = 52;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: isDark ? AppTheme.darkInput : AppTheme.fillLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            prefixIcon: Icon(Icons.search_rounded,
                size: 22, color: AppTheme.secondaryInkOf(context)),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    iconSize: 24,
                    constraints:
                        const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: Icon(Icons.close_rounded,
                        color: AppTheme.secondaryInkOf(context)),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
