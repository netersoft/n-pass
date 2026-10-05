import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/providers/onboarding/intro_provider.dart';
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

  group('IntroProvider', () {
    test('initial state has currentIndex set to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(introProvider);
      expect(state.currentIndex, 0);
    });

    test('updateIndex updates currentIndex', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(introProvider.notifier).updateIndex(2);
      expect(container.read(introProvider).currentIndex, 2);

      container.read(introProvider.notifier).updateIndex(0);
      expect(container.read(introProvider).currentIndex, 0);
    });

    test('updateIndex does nothing for same index (copyWith optimization)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state1 = container.read(introProvider);
      container.read(introProvider.notifier).updateIndex(0);
      final state2 = container.read(introProvider);

      expect(identical(state1, state2), false);
      expect(state2.currentIndex, 0);
    });

    test('onDone sets firstOpening to false and navigates to providers', () {
      when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(introProvider.notifier).onDone();

      verify(() => mockPrefs.setBool('appFirstOpening', false)).called(1);
      verify(() => mockNav.pushReplacement(any(), arguments: any(named: 'arguments'))).called(1);
    });
  });
}
