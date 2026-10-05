import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/i18n/translations.g.dart';

class TimeUtils {
  ///
  static String get _localeLang => LocaleSettings.instance.currentLocale.languageCode == 'fr' ? 'fr_FR' : 'en_US';

  static String? dateTimeToStr2(
    DateTime dateTime, {
    String outPattern = defaultPattern,
  }) {
    try {
      return DateFormat(outPattern, _localeLang).format(dateTime);
    } catch (e) {
      if (kDebugMode) print(e);
      return null;
    }
  }

  static bool compare2TimeOfDay(TimeOfDay a, TimeOfDay b) => a.hour < b.hour || (a.hour == b.hour && a.minute < b.minute);

  static String formatTimeOfDay(
    TimeOfDay time, {
    String? pattern,
  }) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    final effectivePattern = pattern ?? (_localeLang == 'fr_FR' ? 'HH:mm' : 'hh:mm a');

    return DateFormat(effectivePattern, _localeLang).format(dt);
  }

  /// ----------------------------------------------

  static const String defaultPattern = 'dd-MM-yyyy HH:mm:ss';
  static const String userFriendlyFirstPattern = 'dd MMM yyyy HH:mm';
  static const String userFriendlySecondPattern = 'dd MMMM yyyy HH:mm';

  static DateTime nowDateTime() => DateFormat(defaultPattern).parse(nowString());

  static String nowString({String outPattern = defaultPattern}) => DateFormat(outPattern).format(DateTime.now());

  static String? dateTimeToStr(
    DateTime dateTime, {
    String outPattern = defaultPattern,
  }) {
    try {
      return DateFormat(
        outPattern,
        LocaleSettings.instance.currentLocale.languageCode,
      ).format(dateTime);
    } catch (e) {
      if (kDebugMode) print(e);
      return null;
    }
  }

  static DateTime? strToDateTime(
    String dateStr, {
    String inPattern = defaultPattern,
    String? locale,
  }) {
    try {
      return DateFormat(inPattern, locale).parse(dateStr);
    } catch (e) {
      if (kDebugMode) print(e);
      return null;
    }
  }

  static TimeDifference getStrDateTimeDifferenceFromNow(
    String start, {
    required String startPattern,
    DifferenceUnit unit = DifferenceUnit.auto,
    bool alwaysPositive = true,
    bool rounded = true,
  }) => getDateTimeDifference(
    strToDateTime(start, inPattern: startPattern)!,
    DateTime.now(),
    unit: unit,
    alwaysPositive: alwaysPositive,
    rounded: rounded,
  );

  static TimeDifference getStrDateTimeDifference(
    String start,
    String end, {
    required String startPattern,
    required String endPattern,
    DifferenceUnit unit = DifferenceUnit.auto,
    bool alwaysPositive = true,
    bool rounded = true,
  }) => getDateTimeDifference(
    strToDateTime(start, inPattern: startPattern)!,
    strToDateTime(end, inPattern: endPattern)!,
    unit: unit,
    alwaysPositive: alwaysPositive,
    rounded: rounded,
  );

  static TimeDifference getDateTimeDifferenceFromNow(
    DateTime start, {
    DifferenceUnit unit = DifferenceUnit.auto,
    bool alwaysPositive = true,
    bool rounded = true,
  }) => getDateTimeDifference(
    start,
    DateTime.now(),
    unit: unit,
    alwaysPositive: alwaysPositive,
    rounded: rounded,
  );

  static TimeDifference getDateTimeDifference(
    DateTime start,
    DateTime end, {
    DifferenceUnit unit = DifferenceUnit.auto,
    bool alwaysPositive = true,
    bool rounded = true,
  }) {
    try {
      Duration duration = end.difference(start);

      return _switchDifferenceUnit(duration, unit, alwaysPositive, rounded);
    } catch (e) {
      if (kDebugMode) print('Time Master Difference Calculation Error : $e');

      return TimeDifference();
    }
  }

  static TimeDifference _switchDifferenceUnit(
    Duration duration,
    DifferenceUnit unit,
    bool positive,
    bool rounded,
  ) {
    TimeDifference difference = TimeDifference()
      ..unit = unit
      ..rounded = rounded;

    switch (unit) {
      case DifferenceUnit.seconds:
        difference.duration = duration.inSeconds;

      case DifferenceUnit.minutes:
        difference.duration = duration.inMinutes;

      case DifferenceUnit.hours:
        difference.duration = duration.inHours;

      case DifferenceUnit.days:
        difference.duration = duration.inDays;

      case DifferenceUnit.weeks:
        difference.duration = duration.inDays / 7;

      case DifferenceUnit.months:
        difference.duration = duration.inDays / 30;

      case DifferenceUnit.years:
        difference.duration = duration.inDays / 365;

      default:
        if (duration.inSeconds <= 60) {
          difference
            ..duration = duration.inSeconds
            ..unit = DifferenceUnit.seconds;
        } else if (duration.inSeconds > 60 && duration.inMinutes <= 60) {
          difference
            ..duration = duration.inMinutes
            ..unit = DifferenceUnit.minutes;
        } else if (duration.inMinutes > 60 && duration.inHours <= 24) {
          difference
            ..duration = duration.inHours
            ..unit = DifferenceUnit.hours;
        } else if (duration.inHours > 24 && duration.inDays <= 7) {
          difference
            ..duration = duration.inDays
            ..unit = DifferenceUnit.days;
        } else if (duration.inDays > 7 && duration.inDays <= 30) {
          difference
            ..duration = duration.inDays / 7
            ..unit = DifferenceUnit.weeks;
        } else if (duration.inDays > 30 && duration.inDays <= 365) {
          difference
            ..duration = duration.inDays / 30
            ..unit = DifferenceUnit.months;
        } else if (duration.inDays > 365) {
          difference
            ..duration = duration.inDays / 365
            ..unit = DifferenceUnit.years;
        } else {
          difference.duration = 0;
        }
    }

    difference
      ..duration = rounded ? difference.duration!.round() : difference.duration
      ..duration = positive ? difference.duration!.abs() : difference.duration;

    return difference;
  }

  static String formatTimeDifference(
    TimeDifference timeDifference, {
    String secondsUnitStr = 'second(s)',
    String minutesUnitStr = 'minute(s)',
    String hoursUnitStr = 'hour(s)',
    String daysUnitStr = 'day(s)',
    String weeksUnitStr = 'week(s)',
    String monthsUnitStr = 'month(s)',
    String yearsUnitStr = 'year(s)',
  }) {
    String suffix;

    switch (timeDifference.unit) {
      case DifferenceUnit.seconds:
        suffix = secondsUnitStr;

      case DifferenceUnit.minutes:
        suffix = minutesUnitStr;

      case DifferenceUnit.hours:
        suffix = hoursUnitStr;

      case DifferenceUnit.days:
        suffix = daysUnitStr;

      case DifferenceUnit.weeks:
        suffix = weeksUnitStr;

      case DifferenceUnit.months:
        suffix = monthsUnitStr;

      case DifferenceUnit.years:
        suffix = yearsUnitStr;

      default:
        suffix = '';
    }

    return '${timeDifference.duration} $suffix';
  }
}

class TimeDifference {
  num? duration;
  bool rounded;
  DifferenceUnit? unit;

  TimeDifference({this.duration, this.unit, this.rounded = false});
}

enum DifferenceUnit {
  seconds,
  minutes,
  hours,
  days,
  weeks,
  months,
  years,
  auto,
}
