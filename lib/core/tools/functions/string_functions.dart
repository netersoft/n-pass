// Replace backslashes followed by a single quote with just the single quote
String fixEscapeSequences(String input) => input.replaceAll(r"\'", "'");

/// Generates the initials of a given name.
String getNameInitials(String name) {
  List<String> nameParts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

  if (nameParts.isEmpty) return '';

  if (nameParts.length > 1) {
    return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
  }

  return nameParts[0][0].toUpperCase();
}

/// Hash function
int hashString(String input) {
  int hash = 0;
  for (int i = 0; i < input.length; i++) {
    hash = (31 * hash + input.codeUnitAt(i)) & 0x7FFFFFFF;
  }
  return hash;
}
