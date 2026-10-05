import '../shared_preferences/keys.dart';
import '../shared_preferences/service.dart';

/// Decides when the vault must be locked after the app went to the background.
class AutoLockService {
  /// Delays offered in the settings, in seconds (0 = as soon as the app leaves
  /// the foreground).
  static const List<int> delays = [0, 60, 120, 600, 1800, 3600];
  static const int defaultDelay = 60;

  final SharedPreferencesService _prefs;
  final DateTime Function() _now;

  DateTime? _backgroundedAt;

  AutoLockService(this._prefs, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  int get delaySeconds => _prefs.getInt(PrefKeys.autoLockDelaySeconds, defaultValue: defaultDelay) ?? defaultDelay;

  Future<void> setDelaySeconds(int seconds) => _prefs.setInt(PrefKeys.autoLockDelaySeconds, seconds);

  /// Records when the app left the foreground; keeps the first timestamp when
  /// called several times in a row (hidden then paused).
  void onBackground() => _backgroundedAt ??= _now();

  /// Returns true when the app was away for at least [delaySeconds].
  bool onForeground() {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null) return false;
    return _now().difference(since).inSeconds >= delaySeconds;
  }
}
