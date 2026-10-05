import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

abstract class LocationService {
  static final Location location = Location();

  static Future<List<geocoding.Location>> getLocationFromAddress(
    String address,
  ) async => geocoding.locationFromAddress(address);

  static Future<geocoding.Placemark?> getCurrentPlacemark({
    LocationData? locationData,
  }) async {
    var placemarks = await getCurrentPlacemarks(locationData: locationData);

    return placemarks == null ? null : placemarks[0];
  }

  static Future<List<geocoding.Placemark>?> getCurrentPlacemarks({
    LocationData? locationData,
  }) async {
    var location = locationData ?? await getCurrentLocation();

    return location == null
        ? null
        : await geocoding.placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
  }

  static Future<LocationData?> getCurrentLocation() async {
    if (await requestPermission() && await requestServiceEnabled()) {
      return location.getLocation();
    }

    return null;
  }

  static Future<bool> requestPermission() async {
    PermissionStatus permissionGranted = await location.hasPermission();

    if (permissionGranted == PermissionStatus.deniedForever) {
      await permission_handler.openAppSettings();
    }

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    return permissionGranted == PermissionStatus.granted;
  }

  static Future<bool> requestServiceEnabled() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    return serviceEnabled;
  }
}
