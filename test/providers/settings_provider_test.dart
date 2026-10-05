import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/enums/app_brightness.dart';
import 'package:flutter_starter/core/providers/account/settings_provider.dart';
import 'package:flutter_starter/core/services/shared_preferences/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_utils.dart';

void main() {
  late MockSharedPreferencesService mockPrefs;
  late MockNavigationHelper mockNav;

  setUp(() async {
    mockPrefs = MockSharedPreferencesService();
    mockNav = MockNavigationHelper();

    await setupTestLocator(
      sharedPreferencesService: mockPrefs,
      navigationHelper: mockNav,
    );
  });

  tearDown(teardownTestLocator);

  group('SettingsProvider', () {
    test('initial state has isLoading set to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(settingsProvider);
      expect(state.isLoading, isFalse);
    });

    group('notifications', () {
      test('getEnableNotificationsState reads from prefs', () {
        when(
          () => mockPrefs.getBool(PrefKeys.enableNotifications, defaultValue: any(named: 'defaultValue')),
        ).thenReturn(false);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final result = container.read(settingsProvider.notifier).getEnableNotificationsState();
        expect(result, isFalse);

        when(
          () => mockPrefs.getBool(PrefKeys.enableNotifications, defaultValue: any(named: 'defaultValue')),
        ).thenReturn(true);

        final result2 = container.read(settingsProvider.notifier).getEnableNotificationsState();
        expect(result2, isTrue);
      });

      test('getEnableNotificationsState defaults to true', () {
        when(
          () => mockPrefs.getBool(PrefKeys.enableNotifications, defaultValue: any(named: 'defaultValue')),
        ).thenReturn(null);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final result = container.read(settingsProvider.notifier).getEnableNotificationsState();
        verify(
          () => mockPrefs.getBool(PrefKeys.enableNotifications, defaultValue: true),
        ).called(1);
        expect(result, isNull);
      });

      test('toggleEnableNotificationsState persists to prefs', () {
        when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
        when(
          () => mockPrefs.getBool(PrefKeys.enableNotifications, defaultValue: any(named: 'defaultValue')),
        ).thenReturn(false);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(settingsProvider.notifier).toggleEnableNotificationsState(true);
        verify(() => mockPrefs.setBool(PrefKeys.enableNotifications, true)).called(1);

        container.read(settingsProvider.notifier).toggleEnableNotificationsState(false);
        verify(() => mockPrefs.setBool(PrefKeys.enableNotifications, false)).called(1);
      });
    });

    group('brightness', () {
      test('getAppBrightness returns stored value', () {
        when(
          () => mockPrefs.getString(PrefKeys.brightness, defaultValue: any(named: 'defaultValue')),
        ).thenReturn(AppBrightness.dark.name);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final result = container.read(settingsProvider.notifier).getAppBrightness();
        expect(result, AppBrightness.dark.name);
      });

      test('getAppBrightness defaults to system', () {
        when(
          () => mockPrefs.getString(PrefKeys.brightness, defaultValue: any(named: 'defaultValue')),
        ).thenReturn(null);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final result = container.read(settingsProvider.notifier).getAppBrightness();
        verify(
          () => mockPrefs.getString(PrefKeys.brightness, defaultValue: AppBrightness.system.name),
        ).called(1);
        expect(result, isNull);
      });

      test('setAppBrightness persists and does not relaunch when relaunch=false', () {
        when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        container
            .read(settingsProvider.notifier)
            .setAppBrightness(
              AppBrightness.dark.name,
              relaunch: false,
            );

        verify(() => mockPrefs.setString(PrefKeys.brightness, AppBrightness.dark.name)).called(1);
        verifyNever(() => mockNav.go(any()));
      });

      test('setAppBrightness persists and attempts relaunch when relaunch=true', () {
        when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
        when(() => mockNav.go(any())).thenReturn(null);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        container
            .read(settingsProvider.notifier)
            .setAppBrightness(
              AppBrightness.light.name,
            );

        verify(() => mockPrefs.setString(PrefKeys.brightness, AppBrightness.light.name)).called(1);
        verify(() => mockNav.go(any())).called(1);
      });
    });
  });
}
