import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../core/enums/app_brightness.dart';
import '../../../core/providers/account/security_settings_provider.dart';
import '../../../core/providers/account/settings_provider.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/services/auto_lock/service.dart';
import '../../../core/services/i18n/config.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../components/misc/floating_modal.dart';
import '../../themes/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0.0,
      title: Text(
        context.t.settings,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: AppTheme.getAppbarBgColor(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          context.pop();
        },
      ),
    ),
    body: const SettingsListWrapper(),
  );
}

String autoLockLabel(int seconds) {
  if (seconds == 0) return t.autoLockImmediately;
  if (seconds < 3600) return t.autoLockAfter(duration: t.minutes(n: seconds ~/ 60));
  return t.autoLockAfter(duration: t.hours(n: seconds ~/ 3600));
}

class SettingsListWrapper extends ConsumerWidget {
  const SettingsListWrapper({super.key});

  Future<void> _toggleBiometrics(BuildContext context, WidgetRef ref, bool enabled) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(securitySettingsProvider.notifier).setBiometrics(enabled);
    final message = !ok
        ? t.biometricsEnableFailed
        : enabled
        ? t.biometricsEnabledDone
        : t.biometricsDisabled;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  void _pickAutoLockDelay(BuildContext context, WidgetRef ref, int current) => showFloatingModalBottomSheet<void>(
    context: context,
    builder: (context) => Material(
      child: SafeArea(
        top: false,
        child: RadioGroup<int>(
          groupValue: current,
          onChanged: (value) {
            if (value != null) ref.read(securitySettingsProvider.notifier).setAutoLockDelay(value);
            context.pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AutoLockService.delays.map((seconds) => RadioListTile<int>(title: Text(autoLockLabel(seconds)), value: seconds)).toList(),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider.notifier);
    final security = ref.watch(securitySettingsProvider);

    var currentLang = I18nConfig.langItems.firstWhereOrNull(
      (item) => item.code == LocaleSettings.instance.currentLocale.languageCode,
    );

    return SettingsList(
      sections: [
        SettingsSection(
          title: Text(context.t.securitySection),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.password),
              trailing: const Icon(Icons.chevron_right),
              title: Text(context.t.changeMasterPassword),
              onPressed: (context) => const ChangePasswordRoute().push<void>(context),
            ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.fingerprint),
              title: Text(context.t.useBiometrics),
              description: security.biometricsAvailable || security.biometricsEnabled ? null : Text(context.t.biometricsNotEnrolled),
              enabled: security.biometricsAvailable || security.biometricsEnabled,
              initialValue: security.biometricsEnabled,
              activeSwitchColor: AppTheme.primaryColor,
              onToggle: (value) => _toggleBiometrics(context, ref, value),
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.lock_clock_outlined),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(autoLockLabel(security.autoLockDelaySeconds)), const Icon(Icons.chevron_right)],
              ),
              title: Text(context.t.autoLock),
              onPressed: (context) => _pickAutoLockDelay(context, ref, security.autoLockDelaySeconds),
            ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.visibility_outlined),
              title: Text(context.t.revealPasswords),
              description: Text(context.t.revealPasswordsHint),
              initialValue: security.revealPasswords,
              activeSwitchColor: AppTheme.primaryColor,
              onToggle: ref.read(securitySettingsProvider.notifier).setRevealPasswords,
            ),
          ],
        ),
        SettingsSection(
          title: Text(context.t.dataSection),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.cloud_upload_outlined),
              trailing: const Icon(Icons.chevron_right),
              title: Text(context.t.backupAndRestore),
              onPressed: (context) => const BackupRoute().push<void>(context),
            ),
          ],
        ),
        SettingsSection(
          title: Text(context.t.appearanceSection),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.language),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentLang?.label[currentLang.code] ?? ''),
                  const Icon(Icons.chevron_right),
                ],
              ),
              title: Text(context.t.language),
              onPressed: (context) => {
                showFloatingModalBottomSheet(
                  context: context,
                  builder: (context) => Material(
                    child: SafeArea(
                      top: false,
                      child: RadioGroup<String>(
                        groupValue: LocaleSettings.instance.currentLocale.languageCode,
                        onChanged: (value) {
                          if (value != LocaleSettings.instance.currentLocale.languageCode) {
                            settings.changeLanguage(value!);
                            context.pop();
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: I18nConfig.langItems
                              .map<Widget>(
                                (item) => RadioListTile(
                                  title: Text(item.label[currentLang?.code]!),
                                  value: item.code,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              },
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.format_paint),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    settings.getAppBrightness() == AppBrightness.system.name
                        ? context.t.system
                        : settings.getAppBrightness() == AppBrightness.light.name
                        ? context.t.light
                        : context.t.dark,
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              title: Text(context.t.theme),
              onPressed: (context) => {
                showFloatingModalBottomSheet(
                  context: context,
                  builder: (context) => Material(
                    child: SafeArea(
                      top: false,
                      child: RadioGroup<String>(
                        groupValue: settings.getAppBrightness(),
                        onChanged: (value) {
                          if (value != settings.getAppBrightness()) {
                            settings.setAppBrightness(value!);
                            context.pop();
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile(
                              title: Text(context.t.light),
                              value: AppBrightness.light.name,
                            ),
                            RadioListTile(
                              title: Text(context.t.dark),
                              value: AppBrightness.dark.name,
                            ),
                            RadioListTile(
                              title: Text(context.t.system),
                              value: AppBrightness.system.name,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              },
            ),
          ],
        ),
        SettingsSection(
          title: Text(context.t.appName),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.info_outline),
              trailing: const Icon(Icons.chevron_right),
              title: Text(context.t.about),
              onPressed: (context) => const AboutRoute().push<void>(context),
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.privacy_tip_outlined),
              trailing: const Icon(Icons.chevron_right),
              title: Text(context.t.privacyPolicy),
              onPressed: (context) => const PrivacyPolicyRoute().push<void>(context),
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.campaign),
              trailing: const Icon(Icons.chevron_right),
              title: Text(context.t.recommandApp),
              onPressed: (context) => {
                showFloatingModalBottomSheet(
                  context: context,
                  builder: (context) => Material(
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(context.t.byEmail),
                            trailing: const Icon(
                              Icons.email,
                              size: 21.0,
                            ),
                            onTap: () => settings.share(ShareOptions.email),
                          ),
                          ListTile(
                            title: Text(context.t.bySms),
                            trailing: const Icon(
                              Icons.sms,
                              size: 21.0,
                            ),
                            onTap: () => settings.share(ShareOptions.sms),
                          ),
                          ListTile(
                            title: Text(context.t.share),
                            trailing: const Icon(
                              Icons.share,
                              size: 21.0,
                            ),
                            onTap: () => settings.share(ShareOptions.free),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              },
            ),
          ],
        ),
      ],
    );
  }
}
