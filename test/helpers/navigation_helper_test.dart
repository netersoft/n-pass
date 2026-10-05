import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:n_pass/core/helpers/router/navigation_helper.dart';

void main() {
  group('NavigationHelper.getExtraValue', () {
    testWidgets('returns value from extra map when key exists', (tester) async {
      dynamic captured;
      final goRouter = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              captured = NavigationHelper.getExtraValue(context, 'test-key');
              return const SizedBox();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: goRouter),
      );

      goRouter.go('/', extra: {'test-key': 'found'});
      await tester.pumpAndSettle();

      expect(captured, 'found');
    });

    testWidgets('returns defaultValue when extra is null', (tester) async {
      dynamic captured;
      final goRouter = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              captured = NavigationHelper.getExtraValue(
                context,
                'missing',
                defaultValue: 42,
              );
              return const SizedBox();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: goRouter),
      );

      goRouter.go('/');
      await tester.pumpAndSettle();

      expect(captured, 42);
    });

    testWidgets('returns default value when extra is not a Map', (tester) async {
      dynamic captured;
      final goRouter = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              captured = NavigationHelper.getExtraValue(
                context,
                'key',
                defaultValue: 'fallback',
              );
              return const SizedBox();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: goRouter),
      );

      goRouter.go('/', extra: 'not-a-map');
      await tester.pumpAndSettle();

      expect(captured, 'fallback');
    });
  });
}
