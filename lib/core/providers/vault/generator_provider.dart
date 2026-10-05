import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/di/locator.dart';
import '../../services/shared_preferences/keys.dart';
import '../../services/shared_preferences/service.dart';
import '../../tools/functions/password_generator.dart';

part 'generator_provider.g.dart';

/// Password generator options, remembered between uses.
@Riverpod(keepAlive: true)
class GeneratorOptions extends _$GeneratorOptions {
  SharedPreferencesService get _prefs => locator<SharedPreferencesService>();

  @override
  PasswordGeneratorOptions build() {
    final raw = _prefs.getString(PrefKeys.generatorOptions);
    if (raw == null) return const PasswordGeneratorOptions();
    try {
      return PasswordGeneratorOptions.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return const PasswordGeneratorOptions();
    }
  }

  void update(PasswordGeneratorOptions options) {
    // Keep at least one charset, otherwise generation is impossible.
    if (options.charsets.isEmpty) return;
    _prefs.setString(PrefKeys.generatorOptions, jsonEncode(options.toJson()));
    state = options;
  }
}
