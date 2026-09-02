import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';

void main() {
  final bytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 1]);

  test('encodes bytes as an image data URL and decodes them back', () {
    final url = DataUrl.encode(bytes);
    expect(url, startsWith('data:image/jpeg;base64,'));
    expect(DataUrl.isDataUrl(url), isTrue);
    expect(DataUrl.mimeTypeOf(url), 'image/jpeg');
    expect(DataUrl.decode(url), bytes);

    final png = DataUrl.encode(bytes, mimeType: 'image/png');
    expect(DataUrl.mimeTypeOf(png), 'image/png');
    expect(DataUrl.decode(png), bytes);
  });

  test('server paths, URLs and blanks are not inline images', () {
    for (final v in [
      null,
      '',
      '   ',
      'uploads/jo/813/box.jpg',
      'https://example.com/photo.jpg',
      'data:text/plain;base64,aGVsbG8=',
    ]) {
      expect(DataUrl.isDataUrl(v), isFalse, reason: '$v');
      expect(DataUrl.decode(v), isNull, reason: '$v');
    }
  });

  test('malformed base64 decodes to null instead of throwing', () {
    expect(DataUrl.decode('data:image/jpeg;base64,***not-base64***'), isNull);
  });

  test('tolerates surrounding whitespace and missing padding', () {
    final raw = base64Encode(bytes).replaceAll('=', '');
    expect(DataUrl.decode('  data:image/jpeg;base64,$raw \n'), bytes);
  });

  test('estimates payload size from the base64 body', () {
    final url = DataUrl.encode(Uint8List(3000));
    expect(DataUrl.approxBytes(url), 3000);
    expect(DataUrl.formatBytes(3000), '3 KB');
    expect(DataUrl.formatBytes(512), '512 B');
    expect(DataUrl.formatBytes(2 * 1024 * 1024), '2.0 MB');
  });
}
