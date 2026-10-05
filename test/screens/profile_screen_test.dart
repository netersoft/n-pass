import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/models/user_model.dart';
import 'package:flutter_starter/core/services/hive/hive_registrar.g.dart';
import 'package:flutter_starter/core/services/hive/keys.dart';
import 'package:flutter_starter/core/services/i18n/translations.g.dart';
import 'package:flutter_starter/view/screens/account/profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/test_utils.dart';

void main() {
  late Directory tempDir;
  late Box authBox;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_profile_screen_test');
    Hive
      ..init(tempDir.path)
      ..registerAdapters();
    // ProfileProvider reads `Hive.box(HiveKeys.auth)` directly and expects
    // it already open -- same assumption as production, minus the
    // encryption cipher which ProfileProvider never touches itself.
    authBox = await Hive.openBox(HiveKeys.auth);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await setupTestLocator();
  });

  tearDown(() async {
    await authBox.clear();
    teardownTestLocator();
  });

  UserModel buildUser({DateTime? emailVerifiedAt}) => UserModel(
    id: 1,
    name: 'Jane Doe',
    email: 'jane@example.com',
    emailVerifiedAt: emailVerifiedAt,
  );

  Widget buildSubject() => ProviderScope(
    child: TranslationProvider(
      child: const MaterialApp(
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ProfileScreen(),
      ),
    ),
  );

  group('when a full profile is stored', () {
    setUp(() async {
      await authBox.put(HiveKeys.authToken, 'a-token');
      await authBox.put(HiveKeys.authUserData, buildUser());
    });

    testWidgets('renders the basic information section for the logged-in user', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);
      expect(find.text(t.twoFactorDisabled), findsOneWidget);
      expect(find.text(t.resendVerificationEmail), findsOneWidget);
    });

    testWidgets('tapping log out shows a confirmation dialog without reaching the network', (tester) async {
      // The "Account" section (log out) sits below the fold in the default
      // test surface -- SettingsList virtualizes its slivers, so tiles
      // outside the viewport aren't built at all.
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.logOut));
      await tester.pumpAndSettle();

      // Stop here without confirming -- both dialog actions route through
      // go_router's `context.pop()`, which needs a real GoRouter ancestor
      // this bare MaterialApp doesn't provide, and tapping "yes" would also
      // call ProfileProvider.logout(), reaching an unstubbed ApiService.
      expect(find.text(t.sureToLogOut), findsOneWidget);
      expect(find.text(t.cancel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('when the email is already verified', () {
    setUp(() async {
      await authBox.put(HiveKeys.authToken, 'a-token');
      await authBox.put(HiveKeys.authUserData, buildUser(emailVerifiedAt: DateTime.now()));
    });

    testWidgets('hides the resend-verification-email tile', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text(t.resendVerificationEmail), findsNothing);
    });
  });

  group('when no profile is stored', () {
    testWidgets('renders without throwing and hides the resend-verification-email tile', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(t.resendVerificationEmail), findsNothing);
    });
  });
}
