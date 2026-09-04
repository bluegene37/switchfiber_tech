import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/data_url.dart';

/// Holds the strokes drawn on a [SignaturePad] and renders them to a PNG.
///
/// Kept separate from the widget so a signature can be exported and cleared
/// from outside, and so the export is testable without a widget tree.
class SignatureController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];

  /// Logical size of the pad the strokes were drawn on, set by the widget.
  Size canvasSize = Size.zero;

  List<List<Offset>> get strokes => List.unmodifiable(_strokes);

  bool get isEmpty => _strokes.every((s) => s.isEmpty);

  void beginStroke(Offset point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void extendStroke(Offset point) {
    if (_strokes.isEmpty) {
      beginStroke(point);
      return;
    }
    _strokes.last.add(point);
    notifyListeners();
  }

  void clear() {
    _strokes.clear();
    notifyListeners();
  }

  /// Render the signature as a PNG data URL on a white background, or null
  /// when nothing has been drawn. [pixelRatio] sharpens the export without
  /// changing the drawn proportions.
  Future<String?> toDataUrl({double pixelRatio = 2}) async {
    if (isEmpty) return null;
    final size = canvasSize == Size.zero ? const Size(400, 180) : canvasSize;
    final width = (size.width * pixelRatio).ceil();
    final height = (size.height * pixelRatio).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFFFFFFF));
    SignaturePainter.paintStrokes(canvas, _strokes,
        color: const Color(0xFF111827), strokeWidth: 2.6);

    final image = await recorder.endRecording().toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) return null;
    return DataUrl.encode(data.buffer.asUint8List(), mimeType: 'image/png');
  }
}

/// Alias for [SignatureController] for backwards compatibility.
typedef SignaturePadController = SignatureController;

/// A drawing surface for the subscriber's signature.
///
/// Reports each finished stroke through [onStrokeEnd] so the owner can export
/// as the customer signs, and stays inert until touched so an untouched pad
/// never produces a blank "signature".
class SignaturePad extends StatelessWidget {
  final SignatureController controller;
  final double height;
  final VoidCallback? onStrokeEnd;

  const SignaturePad({
    super.key,
    required this.controller,
    this.height = 180,
    this.onStrokeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        controller.canvasSize = Size(constraints.maxWidth, height);
        return RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: <Type, GestureRecognizerFactory>{
            EagerPanGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<EagerPanGestureRecognizer>(
              () => EagerPanGestureRecognizer(),
              (EagerPanGestureRecognizer instance) {
                instance.onStart =
                    (d) => controller.beginStroke(d.localPosition);
                instance.onUpdate =
                    (d) => controller.extendStroke(d.localPosition);
                instance.onEnd = (_) => onStrokeEnd?.call();
              },
            ),
          },
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => CustomPaint(
                painter: SignaturePainter(controller.strokes),
                child: controller.isEmpty
                    ? Center(
                        child: Text(
                          'Sign here',
                          // The plain (non-`Of`) const is deliberate: this
                          // canvas is always white regardless of theme (see
                          // `color: Colors.white` above), so the placeholder
                          // must stay a fixed, theme-invariant ink rather
                          // than follow dark mode like `secondaryInkOf` would.
                          style: context.text.titleSmall!.copyWith(
                            color: AppTheme.secondaryInk,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    : const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A [PanGestureRecognizer] that immediately claims victory in the gesture arena
/// on pointer down, ensuring drawing strokes are never stolen or delayed by parent
/// scrollable containers like [SingleChildScrollView].
class EagerPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'eager pan';
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  const SignaturePainter(this.strokes);

  static void paintStrokes(Canvas canvas, List<List<Offset>> strokes,
      {required Color color, required double strokeWidth}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawPoints(ui.PointMode.points, stroke, paint);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintStrokes(canvas, strokes,
        color: const Color(0xFF111827), strokeWidth: 2.6);
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
