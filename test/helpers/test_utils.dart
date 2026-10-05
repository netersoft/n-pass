import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/helpers/router/navigation_helper.dart';
import 'package:n_pass/core/services/di/locator.dart';
import 'package:n_pass/core/services/shared_preferences/service.dart';

class MockSharedPreferencesService extends Mock implements SharedPreferencesService {}

class MockNavigationHelper extends Mock implements NavigationHelper {}

Future<void> setupTestLocator({
  SharedPreferencesService? sharedPreferencesService,
  NavigationHelper? navigationHelper,
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
}

void teardownTestLocator() {
  if (locator.isRegistered<SharedPreferencesService>()) {
    locator.unregister<SharedPreferencesService>();
  }
  if (locator.isRegistered<NavigationHelper>()) {
    locator.unregister<NavigationHelper>();
  }
}
