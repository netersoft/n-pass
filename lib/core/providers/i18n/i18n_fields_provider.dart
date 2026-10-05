import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/i18n/config.dart';
import '../../services/i18n/translations.g.dart';
import '../../tools/functions/string_functions.dart';

part 'i18n_fields_provider.g.dart';

@riverpod
class I18nFields extends _$I18nFields {
  @override
  I18nFieldsState build() => const I18nFieldsState();

  Map<String, String> decodeValue(String? data) {
    Map<String, String> parsedData = {};

    try {
      parsedData = Map<String, String>.from(
        jsonDecode(fixEscapeSequences(data ?? '')),
      );
    } catch (e) {
      //
    }

    return parsedData;
  }

  String? extractLocaleValue(Map<String, String> parsedData, String? localeCode) {
    for (final String? code in [localeCode, localeCode?.toUpperCase()]) {
      if (code != null && (parsedData[code]?.isNotEmpty ?? false)) {
        return parsedData[code] ?? '';
      }
    }

    return '';
  }

  String? setupInitialValue(String? initialValue) {
    final currentLang = I18nConfig.langItems.firstWhereOrNull(
      (item) => item.code == LocaleSettings.instance.currentLocale.languageCode,
    );

    final fieldLocaleCode = currentLang?.code;
    final fieldMappedValue = decodeValue(initialValue);

    state = state.copyWith(
      fieldLocaleCode: fieldLocaleCode,
      fieldMappedValue: fieldMappedValue,
    );

    return extractLocaleValue(fieldMappedValue, fieldLocaleCode);
  }

  void initTextField(String? initialValue, TextEditingController ctrl) {
    final value = setupInitialValue(initialValue);
    ctrl.text = value ?? '';
  }

  void initHtmlField(String? initialValue, HtmlEditorController ctrl) {
    final value = setupInitialValue(initialValue);
    ctrl.insertHtml(value ?? '');
  }

  void onTextFieldValueChanged(String? value, void Function(String?)? execute, TextEditingController ctrl) {
    final localeCode = state.fieldLocaleCode;
    final mappedValue = Map<String, String>.from(state.fieldMappedValue);

    mappedValue[localeCode!] = value ?? '';
    if (execute != null) execute(jsonEncode(mappedValue));

    ctrl.text = value ?? '';

    state = state.copyWith(fieldValue: value, fieldMappedValue: mappedValue);
  }

  void onHtmlFieldValueChanged(String? value, void Function(String?)? execute, HtmlEditorController ctrl) {
    final localeCode = state.fieldLocaleCode;
    final mappedValue = Map<String, String>.from(state.fieldMappedValue);

    mappedValue[localeCode!] = value ?? '';
    if (execute != null) execute(jsonEncode(mappedValue));

    ctrl.insertHtml(value ?? '');

    state = state.copyWith(fieldValue: value, fieldMappedValue: mappedValue);
  }

  void onTextFieldLocaleCodeChanged(String? value, void Function(String?)? execute, TextEditingController ctrl) {
    final mappedValue = Map<String, String>.from(state.fieldMappedValue);
    final extractedValue = extractLocaleValue(mappedValue, value);

    if (execute != null) execute(value);

    ctrl.text = extractedValue ?? '';

    state = state.copyWith(fieldLocaleCode: value, fieldValue: extractedValue);
  }

  void onHtmlFieldLocaleCodeChanged(String? value, void Function(String?)? execute, HtmlEditorController ctrl) {
    final mappedValue = Map<String, String>.from(state.fieldMappedValue);
    final extractedValue = extractLocaleValue(mappedValue, value);

    if (execute != null) execute(value);

    ctrl.insertHtml(extractedValue ?? '');

    state = state.copyWith(fieldLocaleCode: value, fieldValue: extractedValue);
  }
}

class I18nFieldsState {
  final String? fieldValue;
  final String? fieldLocaleCode;
  final Map<String, String> fieldMappedValue;

  const I18nFieldsState({
    this.fieldValue,
    this.fieldLocaleCode,
    this.fieldMappedValue = const {},
  });

  I18nFieldsState copyWith({
    String? fieldValue,
    String? fieldLocaleCode,
    Map<String, String>? fieldMappedValue,
  }) => I18nFieldsState(
    fieldValue: fieldValue ?? this.fieldValue,
    fieldLocaleCode: fieldLocaleCode ?? this.fieldLocaleCode,
    fieldMappedValue: fieldMappedValue ?? this.fieldMappedValue,
  );
}
