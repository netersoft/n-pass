import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../core/enums/app_brightness.dart';
import '../../../core/helpers/ui/dialog_helper.dart';
import '../../../core/providers/account/settings_provider.dart';
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

class SettingsListWrapper extends ConsumerWidget {
  const SettingsListWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider.notifier);

    var currentLang = I18nConfig.langItems.firstWhereOrNull(
      (item) => item.code == LocaleSettings.instance.currentLocale.languageCode,
    );

    return SettingsList(
      sections: [
        SettingsSection(
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
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.info),
              trailing: const Icon(Icons.chevron_right),
              title: Text(context.t.about),
              onPressed: (context) => {
                DialogHelper.showContent(
                  context,
                  title: Text(
                    context.t.about,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppTheme.pickByTheme(
                          light: 'assets/images/launcher/logo.svg',
                          dark: 'assets/images/launcher/logo_reverse.svg',
                        ),
                        width: 160.0,
                      ),
                      Text(
                        context.t.appNameAlt,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (ctx, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              'Version ${snapshot.data!.version}',
                              style: const TextStyle(fontSize: 14.0),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 25),
                      Text(
                        context.t.appDescription,
                        style: const TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              },
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
                            title: Text(context.t.byWhatsapp),
                            trailing: SvgPicture.asset(
                              'assets/images/whatsapp.svg',
                              width: 21.0,
                              height: 21.0,
                            ),
                            onTap: () => settings.share(ShareOptions.whatsapp),
                          ),
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
