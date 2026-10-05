import '../../services/biometrics/service.dart';
import '../../services/i18n/translations.g.dart';

BiometricPrompt localizedBiometricPrompt() => BiometricPrompt(title: t.biometricPromptTitle, cancel: t.biometricPromptCancel);
