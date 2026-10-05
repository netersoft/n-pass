import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/routes/router.dart';

void main() {
  group('vaultRedirect', () {
    test('locked vault: protected screens go to unlock, or create when there is no vault', () {
      expect(vaultRedirect('/main', isCreated: true, isUnlocked: false), '/unlock');
      expect(vaultRedirect('/main/settings', isCreated: true, isUnlocked: false), '/unlock');
      expect(vaultRedirect('/main', isCreated: false, isUnlocked: false), '/create');
    });

    test('locked vault: public screens stay reachable', () {
      for (final location in ['/', '/intro', '/create', '/unlock']) {
        expect(vaultRedirect(location, isCreated: true, isUnlocked: false), isNull, reason: location);
      }
    });

    test('unlocked vault: unlock screen goes to main, others stay', () {
      expect(vaultRedirect('/unlock', isCreated: true, isUnlocked: true), '/main');
      expect(vaultRedirect('/main', isCreated: true, isUnlocked: true), isNull);
      expect(vaultRedirect('/create', isCreated: true, isUnlocked: true), isNull);
    });
  });
}
