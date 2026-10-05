extension DoubleX on double {
  String format() {
    if (this == toInt()) {
      return toInt().toString();
    } else {
      return toString();
    }
  }
}
