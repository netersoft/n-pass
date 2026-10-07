import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/services/i18n/translations.g.dart';

void main() {
  group('LocaleSettings', () {
    test('base locale is en, used for unsupported device languages', () {
      expect(AppLocaleUtils.instance.baseLocale, AppLocale.en);
    });

    test('setLocaleRaw changes locale', () async {
      await LocaleSettings.setLocaleRaw('en');
      expect(LocaleSettings.currentLocale, AppLocale.en);

      await LocaleSettings.setLocaleRaw('fr');
      expect(LocaleSettings.currentLocale, AppLocale.fr);
    });

    test('translations reflect current locale', () async {
      await LocaleSettings.setLocaleRaw('fr');
      expect(t.language, 'Langue');

      await LocaleSettings.setLocaleRaw('en');
      expect(t.language, 'Language');
    });
  });
}
