import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/reports/widgets/photo_capture_tile.dart';

/// A 1x1 transparent PNG, so Image.memory can actually decode it.
final _pngBytes = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, //
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);
final _png = DataUrl.encode(_pngBytes, mimeType: 'image/png');

void main() {
  Widget host({
    required String? value,
    required Future<String?> Function(ImageSource) pick,
    required ValueChanged<String?> onChanged,
  }) =>
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: PhotoCaptureTile(
                label: 'House Front',
                hint: 'Premises from the street',
                icon: Icons.house_rounded,
                value: value,
                pick: pick,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      );

  testWidgets('taking a photo hands the data URL back', (tester) async {
    ImageSource? requested;
    String? received;
    await tester.pumpWidget(host(
      value: null,
      pick: (source) async {
        requested = source;
        return _png;
      },
      onChanged: (v) => received = v,
    ));

    expect(find.text('Tap to add photo'), findsOneWidget);
    await tester.tap(find.text('House Front'));
    await tester.pumpAndSettle();
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Remove photo'), findsNothing,
        reason: 'nothing to remove yet');

    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();

    expect(requested, ImageSource.camera);
    expect(received, _png);
  });

  testWidgets('cancelling the picker leaves the field untouched',
      (tester) async {
    var changed = false;
    await tester.pumpWidget(host(
      value: null,
      pick: (_) async => null,
      onChanged: (_) => changed = true,
    ));
    await tester.tap(find.text('House Front'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();
    expect(changed, isFalse);
  });

  testWidgets('a held photo shows a thumbnail and can be removed',
      (tester) async {
    String? received = 'untouched';
    await tester.pumpWidget(host(
      value: _png,
      pick: (_) async => null,
      onChanged: (v) => received = v,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Tap to add photo'), findsNothing);

    await tester.tap(find.text('House Front'));
    await tester.pumpAndSettle();
    expect(find.text('Retake photo'), findsOneWidget);
    expect(find.text('View photo'), findsOneWidget);

    await tester.tap(find.text('Remove photo'));
    await tester.pumpAndSettle();
    expect(received, '', reason: 'an empty string clears the field on sync');
  });

  testWidgets('a server path is reported as stored, not rendered',
      (tester) async {
    await tester.pumpWidget(host(
      value: 'uploads/813/houseFront.jpg',
      pick: (_) async => null,
      onChanged: (_) {},
    ));
    expect(find.text('Stored on server'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('a picker failure is explained rather than thrown',
      (tester) async {
    await tester.pumpWidget(host(
      value: null,
      pick: (_) async => throw StateError('no camera'),
      onChanged: (_) {},
    ));
    await tester.tap(find.text('House Front'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not open the camera'), findsOneWidget);
  });
}
