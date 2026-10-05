import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/helpers/router/route_redirect_helper.dart';
import 'package:n_pass/core/routes/app_route.dart';

void main() {
  group('RedirectionRoute', () {
    test('has path /', () {
      expect(const RedirectionRoute().location, '/');
    });
  });

  group('RedirectionExtra', () {
    test('constructs with routes and params', () {
      const extra = RedirectionExtra(
        routes: ['/home', '/profile'],
        params: {'token': 'abc'},
      );
      expect(extra.routes, ['/home', '/profile']);
      expect(extra.params, {'token': 'abc'});
    });

    test('uses empty defaults', () {
      const extra = RedirectionExtra();
      expect(extra.routes, isEmpty);
      expect(extra.params, isEmpty);
    });
  });

  group('RouteRedirectHelper', () {
    test('instance factory creates helper with given context', () {
      final helper = RouteRedirectHelper.instance(null);
      expect(helper, isA<RouteRedirectHelper>());
    });

    test('redirectTo does not throw with null context', () {
      final helper = RouteRedirectHelper(null);
      expect(
        () => helper.redirectTo(routes: ['/test'], params: {}),
        returnsNormally,
      );
    });

    testWidgets('redirectTo does not throw with real context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => GestureDetector(
              onTap: () => RouteRedirectHelper.instance(context)..redirectTo(routes: ['/test']),
              child: const SizedBox(width: 100, height: 100, key: ValueKey('tap')),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('tap')), warnIfMissed: false);
    });
  });
}
