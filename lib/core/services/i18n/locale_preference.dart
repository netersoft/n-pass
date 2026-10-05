import '../shared_preferences/keys.dart';
import '../shared_preferences/service.dart';
import 'translations.g.dart';

/// The language picked in the settings, kept across launches. Until the user
/// picks one, the app follows the device language.
abstract class LocalePreference {
  static Future<void> save(SharedPreferencesService prefs, String languageCode) async {
    await prefs.setString(PrefKeys.language, languageCode);
    await LocaleSettings.setLocaleRaw(languageCode);
  }

  /// Applies the saved language, or the device language when none is saved
  /// (or the saved one is no longer supported).
  static Future<void> restore(SharedPreferencesService prefs) async {
    final saved = prefs.getString(PrefKeys.language);
    final locale = AppLocale.values.where((l) => l.languageCode == saved).firstOrNull;
    if (locale != null) {
      await LocaleSettings.setLocale(locale);
    } else {
      await LocaleSettings.useDeviceLocale();
    }
  }

  static bool hasSaved(SharedPreferencesService prefs) => prefs.getString(PrefKeys.language) != null;
}
