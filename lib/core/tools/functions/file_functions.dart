import 'dart:io';
import 'dart:math';

/// Retrieves the formatted size of a file
String getFileSize(File file, int decimals) {
  int bytes = file.lengthSync();

  return bytes != 0 ? formatBytes(bytes, decimals) : '0 B';
}

/// Formats a size in bytes
String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}
