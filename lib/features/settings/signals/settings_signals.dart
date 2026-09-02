import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage_service.dart';

/// Device-level preferences that are not tied to a technician's session.
///
/// Stored alongside the API base URL and cleared only by a full reset, so a
/// logout does not throw away the technician's display choices.
class SettingsSignals {
  static final SettingsSignals instance = SettingsSignals._internal();
  factory SettingsSignals() => instance;
  SettingsSignals._internal();

  final SecureStorageService _storage = SecureStorageService.instance;

  final themeMode = signal<ThemeMode>(ThemeMode.light);

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  /// Load saved preferences. Falls back to light on anything unreadable so a
  /// corrupt value can never leave the app themeless.
  Future<void> restore() async {
    try {
      final saved = await _storage.read(AppConstants.keyDarkMode);
      themeMode.value = saved?.trim().toLowerCase() == 'true'
          ? ThemeMode.dark
          : ThemeMode.light;
    } catch (_) {
      themeMode.value = ThemeMode.light;
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    themeMode.value = enabled ? ThemeMode.dark : ThemeMode.light;
    await _storage.write(AppConstants.keyDarkMode, enabled.toString());
  }
}
