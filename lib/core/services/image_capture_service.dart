import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../utils/data_url.dart';
import 'exif_service.dart';
import 'location_service.dart';

/// Captures a photo from the camera or gallery, compresses it (1600px, 80% quality),
/// injects GPS coordinates and technician metadata into EXIF, and returns it as a data URL.
class ImageCaptureService {
  static final ImageCaptureService instance = ImageCaptureService();

  static const double maxDimension = 1600;
  static const int quality = 80;

  final ImagePicker _picker;
  final LocationService _locationService;
  final ExifService _exifService;

  ImageCaptureService({
    ImagePicker? picker,
    LocationService? locationService,
    ExifService? exifService,
  })  : _picker = picker ?? ImagePicker(),
        _locationService = locationService ?? LocationService.instance,
        _exifService = exifService ?? ExifService.instance;

  /// Null when the technician cancels.
  /// Compresses the image and embeds GPS EXIF tags directly into the JPEG file.
  Future<String?> pickAsDataUrl(
    ImageSource source, {
    double? fallbackLat,
    double? fallbackLng,
    String? technicianEmail,
  }) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
      imageQuality: quality,
      requestFullMetadata: true,
    );
    if (file == null) return null;

    Uint8List bytes = await file.readAsBytes();

    // Query current high-accuracy GPS fix from device
    double? lat = fallbackLat;
    double? lng = fallbackLng;
    double? alt;

    try {
      final pos = await _locationService.getCurrentPosition();
      if (pos != null) {
        lat = pos.latitude;
        lng = pos.longitude;
        alt = pos.altitude;
      }
    } catch (_) {}

    // Only inject GPS EXIF if a verified GPS fix or explicit coordinates were acquired.
    // Never fall back to dummy/plant center coordinates to avoid spoofing unverified locations.
    if (lat != null && lng != null) {
      bytes = _exifService.injectGpsExif(
        bytes,
        latitude: lat,
        longitude: lng,
        altitude: alt,
        timestamp: DateTime.now(),
        technicianEmail: technicianEmail,
      );
    }

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

