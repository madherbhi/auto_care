/// Short multipart filenames expected by the cases update API.
abstract final class MediaUploadFilename {
  MediaUploadFilename._();

  /// e.g. `image1.jpeg`, `video.mp4` — used to match unchanged server media.
  static String? slotKey(String? pathOrFileName) {
    final trimmed = pathOrFileName?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    final matches = RegExp(
      r'((?:image|video)\d*\.(?:jpe?g|png|webp|mp4|mov))',
      caseSensitive: false,
    ).allMatches(trimmed);
    if (matches.isEmpty) return null;
    return matches.last.group(1)!.toLowerCase();
  }

  static String forField(
    String field,
    int index, {
    String? serverFileName,
    String? localPath,
  }) {
    final fromServer = _normalize(serverFileName);
    if (fromServer.isNotEmpty) return fromServer;

    final fromPath = _normalize(_basename(localPath));
    if (fromPath.isNotEmpty && !_looksGenerated(fromPath)) return fromPath;

    switch (field) {
      case 'videos':
        return 'video.mp4';
      case 'rcImages':
        return index == 0 ? 'image3.jpeg' : 'image4.jpeg';
      case 'images':
      default:
        return 'image${index + 1}.jpeg';
    }
  }

  static String _normalize(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '';

    final match = RegExp(
      r'((?:image|video)\d*\.(?:jpe?g|png|webp|mp4|mov))$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (match != null) return match.group(1)!;

    if (trimmed.startsWith('upload_')) {
      final parts = trimmed.split('_');
      if (parts.length >= 2) {
        final last = parts.last;
        if (_hasKnownExtension(last)) return last;
      }
    }

    return trimmed;
  }

  static bool _looksGenerated(String name) {
    final lower = name.toLowerCase();
    return lower.startsWith('upload_') ||
        lower.startsWith('remote_media_') ||
        lower.startsWith('image_picker_');
  }

  static bool _hasKnownExtension(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov');
  }

  static String _basename(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final segments = path.split('/');
    return segments.isNotEmpty ? segments.last : path;
  }
}
