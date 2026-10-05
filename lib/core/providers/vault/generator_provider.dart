import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/di/locator.dart';
import '../../services/shared_preferences/keys.dart';
import '../../services/shared_preferences/service.dart';
import '../../tools/functions/passphrase_generator.dart';
import '../../tools/functions/password_generator.dart';

part 'generator_provider.g.dart';

enum GeneratorMode { password, passphrase }

class GeneratorSettings {
  final GeneratorMode mode;
  final PasswordGeneratorOptions password;
  final PassphraseOptions passphrase;

  const GeneratorSettings({
    this.mode = GeneratorMode.password,
    this.password = const PasswordGeneratorOptions(),
    this.passphrase = const PassphraseOptions(),
  });

  factory GeneratorSettings.fromJson(Map<String, dynamic> json) => GeneratorSettings(
    mode: GeneratorMode.values.asNameMap()[json['mode']] ?? GeneratorMode.password,
    password: json['password'] is Map<String, dynamic>
        ? PasswordGeneratorOptions.fromJson(json['password'] as Map<String, dynamic>)
        : const PasswordGeneratorOptions(),
    passphrase: json['passphrase'] is Map<String, dynamic> ? PassphraseOptions.fromJson(json['passphrase'] as Map<String, dynamic>) : const PassphraseOptions(),
  );

  Map<String, dynamic> toJson() => {'mode': mode.name, 'password': password.toJson(), 'passphrase': passphrase.toJson()};

  GeneratorSettings copyWith({GeneratorMode? mode, PasswordGeneratorOptions? password, PassphraseOptions? passphrase}) => GeneratorSettings(
    mode: mode ?? this.mode,
    password: password ?? this.password,
    passphrase: passphrase ?? this.passphrase,
  );
}

/// Generator mode and options, remembered between uses.
@Riverpod(keepAlive: true)
class GeneratorOptions extends _$GeneratorOptions {
  SharedPreferencesService get _prefs => locator<SharedPreferencesService>();

  @override
  GeneratorSettings build() {
    final raw = _prefs.getString(PrefKeys.generatorOptions);
    if (raw == null) return const GeneratorSettings();
    try {
      return GeneratorSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return const GeneratorSettings();
    }
  }

  void update(GeneratorSettings settings) {
    // Keep at least one charset, otherwise generation is impossible.
    if (settings.password.charsets.isEmpty) return;
    _prefs.setString(PrefKeys.generatorOptions, jsonEncode(settings.toJson()));
    state = settings;
  }
}

/// EFF large wordlist (CC BY 3.0 US), one word per line.
@Riverpod(keepAlive: true)
Future<List<String>> passphraseWordlist(Ref ref) async {
  final raw = await rootBundle.loadString('assets/wordlists/eff_large_wordlist.txt');
  return const LineSplitter().convert(raw).where((w) => w.isNotEmpty).toList(growable: false);
}
