extension StringX on String {
  String truncateTo(int maxLength) => (length <= maxLength) ? this : '${substring(0, maxLength)}...';

  String kebabToCamelCase() => split('-')
      .asMap()
      .map((index, word) {
        if (index == 0) {
          return MapEntry(index, word);
        }
        return MapEntry(index, word[0].toUpperCase() + word.substring(1));
      })
      .values
      .join();

  String toPascalCase() => split(RegExp(r'[\s_]+')).map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join();

  String toCamelCase() {
    String pascalCase = toPascalCase();
    if (pascalCase.isEmpty) return '';
    return pascalCase[0].toLowerCase() + pascalCase.substring(1);
  }

  String toSnakeCase() => split(RegExp(r'[\s_]+')).map((word) => word.toLowerCase()).join('_');

  String toKebabCase() => split(RegExp(r'[\s_]+')).map((word) => word.toLowerCase()).join('-');

  String toUpperCaseFirst() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }

  String toLowerCaseFirst() {
    if (isEmpty) return '';
    return this[0].toLowerCase() + substring(1);
  }
}
