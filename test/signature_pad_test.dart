import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/reports/widgets/signature_pad.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('an untouched pad exports nothing', () async {
    final c = SignatureController();
    expect(c.isEmpty, isTrue);
    expect(await c.toDataUrl(), isNull);
  });

  test('strokes export as a PNG data URL and clear resets it', () async {
    final c = SignatureController()
      ..canvasSize = const Size(300, 120)
      ..beginStroke(const Offset(10, 60))
      ..extendStroke(const Offset(80, 30))
      ..extendStroke(const Offset(150, 90));

    final url = await c.toDataUrl();
    expect(DataUrl.isDataUrl(url), isTrue);
    expect(DataUrl.mimeTypeOf(url), 'image/png');
    final bytes = DataUrl.decode(url)!;
    // PNG magic number.
    expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);

    c.clear();
    expect(c.isEmpty, isTrue);
    expect(await c.toDataUrl(), isNull);
  });

  testWidgets('drawing on the pad records strokes and reports each one',
      (tester) async {
    final c = SignatureController();
    var ended = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SignaturePad(controller: c, onStrokeEnd: () => ended++),
      ),
    ));
    expect(find.text('Sign here'), findsOneWidget);

    final center = tester.getCenter(find.byType(SignaturePad));
    await tester.timedDrag(find.byType(SignaturePad), const Offset(60, 20),
        const Duration(milliseconds: 200));
    await tester.pump();

    expect(c.isEmpty, isFalse);
    expect(c.strokes.single.length, greaterThan(1));
    expect(ended, 1);
    expect(find.text('Sign here'), findsNothing);
    expect(c.canvasSize.width, greaterThan(0));
    expect(c.strokes.single.first.dx, lessThan(center.dx + 1));
  });
}
