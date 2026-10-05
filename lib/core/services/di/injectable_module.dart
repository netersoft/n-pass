import 'package:injectable/injectable.dart';

import '../../helpers/router/navigation_helper.dart';
import '../hive/service.dart';
import '../shared_preferences/service.dart';

@module
abstract class AppModule {
  @singleton
  NavigationHelper get navigationHelper => NavigationHelper();

  @singleton
  @preResolve
  Future<SharedPreferencesService> get prefs async => (await SharedPreferencesService.getInstance())!;

  @singleton
  @preResolve
  Future<HiveService> get hive async => (await HiveService.getInstance())!;
}
