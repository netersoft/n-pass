import 'package:app_set_id/app_set_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../../tools/functions/random_functions.dart';

abstract class DeviceInfoHelper {
  static DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  /// Extracting information from the Android device
  /// Dependencies
  /// Device Info Plus : https://pub.dev/packages/device_info_plus
  static Map<String, dynamic> androidDeviceInfo(AndroidDeviceInfo info) => <String, dynamic>{
    'version.securityPatch': info.version.securityPatch,
    'version.sdkInt': info.version.sdkInt,
    'version.release': info.version.release,
    'version.previewSdkInt': info.version.previewSdkInt,
    'version.incremental': info.version.incremental,
    'version.codename': info.version.codename,
    'version.baseOS': info.version.baseOS,
    'board': info.board,
    'bootloader': info.bootloader,
    'brand': info.brand,
    'device': info.device,
    'display': info.display,
    'fingerprint': info.fingerprint,
    'hardware': info.hardware,
    'host': info.host,
    'id': info.id,
    'manufacturer': info.manufacturer,
    'model': info.model,
    'product': info.product,
    'supported32BitAbis': info.supported32BitAbis,
    'supported64BitAbis': info.supported64BitAbis,
    'supportedAbis': info.supportedAbis,
    'tags': info.tags,
    'type': info.type,
    'isPhysicalDevice': info.isPhysicalDevice,
    'systemFeatures': info.systemFeatures,
    // 'serialNumber': info.serialNumber,
    'isLowRamDevice': info.isLowRamDevice,
  };

  /// Extracting information from the iOS device
  /// Dependencies
  /// Device Info Plus : https://pub.dev/packages/device_info_plus
  static Map<String, dynamic> iosDeviceInfo(IosDeviceInfo info) => <String, dynamic>{
    'name': info.name,
    'systemName': info.systemName,
    'systemVersion': info.systemVersion,
    'model': info.model,
    'localizedModel': info.localizedModel,
    'identifierForVendor': info.identifierForVendor,
    'isPhysicalDevice': info.isPhysicalDevice,
    'utsname.sysname:': info.utsname.sysname,
    'utsname.nodename:': info.utsname.nodename,
    'utsname.release:': info.utsname.release,
    'utsname.version:': info.utsname.version,
    'utsname.machine:': info.utsname.machine,
  };

  /// A method that returns a map of device information.
  /// The map contains different information about the device,
  /// such as the model, system name, system version, etc.
  /// It uses the DeviceInfoPlus package to get the information.
  /// The method is asynchronous and returns a Future of a map.
  /// The key of the map is a string describing the information and the value is a dynamic object containing the information.
  static Future<Map<String, dynamic>> getInfo() async => switch (defaultTargetPlatform) {
    TargetPlatform.android => DeviceInfoHelper.androidDeviceInfo(
      await deviceInfoPlugin.androidInfo,
    ),
    TargetPlatform.iOS => DeviceInfoHelper.iosDeviceInfo(
      await deviceInfoPlugin.iosInfo,
    ),
    TargetPlatform.fuchsia => {},
    TargetPlatform.linux => {},
    TargetPlatform.macOS => {},
    TargetPlatform.windows => {},
  };

  /// A method that returns a string containing the name of the device.
  /// The name is retrieved using the DeviceInfoPlus package.
  /// The method is asynchronous and returns a Future of a string.
  /// The returned string is different for each platform.
  static Future<String> getName() async => switch (defaultTargetPlatform) {
    TargetPlatform.android => (await deviceInfoPlugin.androidInfo).model,
    TargetPlatform.iOS => (await deviceInfoPlugin.iosInfo).utsname.machine,
    TargetPlatform.fuchsia => '',
    TargetPlatform.linux => '',
    TargetPlatform.macOS => '',
    TargetPlatform.windows => '',
  };

  /// Returns a unique identifier for the app.
  ///
  /// If AppSetId is able to get the identifier, it will be returned.
  /// Otherwise, a random alphanumeric string of length 21 will be returned.
  ///
  /// This method is asynchronous and returns a Future of a string.
  static Future<String> getAppSetId() async => (await AppSetId().getIdentifier()) ?? genRandomAlphaNumeric(21);
}
