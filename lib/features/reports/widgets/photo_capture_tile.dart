import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/exif_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/data_url.dart';

/// Picks a photo from the camera or gallery for one image field.
///
/// Shows a thumbnail once a data URL is held, a "stored on server" state for
/// values the app cannot render (paths uploaded from the web console), and an
/// empty prompt otherwise. Tapping opens a sheet with capture, view and
/// remove actions. [pick] is injected so tests can supply an image without a
/// device camera.
class PhotoCaptureTile extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final Future<String?> Function(ImageSource source) pick;
  final ValueChanged<String?> onChanged;

  const PhotoCaptureTile({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.pick,
    required this.onChanged,
  });

  bool get _hasValue => value?.trim().isNotEmpty == true;

  Future<void> _capture(BuildContext context, ImageSource source) async {
    try {
      final result = await pick(source);
      if (result == null) return;
      onChanged(result);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Could not open the camera. Check the app\'s camera permission.'
                : 'Could not open the photo library.',
          ),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showActions(BuildContext context) async {
    final bytes = DataUrl.decode(value);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // iOS Grabber Pill
              Center(
                child: Container(
                  width: 36,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF38383A)
                        : const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(hint),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.camera_fill,
                    color: AppTheme.primary),
                title: Text(_hasValue ? 'Retake photo' : 'Take photo with GPS'),
                onTap: () => Navigator.of(ctx).pop(_PhotoAction.camera),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.photo_fill,
                    color: Color(0xFF0070BA)),
                title: const Text('Choose from photo library'),
                onTap: () => Navigator.of(ctx).pop(_PhotoAction.gallery),
              ),
              if (bytes != null)
                ListTile(
                  leading: const Icon(CupertinoIcons.info_circle_fill,
                      color: AppTheme.success),
                  title: const Text('View photo & EXIF details'),
                  onTap: () => Navigator.of(ctx).pop(_PhotoAction.view),
                ),
              if (_hasValue)
                ListTile(
                  leading: const Icon(CupertinoIcons.trash,
                      color: AppTheme.danger),
                  title: const Text('Remove photo',
                      style: TextStyle(color: AppTheme.danger)),
                  onTap: () => Navigator.of(ctx).pop(_PhotoAction.remove),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case _PhotoAction.camera:
        await _capture(context, ImageSource.camera);
      case _PhotoAction.gallery:
        await _capture(context, ImageSource.gallery);
      case _PhotoAction.view:
        await showPhotoViewer(context, bytes!, title: label);
      case _PhotoAction.remove:
        onChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;
    final bytes = DataUrl.decode(value);
    final onServer = _hasValue && bytes == null;

    return InkWell(
      onTap: () => _showActions(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasValue
                ? AppTheme.success.withValues(alpha: 0.6)
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: _hasValue ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: bytes != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(bytes,
                            fit: BoxFit.cover, gaplessPlayback: true),
                        // GPS Badge
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.location_fill,
                                    color: Colors.white, size: 9),
                                SizedBox(width: 3),
                                Text(
                                  'GPS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Size Badge
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              DataUrl.formatBytes(DataUrl.approxBytes(value!)),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            onServer ? Icons.cloud_done_rounded : icon,
                            size: 28,
                            color: onServer ? AppTheme.success : muted,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            onServer ? 'Stored on server' : 'Tap to add photo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: onServer ? AppTheme.success : muted,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _hasValue
                        ? CupertinoIcons.checkmark_seal_fill
                        : CupertinoIcons.camera,
                    size: 16,
                    color: _hasValue ? AppTheme.success : muted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PhotoAction { camera, gallery, view, remove }

/// Full-screen, pinch-to-zoom view of an inline image with EXIF inspector.
Future<void> showPhotoViewer(
  BuildContext context,
  Uint8List bytes, {
  required String title,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (ctx) => _PhotoViewerScreen(bytes: bytes, title: title),
    ),
  );
}

class _PhotoViewerScreen extends StatefulWidget {
  final Uint8List bytes;
  final String title;

  const _PhotoViewerScreen({required this.bytes, required this.title});

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  ExifMetadata? _metadata;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExif();
  }

  Future<void> _loadExif() async {
    final meta = await ExifService.instance.extractExif(widget.bytes);
    if (!mounted) return;
    setState(() {
      _metadata = meta;
      _loading = false;
    });
  }

  void _showExifDetails() {
    final meta = _metadata;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // iOS Grabber Pill
              Center(
                child: Container(
                  width: 36,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF38383A)
                        : const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.info_circle_fill,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Photo EXIF Metadata',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 13,
                        color: isDark ? Colors.white : AppTheme.darkSlate,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location Section
              _buildMetaGroup(
                isDark: isDark,
                title: 'LOCATION & GPS',
                children: [
                  _MetaRow(
                    icon: CupertinoIcons.location_solid,
                    label: 'Coordinates',
                    value: meta?.dmsCoordinates ?? 'No GPS Recorded',
                    color: meta?.hasGps == true
                        ? AppTheme.success
                        : AppTheme.textMuted,
                  ),
                  if (meta?.hasGps == true) ...[
                    _MetaRow(
                      icon: CupertinoIcons.map_pin_ellipse,
                      label: 'Decimal',
                      value: meta!.decimalCoordinates,
                    ),
                    if (meta.altitude != null)
                      _MetaRow(
                        icon: CupertinoIcons.arrow_up_circle,
                        label: 'Altitude',
                        value: '${meta.altitude!.toStringAsFixed(1)} m above sea level',
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Capture & Device Info
              _buildMetaGroup(
                isDark: isDark,
                title: 'TIMESTAMP & DEVICE',
                children: [
                  _MetaRow(
                    icon: CupertinoIcons.time,
                    label: 'Captured At',
                    value: meta?.captureTime != null
                        ? DateFormat('MMM d, yyyy  h:mm:ss a').format(meta!.captureTime!)
                        : 'Current field capture',
                  ),
                  _MetaRow(
                    icon: CupertinoIcons.device_phone_portrait,
                    label: 'Hardware / App',
                    value: meta?.software ?? 'SwitchFiber Tech Terminal',
                  ),
                  _MetaRow(
                    icon: CupertinoIcons.doc_text,
                    label: 'File Size (Compressed)',
                    value: meta?.formattedSize.isNotEmpty == true
                        ? '${meta!.formattedSize} (Optimized for upload)'
                        : '${DataUrl.formatBytes(widget.bytes.length)} (Compressed)',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // External Maps Action
              if (meta?.hasGps == true)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onPressed: () {
                      final url = Uri.parse(
                          'https://maps.apple.com/?q=${meta!.latitude},${meta.longitude}');
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.map, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Open Location in Maps',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaGroup({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 40,
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            tooltip: 'View Photo EXIF Metadata',
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(CupertinoIcons.info_circle, size: 22),
            onPressed: _loading ? null : _showExifDetails,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: Image.memory(widget.bytes, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppTheme.textMuted),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

