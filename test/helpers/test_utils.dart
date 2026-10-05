import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/helpers/router/navigation_helper.dart';
import 'package:n_pass/core/services/biometrics/service.dart';
import 'package:n_pass/core/services/di/locator.dart';
import 'package:n_pass/core/services/shared_preferences/service.dart';
import 'package:n_pass/core/services/vault/service.dart';

class MockSharedPreferencesService extends Mock implements SharedPreferencesService {}

class MockNavigationHelper extends Mock implements NavigationHelper {}

class MockVaultService extends Mock implements VaultService {}

class MockBiometricService extends Mock implements BiometricService {}

Future<void> setupTestLocator({
  SharedPreferencesService? sharedPreferencesService,
  NavigationHelper? navigationHelper,
  VaultService? vaultService,
  BiometricService? biometricService,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (!locator.isRegistered<SharedPreferencesService>()) {
    locator.registerSingleton<SharedPreferencesService>(
      sharedPreferencesService ?? MockSharedPreferencesService(),
    );
  }

  if (!locator.isRegistered<NavigationHelper>()) {
    locator.registerSingleton<NavigationHelper>(
      navigationHelper ?? MockNavigationHelper(),
    );
  }

  if (vaultService != null && !locator.isRegistered<VaultService>()) {
    locator.registerSingleton<VaultService>(vaultService);
  }

  if (biometricService != null && !locator.isRegistered<BiometricService>()) {
    locator.registerSingleton<BiometricService>(biometricService);
  }
}

void teardownTestLocator() {
  if (locator.isRegistered<SharedPreferencesService>()) {
    locator.unregister<SharedPreferencesService>();
  }
  if (locator.isRegistered<NavigationHelper>()) {
    locator.unregister<NavigationHelper>();
  }
  if (locator.isRegistered<VaultService>()) {
    locator.unregister<VaultService>();
  }
  if (locator.isRegistered<BiometricService>()) {
    locator.unregister<BiometricService>();
  }
}
