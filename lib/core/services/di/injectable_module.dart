import 'package:injectable/injectable.dart';

import '../../helpers/router/navigation_helper.dart';
import '../auto_lock/service.dart';
import '../backup/service.dart';
import '../biometrics/service.dart';
import '../camera/service.dart';
import '../clipboard/service.dart';
import '../files/service.dart';
import '../hive/service.dart';
import '../review/service.dart';
import '../shared_preferences/service.dart';
import '../vault/service.dart';
import '../vault/store.dart';

@module
abstract class AppModule {
  @singleton
  NavigationHelper get navigationHelper => NavigationHelper();

  @singleton
  ReviewService get reviewService => ReviewService();

  @singleton
  @preResolve
  Future<SharedPreferencesService> get prefs async => (await SharedPreferencesService.getInstance())!;

  @singleton
  @preResolve
  Future<HiveService> get hive async => (await HiveService.getInstance())!;

  @singleton
  @preResolve
  Future<VaultService> get vault async => VaultService(await VaultStore.open());

  @singleton
  BiometricService biometrics(SharedPreferencesService prefs) => BiometricService(prefs);

  @singleton
  AutoLockService autoLock(SharedPreferencesService prefs) => AutoLockService(prefs);

  @singleton
  ClipboardService get clipboard => ClipboardService();

  @singleton
  BackupService get backup => BackupService();

  @singleton
  CameraPermissionService camera(AutoLockService autoLock) => CameraPermissionService(autoLock);

  @singleton
  FileTransferService fileTransfer(AutoLockService autoLock) => FileTransferService(autoLock);
}
