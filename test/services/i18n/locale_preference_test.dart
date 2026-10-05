import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/services/i18n/locale_preference.dart';
import 'package:n_pass/core/services/i18n/translations.g.dart';
import 'package:n_pass/core/services/shared_preferences/keys.dart';

import '../../helpers/test_utils.dart';

void main() {
  late MockSharedPreferencesService prefs;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    prefs = MockSharedPreferencesService();
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  tearDown(() => LocaleSettings.setLocale(AppLocale.fr));

  void saved(String? code) => when(() => prefs.getString(PrefKeys.language, defaultValue: any(named: 'defaultValue'))).thenReturn(code);

  test('save persists the language and applies it', () async {
    await LocalePreference.save(prefs, 'en');

    verify(() => prefs.setString(PrefKeys.language, 'en')).called(1);
    expect(LocaleSettings.currentLocale, AppLocale.en);
  });

  test('restore applies the saved language', () async {
    saved('en');

    await LocalePreference.restore(prefs);

    expect(LocaleSettings.currentLocale, AppLocale.en);
    expect(LocalePreference.hasSaved(prefs), isTrue);
  });

  test('restore follows the device without a supported saved language', () async {
    for (final code in [null, 'xx']) {
      saved(code);
      await LocaleSettings.setLocale(AppLocale.fr);

      await LocalePreference.restore(prefs);

      // The test device locale is en-US.
      expect(LocaleSettings.currentLocale, AppLocale.en, reason: '$code');
    }
    saved(null);
    expect(LocalePreference.hasSaved(prefs), isFalse);
  });
}
