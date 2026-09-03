import 'dart:convert';
import 'dart:typed_data';
import 'package:exif/exif.dart';

/// Parsed EXIF metadata for an image, including GPS, timestamps, and camera details.
class ExifMetadata {
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final DateTime? captureTime;
  final String? make;
  final String? model;
  final String? software;
  final int? fileSizeBytes;
  final int? width;
  final int? height;

  const ExifMetadata({
    this.latitude,
    this.longitude,
    this.altitude,
    this.captureTime,
    this.make,
    this.model,
    this.software,
    this.fileSizeBytes,
    this.width,
    this.height,
  });

  bool get hasGps => latitude != null && longitude != null;

  String get dmsCoordinates {
    if (!hasGps) return 'No GPS fix';
    final lat = latitude!;
    final lng = longitude!;
    final latRef = lat >= 0 ? 'N' : 'S';
    final lngRef = lng >= 0 ? 'E' : 'W';

    String toDms(double val) {
      final absVal = val.abs();
      final deg = absVal.floor();
      final minVal = (absVal - deg) * 60;
      final min = minVal.floor();
      final sec = (minVal - min) * 60;
      return '$deg°$min\'${sec.toStringAsFixed(1)}"';
    }

    return '${toDms(lat)} $latRef, ${toDms(lng)} $lngRef';
  }

  String get decimalCoordinates {
    if (!hasGps) return 'No GPS fix';
    return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
  }

