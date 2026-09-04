import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/services/photo_storage_service.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';

void main() {
  late Directory tempDir;
  late PhotoStorageService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('photo_storage_test_');
    service = PhotoStorageService();
    service.setDirectoryForTesting(tempDir);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('saving null returns null, empty returns empty string for deletion', () async {
    expect(await service.savePhotoLocally(null, tag: 'box'), isNull);
    expect(await service.savePhotoLocally('', tag: 'box'), '');
    expect(await service.savePhotoLocally('   ', tag: 'box'), '');
  });

  test('non-data-URL paths are preserved as-is', () async {
    const serverPath = 'uploads/2026/09/box.jpg';
    final saved = await service.savePhotoLocally(serverPath, tag: 'box');
    expect(saved, serverPath);
  });

  test('data URL is saved as a discrete file on disk', () async {
    final dummyBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46]);
    final dataUrl = DataUrl.encode(dummyBytes, mimeType: 'image/jpeg');

    final filePath = await service.savePhotoLocally(dataUrl, tag: 'box_reading', entityId: 42);
    expect(filePath, isNotNull);
    expect(filePath, contains('id_42_box_reading_'));
    expect(filePath, endsWith('.jpg'));

    final file = File(filePath!);
    expect(file.existsSync(), isTrue);
    expect(file.readAsBytesSync(), dummyBytes);

    // resolveBytes can read it back synchronously
    final resolvedBytes = service.resolveBytes(filePath);
    expect(resolvedBytes, dummyBytes);

    // resolveToDataUrl can convert it back to data URL for API uploads
    final reconstructedUrl = await service.resolveToDataUrl(filePath);
    expect(reconstructedUrl, dataUrl);

    // deletion removes file
    await service.deletePhotoFile(filePath);
    expect(file.existsSync(), isFalse);
  });

  test('PNG signature data URL is saved as .png file', () async {
    final dummyPngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    final dataUrl = DataUrl.encode(dummyPngBytes, mimeType: 'image/png');

    final filePath = await service.savePhotoLocally(dataUrl, tag: 'signature', entityId: 101);
    expect(filePath, endsWith('.png'));
    expect(File(filePath!).existsSync(), isTrue);

    final resolved = service.resolveBytes(filePath);
    expect(resolved, dummyPngBytes);

    final url = await service.resolveToDataUrl(filePath);
    expect(url, dataUrl);
  });
}
