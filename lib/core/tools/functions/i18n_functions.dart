import 'dart:convert';
import 'dart:ui';

import '../../services/i18n/translations.g.dart';

import 'string_functions.dart';

/// Get the translation of a given string
String getTranslation(String data, {String fallback = 'fr'}) {
  Map<String, String> parsedData = {};

  String langCode = LocaleSettings.instance.currentLocale.languageCode;

  try {
    parsedData = Map<String, String>.from(
      jsonDecode(fixEscapeSequences(data)),
    );
  } catch (e) {
    return data;
  }

  bool isValidTranslation(String key) => parsedData[key]?.isNotEmpty ?? false;

  for (final String code in [
    langCode,
    langCode.toUpperCase(),
    fallback,
    fallback.toUpperCase(),
  ]) {
    if (isValidTranslation(code)) {
      return parsedData[code] ?? '';
    }
  }

  dynamic any = data;
  parsedData.forEach((key, value) {
    any = value;
  });

  return any;
}

/// Returns the language code of the systemAdd commentMore actions
String getSystemLanguageCode() => PlatformDispatcher.instance.locale.languageCode;
