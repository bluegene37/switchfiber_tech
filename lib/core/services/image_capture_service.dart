import 'package:image_picker/image_picker.dart';
import '../utils/data_url.dart';

/// Captures a photo from the camera or gallery and returns it as a data URL
/// ready to store on a job order.
///
/// Compression mirrors the web console's dropzone (1600 px on the long edge,
/// 80 % quality) so photos taken in the field weigh the same as ones the
/// office uploads: a few hundred kilobytes, small enough to ride along in the
/// full-record PUT and the SQLite cache.
class ImageCaptureService {
  static final ImageCaptureService instance = ImageCaptureService();

  static const double maxDimension = 1600;
  static const int quality = 80;

  final ImagePicker _picker;

  ImageCaptureService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  /// Null when the technician cancels. Throws on a platform error (no camera,
  /// permission denied) so the caller can explain it.
  Future<String?> pickAsDataUrl(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
      imageQuality: quality,
      requestFullMetadata: false,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    return DataUrl.encode(bytes, mimeType: _mimeTypeFor(file));
  }

  static String _mimeTypeFor(XFile file) {
    final declared = file.mimeType;
    if (declared != null && declared.startsWith('image/')) return declared;
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
