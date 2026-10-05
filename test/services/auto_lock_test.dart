import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/services/auto_lock/service.dart';
import 'package:n_pass/core/services/shared_preferences/keys.dart';

import '../helpers/test_utils.dart';

void main() {
  late MockSharedPreferencesService prefs;
  late DateTime now;
  late AutoLockService autoLock;

  setUp(() {
    prefs = MockSharedPreferencesService();
    now = DateTime(2026, 10, 5, 12);
    autoLock = AutoLockService(prefs, now: () => now);
  });

  void delay(int? seconds) => when(
    () => prefs.getInt(PrefKeys.autoLockDelaySeconds, defaultValue: any(named: 'defaultValue')),
  ).thenReturn(seconds ?? AutoLockService.defaultDelay);

  test('defaults to one minute', () {
    when(() => prefs.getInt(PrefKeys.autoLockDelaySeconds, defaultValue: any(named: 'defaultValue'))).thenReturn(null);

    expect(autoLock.delaySeconds, AutoLockService.defaultDelay);
    expect(AutoLockService.defaultDelay, 60);
  });

  test('locks only after the delay', () {
    delay(60);

    autoLock.onBackground();
    now = now.add(const Duration(seconds: 59));
    expect(autoLock.onForeground(), isFalse);

    autoLock.onBackground();
    now = now.add(const Duration(seconds: 60));
    expect(autoLock.onForeground(), isTrue);
  });

  test('a zero delay locks as soon as the app comes back', () {
    delay(0);

    autoLock.onBackground();
    expect(autoLock.onForeground(), isTrue);
  });

  test('keeps the first background timestamp and resets after resume', () {
    delay(60);

    autoLock.onBackground();
    now = now.add(const Duration(seconds: 50));
    autoLock.onBackground();
    now = now.add(const Duration(seconds: 20));
    expect(autoLock.onForeground(), isTrue);

    expect(autoLock.onForeground(), isFalse, reason: 'no background since the last resume');
  });

  test('setDelaySeconds persists the delay', () async {
    when(() => prefs.setInt(any(), any())).thenAnswer((_) async => true);

    await autoLock.setDelaySeconds(600);

    verify(() => prefs.setInt(PrefKeys.autoLockDelaySeconds, 600)).called(1);
  });

  group('whileExternal', () {
    test('gives at least the grace delay while a system screen is open', () async {
      delay(0);

      await autoLock.whileExternal(() async {
        autoLock.onBackground();
        now = now.add(const Duration(seconds: AutoLockService.externalGraceSeconds - 1));
        expect(autoLock.onForeground(), isFalse);

        autoLock.onBackground();
        now = now.add(const Duration(seconds: AutoLockService.externalGraceSeconds));
        expect(autoLock.onForeground(), isTrue, reason: 'still locks after a long trip away');
      });
    });

    test('keeps a longer configured delay', () async {
      delay(3600);

      await autoLock.whileExternal(() async {
        autoLock.onBackground();
        now = now.add(const Duration(seconds: 600));
        expect(autoLock.onForeground(), isFalse);
      });
    });

    test('applies the normal delay again once the action is done', () async {
      delay(0);

      await autoLock.whileExternal(() async {});
      autoLock.onBackground();

      expect(autoLock.onForeground(), isTrue);
    });

    test('ends the grace even when the action throws', () async {
      delay(0);

      await expectLater(autoLock.whileExternal<void>(() async => throw StateError('boom')), throwsStateError);
      autoLock.onBackground();

      expect(autoLock.onForeground(), isTrue);
    });
  });
}
