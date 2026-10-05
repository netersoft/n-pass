import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/providers/vault/change_password_provider.dart';
import 'package:n_pass/core/tools/functions/password_strength.dart';

import '../helpers/test_utils.dart';

void main() {
  late MockVaultService vault;

  setUp(() async {
    vault = MockVaultService();
    await setupTestLocator(vaultService: vault);
  });

  tearDown(teardownTestLocator);

  ProviderContainer container() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.listen(changePasswordProvider, (_, _) {});
    return c;
  }

  test('rates the new password', () {
    final c = container();

    c.read(changePasswordProvider.notifier).setNewPassword('correct horse battery staple');

    expect(c.read(changePasswordProvider).strength, PasswordStrength.strong);
    expect(c.read(changePasswordProvider).isStrongEnough, isTrue);
  });

  test('flags a wrong current password until it is edited', () async {
    when(() => vault.changePassword('wrong', 'new password')).thenAnswer((_) async => false);
    final c = container();
    final notifier = c.read(changePasswordProvider.notifier);

    expect(await notifier.submit('wrong', 'new password'), isFalse);
    expect(c.read(changePasswordProvider).wrongCurrentPassword, isTrue);
    expect(c.read(changePasswordProvider).isSubmitting, isFalse);

    notifier.clearWrongPassword();
    expect(c.read(changePasswordProvider).wrongCurrentPassword, isFalse);
  });

  test('changes the password with the right current one', () async {
    when(() => vault.changePassword('current', 'new password')).thenAnswer((_) async => true);

    expect(await container().read(changePasswordProvider.notifier).submit('current', 'new password'), isTrue);
    verify(() => vault.changePassword('current', 'new password')).called(1);
  });
}
