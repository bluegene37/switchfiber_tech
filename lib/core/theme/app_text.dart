import 'package:flutter/material.dart';

/// `context.text.bodyMedium` instead of `Theme.of(context).textTheme.bodyMedium`.
/// Every widget reads type through this so the scale lives in one place.
extension AppText on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;
}
