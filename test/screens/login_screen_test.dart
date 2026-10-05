import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/services/i18n/translations.g.dart';
import 'package:flutter_starter/view/screens/auth/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_utils.dart';

void main() {
  late MockSharedPreferencesService mockPrefs;

  setUp(() async {
    mockPrefs = MockSharedPreferencesService();
    when(
      () => mockPrefs.getString(any(), defaultValue: any(named: 'defaultValue')),
    ).thenReturn(null);

    await setupTestLocator(sharedPreferencesService: mockPrefs);
  });

  tearDown(teardownTestLocator);

  Widget buildSubject() => ProviderScope(
    child: TranslationProvider(
      child: const MaterialApp(
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FormBuilderLocalizations.delegate,
        ],
        home: LoginScreen(),
      ),
    ),
  );

  testWidgets('renders the email field, password field, and primary actions', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(FormBuilderTextField), findsNWidgets(2));
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.textContaining("S'inscrire", findRichText: true), findsOneWidget);
    expect(find.text('Mot de passe oublié ?'), findsOneWidget);
  });

  testWidgets('toggles password visibility locally without touching the network', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('blocks submission on empty fields instead of reaching the network layer', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    // Client-side validation must reject the empty form before `Login.submit`
    // ever runs -- if it didn't, this would throw trying to reach a live API
    // or an unset Hive box, since neither is configured in this test.
    expect(tester.takeException(), isNull);
    expect(find.byType(LoginScreenForm), findsOneWidget);
  });
}
