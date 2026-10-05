import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/models/user_model.dart';
import 'package:flutter_starter/core/services/hive/hive_registrar.g.dart';
import 'package:flutter_starter/core/services/hive/keys.dart';
import 'package:flutter_starter/core/services/i18n/translations.g.dart';
import 'package:flutter_starter/view/screens/account/edit_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/test_utils.dart';

void main() {
  late Directory tempDir;
  late Box authBox;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_edit_profile_screen_test');
    Hive
      ..init(tempDir.path)
      ..registerAdapters();
    // EditProfileScreen renders through ProfileProvider, which reads
    // `Hive.box(HiveKeys.auth)` directly and expects it already open -- same
    // assumption as production, minus the encryption cipher it never touches.
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
    await authBox.put(
      HiveKeys.authUserData,
      UserModel(id: 1, name: 'Jane Doe', email: 'jane@example.com'),
    );
  });

  tearDown(() async {
    await authBox.clear();
    teardownTestLocator();
  });

  Widget buildSubject() => ProviderScope(
    child: TranslationProvider(
      child: const MaterialApp(
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FormBuilderLocalizations.delegate,
        ],
        home: EditProfileScreen(),
      ),
    ),
  );

  testWidgets('renders the name and email fields pre-filled with the stored user', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(FormBuilderTextField), findsNWidgets(2));
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text(t.save), findsOneWidget);
  });

  testWidgets('blocks submission on an invalid email instead of reaching the network layer', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(FormBuilderTextField).last, 'not-an-email');
    await tester.tap(find.text(t.save));
    await tester.pumpAndSettle();

    // Client-side validation must reject the invalid email before
    // `Profile.updateProfile` ever runs -- if it didn't, this would throw
    // trying to reach a live API, since none is configured in this test.
    expect(tester.takeException(), isNull);
    expect(find.byType(EditProfileScreenForm), findsOneWidget);
  });

  testWidgets('tapping the avatar offers gallery and camera actions', (tester) async {
    // No stored avatar url here on purpose -- rendering one would route
    // through CustomNetworkImage/CachedNetworkImage, whose shimmer
    // placeholder animates indefinitely while the (unmocked) network
    // request never resolves in this test, hanging pumpAndSettle forever.
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.text(t.chooseInTheGallery), findsOneWidget);
    expect(find.text(t.takePicture), findsOneWidget);
    expect(find.text(t.delete), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
