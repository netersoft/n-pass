import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_starter/core/helpers/router/navigation_helper.dart';
import 'package:flutter_starter/core/services/api/service.dart';
import 'package:flutter_starter/core/services/di/locator.dart';
import 'package:flutter_starter/core/services/shared_preferences/service.dart';
import 'package:mocktail/mocktail.dart';

class MockSharedPreferencesService extends Mock implements SharedPreferencesService {}

class MockNavigationHelper extends Mock implements NavigationHelper {}

class MockApiClient extends Mock implements ApiClient {}

Future<void> setupTestLocator({
  SharedPreferencesService? sharedPreferencesService,
  NavigationHelper? navigationHelper,
  ApiClient? apiClient,
}) async {
  await dotenv.load();

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

  if (!locator.isRegistered<ApiClient>()) {
    locator.registerSingleton<ApiClient>(apiClient ?? MockApiClient());
  }
}

void teardownTestLocator() {
  if (locator.isRegistered<SharedPreferencesService>()) {
    locator.unregister<SharedPreferencesService>();
  }
  if (locator.isRegistered<NavigationHelper>()) {
    locator.unregister<NavigationHelper>();
  }
  if (locator.isRegistered<ApiClient>()) {
    locator.unregister<ApiClient>();
  }
}
