import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  static SharedPreferences? _preferences;

  static Future<SharedPreferencesService?> getInstance() async {
    _instance ??= SharedPreferencesService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance;
  }

  SharedPreferences? get preferences => _preferences;

  List<String>? getListString(String key, {List<String>? defaultValue}) => _preferences!.getStringList(key) ?? defaultValue;

  String? getString(String key, {String? defaultValue}) => _preferences!.getString(key) ?? defaultValue;

  bool? getBool(String key, {bool? defaultValue}) => _preferences!.getBool(key) ?? defaultValue;

  int? getInt(String key, {int? defaultValue}) => _preferences!.getInt(key) ?? defaultValue;

  double? getDouble(String key, {double? defaultValue}) => _preferences!.getDouble(key) ?? defaultValue;

  Future<bool> setStringList(String key, List<String> value) => _preferences!.setStringList(key, value);

  Future<bool> setString(String key, String value) => _preferences!.setString(key, value);

  Future<bool> setBool(String key, bool value) => _preferences!.setBool(key, value);

  Future<bool> setInt(String key, int value) => _preferences!.setInt(key, value);

  Future<bool> setDouble(String key, double value) => _preferences!.setDouble(key, value);

  Future<bool> remove(String key) => _preferences!.remove(key);
}
