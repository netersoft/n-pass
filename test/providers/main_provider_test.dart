import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/providers/main_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_utils.dart';

void main() {
  // AppTheme.prefs is a `static final` resolved from the locator on first
  // access -- MainScreen.defaultAppBar/searchAppBar (used by selectAppBar)
  // read it via AppTheme.getAppbarBgColor(), so a SharedPreferencesService
  // must be registered before selectAppBar runs for the first time in this
  // isolate, and stays cached for the rest of the file regardless of later
  // locator resets.
  setUpAll(() async {
    final mockPrefs = MockSharedPreferencesService();
    when(
      () => mockPrefs.getString(any(), defaultValue: any(named: 'defaultValue')),
    ).thenReturn(null);

    await setupTestLocator(sharedPreferencesService: mockPrefs);
  });

  group('MainProvider', () {
    test('initial state defaults to the home tab with the bottom bar visible', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(mainProvider);
      expect(state.currentTabIndex, MainState.homeTabIndex);
      expect(state.bottomBarIsVisible, isTrue);
    });

    test('updateTabIndex updates currentTabIndex', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(mainProvider.notifier).updateTabIndex(MainState.searchTabIndex);

      expect(container.read(mainProvider).currentTabIndex, MainState.searchTabIndex);
    });

    test('toggleBottomBar updates bottomBarIsVisible', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(mainProvider.notifier).toggleBottomBar(false);
      expect(container.read(mainProvider).bottomBarIsVisible, isFalse);

      container.read(mainProvider.notifier).toggleBottomBar(true);
      expect(container.read(mainProvider).bottomBarIsVisible, isTrue);
    });

    group('selectAppBar', () {
      test('returns the search app bar (2 actions) on the search tab', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(mainProvider.notifier).updateTabIndex(MainState.searchTabIndex);

        final appBar = container.read(mainProvider.notifier).selectAppBar() as AppBar;
        expect(appBar.actions, hasLength(2));
      });

      test('returns the default app bar (1 action) on every other tab', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        for (final index in [MainState.homeTabIndex, MainState.notificationsTabIndex, MainState.pageTabIndex]) {
          container.read(mainProvider.notifier).updateTabIndex(index);

          final appBar = container.read(mainProvider.notifier).selectAppBar() as AppBar;
          expect(appBar.actions, hasLength(1));
        }
      });
    });
  });
}
