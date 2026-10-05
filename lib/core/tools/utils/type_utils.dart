import '../../helpers/logging/log_helper.dart';

/// Logs whether each key in the given map corresponds to a numeric
/// value (either a num or a String containing a number) or not.
///
/// If the value is a num, logs '✅ "$key" is a num: $value'.
/// If the value is a String containing a number, logs
/// '⚠️ "$key" is a String containing a number: "$value"'.
/// Otherwise, logs '❌ "$key" is not a num: $value (${value.runtimeType})'.
void detectNumericFields(Map<String, dynamic> data) {
  data.forEach((key, value) {
    if (value is num) {
      LogHelper.i('✅ "$key" is a num: $value');
    } else if (value is String && num.tryParse(value) != null) {
      LogHelper.i('⚠️ "$key" is a String containing a number: "$value"');
    } else {
      LogHelper.i('❌ "$key" is not a num: $value (${value.runtimeType})');
    }
  });
}

/// Example usage:
///
/// ```dart
/// newItems = safeParseList(
///   response.data as List,
///   (item) => UserModel.fromJson(item),
///   debugLabel: 'UserModel',
/// );
/// ```
List<T> safeParseList<T>(
  List<dynamic> rawList,
  T Function(Map<String, dynamic>) fromJsonFn, {
  String? debugLabel,
}) {
  try {
    return rawList.map((item) {
      if (item is Map<String, dynamic>) {
        return fromJsonFn(item);
      } else {
        throw FormatException('Unexpected element: $item');
      }
    }).toList();
  } catch (e, stack) {
    final label = debugLabel ?? T.toString();
    LogHelper.i('⛔ Error parsing $label: $e');
    LogHelper.w(stack);
    rethrow;
  }
}

/// Safely converts a given value to the given target type.
///
/// If the value is null, returns null.
///
/// If the value is already of the target type, returns the value.
///
/// If the value is a String containing a number, attempts to parse the
/// value to the target type. If the parse fails, logs an error and
/// returns null.
///
/// If the value is of a different type, logs an error and returns null.
///
/// Supported target types are 'int', 'double', and 'num'.
dynamic safeConvertTo(String targetType, dynamic value) {
  if (value == null) return null;

  try {
    switch (targetType) {
      case 'int':
        if (value is int) return value;
        return int.tryParse(value.toString());

      case 'double':
        if (value is double) return value;
        return double.tryParse(value.toString());

      case 'num':
        if (value is num) return value;
        return num.tryParse(value.toString());

      default:
        throw ArgumentError('Unsupported target type: $targetType');
    }
  } catch (e) {
    LogHelper.e('Conversion error: $e');
    return null;
  }
}
