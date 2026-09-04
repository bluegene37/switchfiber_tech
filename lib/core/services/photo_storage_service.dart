import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../utils/data_url.dart';

/// Manages filesystem persistence for photo proofs and subscriber signatures.
///
/// Offloading Base64 images and drawn signatures to discrete files in the
/// application documents directory prevents SQLite rows from exceeding the
/// 2MB Android CursorWindow limit and eliminates high memory bloat in
/// reactive Drift queries.
class PhotoStorageService {
  static PhotoStorageService instance = PhotoStorageService();

  Directory? _customDirectory;

  /// Override base directory for unit tests.
  void setDirectoryForTesting(Directory? dir) {
    _customDirectory = dir;
  }

  /// Get the directory where local proof photos are saved.
  Future<Directory> get photosDirectory async {
    if (_customDirectory != null) {
      final dir = Directory(p.join(_customDirectory!.path, 'photos'));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return dir;
    }
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'photos'));
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (_) {
      final temp = Directory.systemTemp;
      final dir = Directory(p.join(temp.path, 'photos'));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return dir;
    }
  }

  /// Persists a photo or signature data URL to disk as a `.jpg` or `.png` file.
  ///
  /// If [dataUrlOrPath] is already a local file path or server path, it is
  /// returned as-is.
  /// If it is a data URL (`data:image/...;base64,...`), it is decoded and
  /// written to a dedicated file on disk, returning the local file path.
  Future<String?> savePhotoLocally(
    String? dataUrlOrPath, {
    required String tag,
    int? entityId,
  }) async {
    if (dataUrlOrPath == null) return null;
    final trimmed = dataUrlOrPath.trim();
    if (trimmed.isEmpty) return '';

    if (!DataUrl.isDataUrl(trimmed)) {
      return trimmed;
    }

    final bytes = DataUrl.decode(trimmed);
    if (bytes == null || bytes.isEmpty) return null;

    final mime = DataUrl.mimeTypeOf(trimmed) ?? 'image/jpeg';
    final ext = mime == 'image/png' ? 'png' : 'jpg';

    final dir = await photosDirectory;
    final idPart = entityId != null ? 'id_${entityId}_' : '';
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final filename = '$idPart${tag}_$timestamp.$ext';
    final file = File(p.join(dir.path, filename));

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Synchronously or quickly resolves bytes for an image reference.
  ///
  /// Handles:
  /// 1. Base64 data URLs (`data:image/...`).
  /// 2. Local filesystem paths (`/data/...` or `file:///...`).
  /// Returns `null` if the reference is empty or the file does not exist.
  Uint8List? resolveBytes(String? pathOrDataUrl) {
    if (pathOrDataUrl == null || pathOrDataUrl.trim().isEmpty) return null;
    final trimmed = pathOrDataUrl.trim();

    if (DataUrl.isDataUrl(trimmed)) {
      return DataUrl.decode(trimmed);
    }

    try {
      final filePath = trimmed.startsWith('file://')
          ? Uri.parse(trimmed).toFilePath()
          : trimmed;
      final file = File(filePath);
      if (file.existsSync()) {
        return file.readAsBytesSync();
      }
    } catch (_) {}

    return null;
  }

  /// Converts a local file path back into a Base64 data URL for API uploads.
  ///
  /// If [pathOrDataUrl] is already a data URL or relative server path (e.g.
  /// `uploads/...`), it is returned as-is.
  Future<String?> resolveToDataUrl(String? pathOrDataUrl) async {
    if (pathOrDataUrl == null) return null;
    final trimmed = pathOrDataUrl.trim();
    if (trimmed.isEmpty) return '';

    if (DataUrl.isDataUrl(trimmed)) return trimmed;

    // Remote server relative path (e.g. "uploads/job_813.jpg")
    if (!trimmed.startsWith('/') && !trimmed.startsWith('file://') && !trimmed.contains(':\\')) {
      return trimmed;
    }

    try {
      final filePath = trimmed.startsWith('file://')
          ? Uri.parse(trimmed).toFilePath()
          : trimmed;
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final isPng = filePath.toLowerCase().endsWith('.png');
        final mime = isPng ? 'image/png' : 'image/jpeg';
        return DataUrl.encode(bytes, mimeType: mime);
      }
    } catch (_) {}

    return trimmed;
  }

  /// Synchronously converts a local file path back into a Base64 data URL.
  String? resolveToDataUrlSync(String? pathOrDataUrl) {
    if (pathOrDataUrl == null) return null;
    final trimmed = pathOrDataUrl.trim();
    if (trimmed.isEmpty) return '';

    if (DataUrl.isDataUrl(trimmed)) return trimmed;

    // Remote server relative path (e.g. "uploads/job_813.jpg")
    if (!trimmed.startsWith('/') &&
        !trimmed.startsWith('file://') &&
        !trimmed.contains(':\\')) {
      return trimmed;
    }

    try {
      final filePath = trimmed.startsWith('file://')
          ? Uri.parse(trimmed).toFilePath()
          : trimmed;
      final file = File(filePath);
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        final isPng = filePath.toLowerCase().endsWith('.png');
        final mime = isPng ? 'image/png' : 'image/jpeg';
        return DataUrl.encode(bytes, mimeType: mime);
      }
    } catch (_) {}

    return trimmed;
  }

  /// Delete a stored local file if it exists in the photos directory.
  Future<void> deletePhotoFile(String? filePath) async {
    if (filePath == null || filePath.trim().isEmpty) return;
    try {
      final file = File(filePath.trim());
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
