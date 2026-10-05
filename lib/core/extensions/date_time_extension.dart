import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension DateTimeX on DateTime {
  /// Combines a date with a TimeOfDay time
  DateTime? combineWithTime(TimeOfDay? time) {
    if (time == null) return null;

    try {
      return DateTime(
        year,
        month,
        day,
        time.hour,
        time.minute,
      );
    } catch (e) {
      if (kDebugMode) print('Erreur combineWithTime: $e');
      return null;
    }
  }

  /// Split a DateTime into a map {date, time}
  Map<String, dynamic>? splitToDateAndTimeMap() {
    try {
      return {
        'date': DateTime(year, month, day),
        'time': TimeOfDay(hour: hour, minute: minute),
      };
    } catch (e) {
      if (kDebugMode) print('Erreur splitToDateAndTimeMap: $e');
      return null;
    }
  }

  /// Updates a DateTime with a new date and/or time
  DateTime? mergeWith({
    DateTime? newDate,
    TimeOfDay? newTime,
  }) => DateTime(
    newDate?.year ?? year,
    newDate?.month ?? month,
    newDate?.day ?? day,
    newTime?.hour ?? hour,
    newTime?.minute ?? minute,
  );
}
