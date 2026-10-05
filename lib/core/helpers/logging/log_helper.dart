import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

String _toPrettier(Object message) {
  final input = message.toString().trim();

  if (!input.startsWith('{') && !input.startsWith('[')) {
    return input;
  }

  try {
    final decoded = jsonDecode(input);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    return input;
  }
}

abstract class LogHelper {
  static Logger instance = Logger(
    printer: PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void t(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
    bool usePrettier = true,
    bool onlyInDebug = true,
  }) => (onlyInDebug && kDebugMode) || !onlyInDebug
      ? instance.t(
          usePrettier ? _toPrettier(message) : message,
          error: error,
          stackTrace: stackTrace,
          time: time,
        )
      : null;

  static void d(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
    bool usePrettier = true,
    bool onlyInDebug = false,
  }) => (onlyInDebug && kDebugMode) || !onlyInDebug
      ? instance.d(
          usePrettier ? _toPrettier(message) : message,
          error: error,
          stackTrace: stackTrace,
          time: time,
        )
      : null;

  static void i(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
    bool usePrettier = true,
    bool onlyInDebug = false,
  }) => (onlyInDebug && kDebugMode) || !onlyInDebug
      ? instance.i(
          usePrettier ? _toPrettier(message) : message,
          error: error,
          stackTrace: stackTrace,
          time: time,
        )
      : null;

  static void w(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
    bool usePrettier = true,
    bool onlyInDebug = false,
  }) => (onlyInDebug && kDebugMode) || !onlyInDebug
      ? instance.w(
          usePrettier ? _toPrettier(message) : message,
          error: error,
          stackTrace: stackTrace,
          time: time,
        )
      : null;

  static void e(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
    bool usePrettier = true,
    bool onlyInDebug = false,
  }) {
    if ((onlyInDebug && kDebugMode) || !onlyInDebug) {
      instance.e(
        usePrettier ? _toPrettier(message) : message,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
    }
  }

  static void f(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
    bool usePrettier = true,
    bool onlyInDebug = false,
  }) {
    if ((onlyInDebug && kDebugMode) || !onlyInDebug) {
      instance.f(
        usePrettier ? _toPrettier(message) : message,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
    }
  }
}
