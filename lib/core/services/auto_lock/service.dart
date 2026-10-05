import '../shared_preferences/keys.dart';
import '../shared_preferences/service.dart';

/// Decides when the vault must be locked after the app went to the background.
class AutoLockService {
  /// Delays offered in the settings, in seconds (0 = as soon as the app leaves
  /// the foreground).
  static const List<int> delays = [0, 60, 120, 600, 1800, 3600];
  static const int defaultDelay = 60;

  /// Minimum delay while the user is in a system screen opened by the app
  /// (file picker, share sheet), so short trips there never lock the vault.
  static const int externalGraceSeconds = 300;

  final SharedPreferencesService _prefs;
  final DateTime Function() _now;

  DateTime? _backgroundedAt;
  bool _backgroundedForExternal = false;
  int _externalDepth = 0;

  AutoLockService(this._prefs, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  int get delaySeconds => _prefs.getInt(PrefKeys.autoLockDelaySeconds, defaultValue: defaultDelay) ?? defaultDelay;

  Future<void> setDelaySeconds(int seconds) => _prefs.setInt(PrefKeys.autoLockDelaySeconds, seconds);

  /// Records when the app left the foreground; keeps the first timestamp when
  /// called several times in a row (hidden then paused).
  void onBackground() {
    if (_backgroundedAt != null) return;
    _backgroundedAt = _now();
    _backgroundedForExternal = _externalDepth > 0;
  }

  /// Returns true when the app was away for at least [delaySeconds] (at least
  /// [externalGraceSeconds] when it left for [whileExternal]).
  bool onForeground() {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null) return false;
    final delay = _backgroundedForExternal && delaySeconds < externalGraceSeconds ? externalGraceSeconds : delaySeconds;
    return _now().difference(since).inSeconds >= delay;
  }

  /// Runs [action], which opens a system screen over the app.
  Future<T> whileExternal<T>(Future<T> Function() action) async {
    _externalDepth++;
    try {
      return await action();
    } finally {
      _externalDepth--;
    }
  }
}
