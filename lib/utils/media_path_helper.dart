/// Distinguishes server-hosted media URLs from on-device capture paths.
abstract final class MediaPathHelper {
  MediaPathHelper._();

  static bool isRemote(String path) {
    final trimmed = path.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  static bool isLocal(String path) => path.trim().isNotEmpty && !isRemote(path);

  static List<String> localOnly(Iterable<String> paths) =>
      paths.where(isLocal).toList();
}
