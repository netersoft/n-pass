import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/helpers/router/navigation_helper.dart';
import 'package:n_pass/core/services/auto_lock/service.dart';
import 'package:n_pass/core/services/biometrics/service.dart';
import 'package:n_pass/core/services/di/locator.dart';
import 'package:n_pass/core/services/review/service.dart';
import 'package:n_pass/core/services/shared_preferences/service.dart';
import 'package:n_pass/core/services/vault/service.dart';

class MockSharedPreferencesService extends Mock implements SharedPreferencesService {}

class MockNavigationHelper extends Mock implements NavigationHelper {}

class MockReviewService extends Mock implements ReviewService {}

class MockVaultService extends Mock implements VaultService {}

class MockBiometricService extends Mock implements BiometricService {}

class MockAutoLockService extends Mock implements AutoLockService {}

Future<void> setupTestLocator({
  SharedPreferencesService? sharedPreferencesService,
  NavigationHelper? navigationHelper,
  VaultService? vaultService,
  BiometricService? biometricService,
  AutoLockService? autoLockService,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (!locator.isRegistered<SharedPreferencesService>()) {
    locator.registerSingleton<SharedPreferencesService>(
      sharedPreferencesService ?? MockSharedPreferencesService(),
    );
  }

  if (!locator.isRegistered<ReviewService>()) {
    final review = MockReviewService();
    when(review.requestOnce).thenAnswer((_) async {});
    locator.registerSingleton<ReviewService>(review);
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

  if (autoLockService != null && !locator.isRegistered<AutoLockService>()) {
    locator.registerSingleton<AutoLockService>(autoLockService);
  }
}

void teardownTestLocator() {
  if (locator.isRegistered<ReviewService>()) {
    locator.unregister<ReviewService>();
  }
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
  if (locator.isRegistered<AutoLockService>()) {
    locator.unregister<AutoLockService>();
  }
}
