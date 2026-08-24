import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/settings/signals/settings_signals.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> store;

  setUp(() {
    store = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        switch (call.method) {
          case 'read':
            return store[call.arguments['key']];
          case 'write':
            store[call.arguments['key']] = call.arguments['value'] as String;
            return null;
          case 'delete':
            store.remove(call.arguments['key']);
            return null;
          case 'deleteAll':
            store.clear();
            return null;
          case 'readAll':
            return store;
          default:
            return null;
        }
      },
    );
    SettingsSignals.instance.themeMode.value = ThemeMode.light;
  });

  test('defaults to light when nothing has been saved', () async {
    await SettingsSignals.instance.restore();
    expect(SettingsSignals.instance.themeMode.value, ThemeMode.light);
    expect(SettingsSignals.instance.isDarkMode, isFalse);
  });

  test('toggling to dark persists the choice', () async {
    await SettingsSignals.instance.setDarkMode(true);
    expect(SettingsSignals.instance.themeMode.value, ThemeMode.dark);
    expect(store['dark_mode_enabled'], 'true');
  });

  test('a saved dark preference survives a restart', () async {
    await SettingsSignals.instance.setDarkMode(true);
    // Simulate a fresh launch: reset in-memory state, keep stored values.
    SettingsSignals.instance.themeMode.value = ThemeMode.light;

    await SettingsSignals.instance.restore();
    expect(SettingsSignals.instance.themeMode.value, ThemeMode.dark);
  });

  test('turning dark mode back off persists too', () async {
    await SettingsSignals.instance.setDarkMode(true);
    await SettingsSignals.instance.setDarkMode(false);
    expect(store['dark_mode_enabled'], 'false');

    SettingsSignals.instance.themeMode.value = ThemeMode.dark;
    await SettingsSignals.instance.restore();
    expect(SettingsSignals.instance.themeMode.value, ThemeMode.light);
  });
}
