abstract class PrefKeys {
  static const brightness = 'appBrightness';
  static const firstOpening = 'appFirstOpening';

  /// Set once the in-app review sheet was requested (see ReviewService).
  static const reviewRequested = 'reviewRequested';

  /// When the in-app review sheet was requested (ms since epoch), the store dialog waits after it.
  static const reviewRequestedAt = 'reviewRequestedAt';

  /// How many times the store dialog was shown, and when last (ms since epoch).
  static const rateDialogCount = 'rateDialogCount';
  static const rateDialogLastAt = 'rateDialogLastAt';

  /// The user rated, or asked not to be asked again.
  static const rateDone = 'rateDone';
  static const biometricsEnabled = 'biometricsEnabled';
  static const autoLockDelaySeconds = 'autoLockDelaySeconds';
  static const entrySort = 'entrySort';
  static const generatorOptions = 'generatorOptions';
  static const revealPasswords = 'revealPasswords';
  static const lastBackupAt = 'lastBackupAt';
  static const language = 'appLanguage';
}
