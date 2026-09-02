import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(hint),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: Text(_hasValue ? 'Retake photo' : 'Take photo'),
                onTap: () => Navigator.of(ctx).pop(_PhotoAction.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(ctx).pop(_PhotoAction.gallery),
              ),
              if (bytes != null)
                ListTile(
                  leading: const Icon(Icons.zoom_in_rounded),
                  title: const Text('View photo'),
                  onTap: () => Navigator.of(ctx).pop(_PhotoAction.view),
                ),
              if (_hasValue)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
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
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(6),
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
                        ? Icons.check_circle_rounded
                        : Icons.add_a_photo_outlined,
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

/// Full-screen, pinch-to-zoom view of an inline image.
Future<void> showPhotoViewer(BuildContext context, Uint8List bytes,
    {required String title}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(title, style: const TextStyle(fontSize: 16)),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
        ),
      ),
    ),
  );
}
