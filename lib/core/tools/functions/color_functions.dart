import 'dart:math';
import 'dart:ui';

import 'string_functions.dart';

/// Generate color from hash
Color generateColorFromName(String name) {
  int hash = hashString(name);
  Random random = Random(hash);
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

/// Determine if a color is dark
bool isColorDark(Color color) {
  double luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
  return luminance < 0.5;
}