  String get formattedSize {
    if (fileSizeBytes == null) return '';
    final bytes = fileSizeBytes!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Service to parse and inject EXIF & GPS metadata into JPEG images.
class ExifService {
  static final ExifService instance = ExifService();

  /// Extract EXIF metadata from raw image bytes.
  Future<ExifMetadata> extractExif(Uint8List bytes) async {
    try {
      final tags = await readExifFromBytes(bytes);
      if (tags.isEmpty) {
        return ExifMetadata(fileSizeBytes: bytes.length);
      }

      double? lat;
      double? lng;
      double? alt;
      DateTime? time;
      String? make = tags['Image Make']?.printable;
      String? model = tags['Image Model']?.printable;
      String? software = tags['Image Software']?.printable;
      int? width;
      int? height;

      // Extract GPS Latitude
      if (tags.containsKey('GPS GPSLatitude') &&
          tags.containsKey('GPS GPSLatitudeRef')) {
        final latTag = tags['GPS GPSLatitude'];
        final latRef = tags['GPS GPSLatitudeRef']?.printable.toUpperCase() ?? 'N';
        final val = _parseGpsCoordinate(latTag);
        if (val != null) {
          lat = latRef.startsWith('S') ? -val : val;
        }
      }

      // Extract GPS Longitude
      if (tags.containsKey('GPS GPSLongitude') &&
          tags.containsKey('GPS GPSLongitudeRef')) {
        final lngTag = tags['GPS GPSLongitude'];
        final lngRef = tags['GPS GPSLongitudeRef']?.printable.toUpperCase() ?? 'E';
        final val = _parseGpsCoordinate(lngTag);
        if (val != null) {
          lng = lngRef.startsWith('W') ? -val : val;
        }
      }

      // Extract GPS Altitude
      if (tags.containsKey('GPS GPSAltitude')) {
        final altTag = tags['GPS GPSAltitude'];
        if (altTag != null) {
          final list = altTag.values.toList();
          if (list.isNotEmpty) {
            final first = list.first;
            if (first is Ratio) {
              alt = first.toDouble();
            } else {
              alt = double.tryParse(first.toString());
            }
          }
        }
      }

      // Extract Date/Time
      final dateTag = tags['EXIF DateTimeOriginal'] ??
          tags['Image DateTime'] ??
          tags['EXIF DateTimeDigitized'];
      if (dateTag != null) {
        final dateStr = dateTag.printable;
        // Format is typically "YYYY:MM:DD HH:MM:SS"
        final parts = dateStr.split(' ');
        if (parts.length == 2) {
          final d = parts[0].replaceAll(':', '-');
          time = DateTime.tryParse('${d}T${parts[1]}');
        }
      }

      // Dimensions
      final wTag = tags['EXIF ExifImageWidth'] ?? tags['Image ImageWidth'];
      final hTag = tags['EXIF ExifImageLength'] ?? tags['Image ImageLength'];
      if (wTag != null) width = int.tryParse(wTag.printable);
      if (hTag != null) height = int.tryParse(hTag.printable);

      return ExifMetadata(
        latitude: lat,
        longitude: lng,
        altitude: alt,
        captureTime: time,
        make: make,
        model: model,
        software: software,
        fileSizeBytes: bytes.length,
        width: width,
        height: height,
      );
    } catch (_) {
      return ExifMetadata(fileSizeBytes: bytes.length);
    }
  }

  double? _parseGpsCoordinate(IfdTag? tag) {
    if (tag == null) return null;
    try {
      final list = tag.values.toList();
      if (list.length >= 3) {
        double toDouble(dynamic item) {
          if (item is Ratio) return item.toDouble();
          return double.parse(item.toString());
        }

        final deg = toDouble(list[0]);
        final min = toDouble(list[1]);
        final sec = toDouble(list[2]);
        return deg + (min / 60.0) + (sec / 3600.0);
      }
    } catch (_) {}
    return null;
  }

  /// Inject GPS coordinates and technician metadata into a JPEG image as an APP1 EXIF segment.
  Uint8List injectGpsExif(
    Uint8List jpegBytes, {
    required double latitude,
    required double longitude,
    double? altitude,
    DateTime? timestamp,
    String? technicianEmail,
  }) {
    if (jpegBytes.length < 4 || jpegBytes[0] != 0xFF || jpegBytes[1] != 0xD8) {
      // Not a JPEG image, return as-is
      return jpegBytes;
    }

    final now = (timestamp ?? DateTime.now()).toUtc();
    final localNow = timestamp ?? DateTime.now();

    // Build the TIFF/EXIF payload
    final exifPayload = _buildExifPayload(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude ?? 15.0,
      utcTime: now,
      localTime: localNow,
      techEmail: technicianEmail,
    );

    // APP1 Header: 0xFF, 0xE1, Length (2 bytes big endian)
    final app1Length = exifPayload.length + 2;
    final app1Header = Uint8List(4);
    app1Header[0] = 0xFF;
    app1Header[1] = 0xE1;
    app1Header[2] = (app1Length >> 8) & 0xFF;
    app1Header[3] = app1Length & 0xFF;

    // Scan for existing APP1 or insertion point right after SOI (0xFF, 0xD8)
    int insertIndex = 2;

    // Check if there is already an APP0 or APP1 segment
    while (insertIndex + 4 < jpegBytes.length && jpegBytes[insertIndex] == 0xFF) {
      final marker = jpegBytes[insertIndex + 1];
      if (marker == 0xE1) {
        // Replace existing APP1 marker
        final segLen = (jpegBytes[insertIndex + 2] << 8) | jpegBytes[insertIndex + 3];
        final nextIndex = insertIndex + 2 + segLen;

        final builder = BytesBuilder();
        builder.add(jpegBytes.sublist(0, insertIndex));
        builder.add(app1Header);
        builder.add(exifPayload);
        if (nextIndex < jpegBytes.length) {
          builder.add(jpegBytes.sublist(nextIndex));
        }
        return builder.toBytes();
      }

      if (marker == 0xE0) {
        // Skip APP0 JFIF, insert after it
        final segLen = (jpegBytes[insertIndex + 2] << 8) | jpegBytes[insertIndex + 3];
        insertIndex += 2 + segLen;
      } else {
        break;
      }
    }

    // Insert APP1 right at insertIndex
    final builder = BytesBuilder();
    builder.add(jpegBytes.sublist(0, insertIndex));
    builder.add(app1Header);
    builder.add(exifPayload);
    builder.add(jpegBytes.sublist(insertIndex));
    return builder.toBytes();
  }

  Uint8List _buildExifPayload({
    required double latitude,
    required double longitude,
    required double altitude,
    required DateTime utcTime,
    required DateTime localTime,
    String? techEmail,
  }) {
    // Little-endian TIFF format ('II')
    final bb = BytesBuilder();

    // 1. Exif header: 'Exif\0\0' (6 bytes)
    bb.add([0x45, 0x78, 0x69, 0x66, 0x00, 0x00]);

    // TIFF Header starts at offset 0 of the TIFF block
    // Byte order: II (0x49, 0x49)
    // 42 test: 0x2A, 0x00
    // Offset to IFD0: 0x08, 0x00, 0x00, 0x00 (8 bytes)
    final tiffHeader = Uint8List.fromList([
      0x49, 0x49,
      0x2A, 0x00,
      0x08, 0x00, 0x00, 0x00,
    ]);

    // Data area buffer (holds strings and RATIONALs)
    final dataArea = BytesBuilder();

    // Coordinates conversion
    final latRef = latitude >= 0 ? 'N' : 'S';
    final lngRef = longitude >= 0 ? 'E' : 'W';
    final absLat = latitude.abs();
    final absLng = longitude.abs();

    final latDeg = absLat.floor();
    final latMinVal = (absLat - latDeg) * 60;
    final latMin = latMinVal.floor();
    final latSec = ((latMinVal - latMin) * 60 * 100).round();

    final lngDeg = absLng.floor();
    final lngMinVal = (absLng - lngDeg) * 60;
    final lngMin = lngMinVal.floor();
    final lngSec = ((lngMinVal - lngMin) * 60 * 100).round();

    // Format DateTime string: "YYYY:MM:DD HH:MM:SS\0" (20 bytes)
    String pad2(int n) => n.toString().padLeft(2, '0');
    final dtStr = '${localTime.year}:${pad2(localTime.month)}:${pad2(localTime.day)} '
        '${pad2(localTime.hour)}:${pad2(localTime.minute)}:${pad2(localTime.second)}\x00';
    final dateStampStr = '${utcTime.year}:${pad2(utcTime.month)}:${pad2(utcTime.day)}\x00';

    // Structure layout:
    // TIFF Header: 8 bytes (offset 0..7)
    // IFD0: 2 bytes count + 5 entries * 12 bytes + 4 bytes next offset = 66 bytes (offset 8..73)
    // GPS IFD: 2 bytes count + 9 entries * 12 bytes + 4 bytes next offset = 114 bytes (offset 74..187)
    // Data Area starts at offset 188
    const int tiffHeaderLen = 8;
    const int ifd0EntryCount = 5;
    const int ifd0Len = 2 + (ifd0EntryCount * 12) + 4; // 66 bytes
    final int gpsIfdOffset = tiffHeaderLen + ifd0Len; // 74
    const int gpsIfdEntryCount = 9;
    const int gpsIfdLen = 2 + (gpsIfdEntryCount * 12) + 4; // 114 bytes
    final int dataAreaBaseOffset = gpsIfdOffset + gpsIfdLen; // 188

    int addData(Uint8List bytes) {
      final offset = dataAreaBaseOffset + dataArea.length;
      dataArea.add(bytes);
      return offset;
    }

    // Allocate data items
    final makeBytes = utf8.encode('Switch Fiber\x00');
    final modelBytes = utf8.encode('Field Terminal\x00');
    final softwareBytes = utf8.encode('SwitchFiber Tech v1.0\x00');
    final dtBytes = utf8.encode(dtStr);
    final dateStampBytes = utf8.encode(dateStampStr);

    final makeOffset = addData(Uint8List.fromList(makeBytes));
    final modelOffset = addData(Uint8List.fromList(modelBytes));
    final softwareOffset = addData(Uint8List.fromList(softwareBytes));
    final dtOffset = addData(Uint8List.fromList(dtBytes));
    final dateStampOffset = addData(Uint8List.fromList(dateStampBytes));

    // RATIONAL: GPS Latitude (deg/1, min/1, sec/100)
    final latBytes = Uint8List(24);
    final latBd = ByteData.sublistView(latBytes);
    latBd.setUint32(0, latDeg, Endian.little);
    latBd.setUint32(4, 1, Endian.little);
    latBd.setUint32(8, latMin, Endian.little);
    latBd.setUint32(12, 1, Endian.little);
    latBd.setUint32(16, latSec, Endian.little);
    latBd.setUint32(20, 100, Endian.little);
    final latOffset = addData(latBytes);

    // RATIONAL: GPS Longitude (deg/1, min/1, sec/100)
    final lngBytes = Uint8List(24);
    final lngBd = ByteData.sublistView(lngBytes);
    lngBd.setUint32(0, lngDeg, Endian.little);
    lngBd.setUint32(4, 1, Endian.little);
    lngBd.setUint32(8, lngMin, Endian.little);
    lngBd.setUint32(12, 1, Endian.little);
    lngBd.setUint32(16, lngSec, Endian.little);
    lngBd.setUint32(20, 100, Endian.little);
    final lngOffset = addData(lngBytes);

    // RATIONAL: Altitude (meters * 10 / 10)
    final altBytes = Uint8List(8);
    final altBd = ByteData.sublistView(altBytes);
    altBd.setUint32(0, (altitude * 10).round(), Endian.little);
    altBd.setUint32(4, 10, Endian.little);
    final altOffset = addData(altBytes);

    // RATIONAL: TimeStamp (UTC hour/1, min/1, sec/1)
    final timeBytes = Uint8List(24);
    final timeBd = ByteData.sublistView(timeBytes);
    timeBd.setUint32(0, utcTime.hour, Endian.little);
    timeBd.setUint32(4, 1, Endian.little);
    timeBd.setUint32(8, utcTime.minute, Endian.little);
    timeBd.setUint32(12, 1, Endian.little);
    timeBd.setUint32(16, utcTime.second, Endian.little);
    timeBd.setUint32(20, 1, Endian.little);
    final timeOffset = addData(timeBytes);

    // Build IFD0
    final ifd0Bytes = Uint8List(ifd0Len);
    final ifd0Bd = ByteData.sublistView(ifd0Bytes);
    ifd0Bd.setUint16(0, ifd0EntryCount, Endian.little);

    void writeEntry(ByteData bd, int index, int tag, int type, int count, int valOrOffset) {
      final pos = 2 + (index * 12);
      bd.setUint16(pos, tag, Endian.little);
      bd.setUint16(pos + 2, type, Endian.little);
      bd.setUint32(pos + 4, count, Endian.little);
      bd.setUint32(pos + 8, valOrOffset, Endian.little);
    }

    // IFD0 entries: Make, Model, Software, DateTime, GPSIFDPointer
    writeEntry(ifd0Bd, 0, 0x010F, 2, makeBytes.length, makeOffset);
    writeEntry(ifd0Bd, 1, 0x0110, 2, modelBytes.length, modelOffset);
    writeEntry(ifd0Bd, 2, 0x0131, 2, softwareBytes.length, softwareOffset);
    writeEntry(ifd0Bd, 3, 0x0132, 2, dtBytes.length, dtOffset);
    writeEntry(ifd0Bd, 4, 0x8825, 4, 1, gpsIfdOffset); // GPS Pointer
    ifd0Bd.setUint32(2 + (ifd0EntryCount * 12), 0, Endian.little); // Next IFD = 0

    // Build GPS IFD
    final gpsIfdBytes = Uint8List(gpsIfdLen);
    final gpsBd = ByteData.sublistView(gpsIfdBytes);
    gpsBd.setUint16(0, gpsIfdEntryCount, Endian.little);

    // 0: GPSVersionID (0x0000, BYTE, count 4, value 2.3.0.0)
    final vBytes = Uint8List(4)..[0] = 2..[1] = 3..[2] = 0..[3] = 0;
    writeEntry(gpsBd, 0, 0x0000, 1, 4, ByteData.sublistView(vBytes).getUint32(0, Endian.little));

    // 1: GPSLatitudeRef (0x0001, ASCII, count 2, 'N\0')
    final latRefBytes = Uint8List(4)..[0] = latRef.codeUnitAt(0)..[1] = 0;
    writeEntry(gpsBd, 1, 0x0001, 2, 2, ByteData.sublistView(latRefBytes).getUint32(0, Endian.little));

    // 2: GPSLatitude (0x0002, RATIONAL, count 3, latOffset)
    writeEntry(gpsBd, 2, 0x0002, 5, 3, latOffset);

    // 3: GPSLongitudeRef (0x0003, ASCII, count 2, 'E\0')
    final lngRefBytes = Uint8List(4)..[0] = lngRef.codeUnitAt(0)..[1] = 0;
    writeEntry(gpsBd, 3, 0x0003, 2, 2, ByteData.sublistView(lngRefBytes).getUint32(0, Endian.little));

    // 4: GPSLongitude (0x0004, RATIONAL, count 3, lngOffset)
    writeEntry(gpsBd, 4, 0x0004, 5, 3, lngOffset);

    // 5: GPSAltitudeRef (0x0005, BYTE, count 1, value 0)
    writeEntry(gpsBd, 5, 0x0005, 1, 1, 0);

    // 6: GPSAltitude (0x0006, RATIONAL, count 1, altOffset)
    writeEntry(gpsBd, 6, 0x0006, 5, 1, altOffset);

    // 7: GPSTimeStamp (0x0007, RATIONAL, count 3, timeOffset)
    writeEntry(gpsBd, 7, 0x0007, 5, 3, timeOffset);

    // 8: GPSDateStamp (0x001D, ASCII, count 11, dateStampOffset)
    writeEntry(gpsBd, 8, 0x001D, 2, dateStampBytes.length, dateStampOffset);

    gpsBd.setUint32(2 + (gpsIfdEntryCount * 12), 0, Endian.little); // Next IFD = 0

    // Assemble final TIFF payload
    bb.add(tiffHeader);
    bb.add(ifd0Bytes);
    bb.add(gpsIfdBytes);
    bb.add(dataArea.toBytes());

    return bb.toBytes();
  }
}
