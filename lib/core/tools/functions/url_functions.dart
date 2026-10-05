import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../enums/image_size.dart';
import '../../services/api/config.dart';

// Validates http/https URLs: domains, IPv4, IPv6, IDN, ports
// [allowLocal] accepts localhost, loopback IPs, and private network ranges
bool isUrl(String value, {bool allowLocal = false}) {
  if (value.isEmpty || value.length > 2048) return false;

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.isAbsolute) return false;

  if (!['http', 'https'].contains(uri.scheme)) return false;

  if (uri.hasPort && (uri.port < 1 || uri.port > 65535)) return false;

  final host = uri.host;
  if (host.isEmpty) return false;

  // IPv6
  if (host.contains(':')) {
    if (!allowLocal && isLocalIPv6(host)) return false;
    return true;
  }

  // IPv4
  final ipv4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
  if (ipv4.hasMatch(host)) {
    final octets = host.split('.').map(int.tryParse).toList();
    if (octets.any((n) => n == null || n > 255)) return false;
    if (!allowLocal && isLocalIPv4(octets.cast<int>())) return false;
    return true;
  }

  // Bare hostname (localhost, intranet, etc.)
  if (!host.contains('.')) {
    return allowLocal; // "localhost", "mydevbox", etc.
  }

  // Hostname validation
  if (host.startsWith('.') || host.endsWith('.') || host.contains('..')) {
    return false;
  }

  final labels = host.split('.');
  final asciiLabel = RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?$|^[a-zA-Z0-9]$');
  for (final label in labels) {
    if (label.isEmpty) return false;
    if (label.codeUnits.every((c) => c < 128) && !asciiLabel.hasMatch(label)) {
      return false;
    }
  }

  return true;
}

// 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 127.0.0.0/8, 169.254.0.0/16
bool isLocalIPv4(List<int> o) =>
    o[0] == 127 || o[0] == 10 || (o[0] == 172 && o[1] >= 16 && o[1] <= 31) || (o[0] == 192 && o[1] == 168) || (o[0] == 169 && o[1] == 254); // link-local

// ::1, fc00::/7 (ULA), fe80::/10 (link-local)
bool isLocalIPv6(String host) {
  final h = host.toLowerCase();
  return h == '::1' || h.startsWith('fc') || h.startsWith('fd') || h.startsWith('fe80');
}

/// Encoding a file path to a URL.
String fileUrl(String path) {
  if (path.isNotEmpty) {
    String encodedPath = Uri.encodeFull(path);

    if (isUrl(encodedPath)) {
      return encodedPath;
    } else {
      return '${ApiConfig.baseUrl}/storage/$encodedPath';
    }
  }

  return '';
}

/// Resolve an URL from a given path.
String resolveUrl(String path) {
  String encodedPath = Uri.encodeFull(path);

  if (isUrl(encodedPath)) {
    return encodedPath;
  } else {
    return '${ApiConfig.baseUrl}/${removeLeadingSlash(encodedPath)}';
  }
}

/// Retrieves an image URL based on the specified path and size.
Future<String> getImageUrl(
  String path, {
  ImageSize size = ImageSize.original,
  String thumbnailsPath = 'thumbnails',
}) async {
  const checkableSizes = [ImageSize.small, ImageSize.medium, ImageSize.large];
  final imageName = path.split('/').last;
  var canUseIt = false;

  for (final checkableSize in checkableSizes) {
    if (checkableSize == size) canUseIt = true;

    if (canUseIt) {
      try {
        final url = fileUrl('$thumbnailsPath/${checkableSize.size}/$imageName');
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          return url;
        }
      } catch (error) {
        // If an error occurs (e.g., 404 Not Found), continue to the next link
      }
    }
  }

  return fileUrl(path);
}

/// Retrieves an video thumbnail URL based on the specified path.
Future<String> getVideoThumbnailUrl(
  String path, {
  String fallbackPath = '',
  String thumbnailsPath = 'thumbnails',
}) async {
  final videoName = p.basenameWithoutExtension(path);

  try {
    final url = fileUrl('$thumbnailsPath/video/$videoName.jpg');
    final response = await http.head(Uri.parse(url));
    if (response.statusCode == 200) {
      return url;
    }
  } catch (error) {
    //
  }

  return fileUrl(fallbackPath);
}

/// Removes the leading slash from a given path.
String removeLeadingSlash(String path) {
  if (path.startsWith('/')) {
    return path.substring(1);
  }
  return path;
}
