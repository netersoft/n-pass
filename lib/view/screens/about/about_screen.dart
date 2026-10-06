import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _logo = 'assets/images/launcher/logo.png';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppTheme.getAppbarBgColor(),
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(context.t.about, style: const TextStyle(color: Colors.white)),
    ),
    body: FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final version = info == null ? '' : '${info.version} (${info.buildNumber})';
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          children: [
            Center(child: Image.asset(_logo, width: 96, height: 96)),
            const SizedBox(height: 16),
            Text(
              context.t.appName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (version.isNotEmpty)
              Text(
                context.t.versionLabel(version: version),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('${context.t.appDescription}\n\n${context.t.legacyNotice}', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(context.t.licenseNotice, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(context.t.privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const PrivacyPolicyRoute().push<void>(context),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(context.t.openSourceLicenses),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: context.t.appName,
                applicationVersion: version,
                applicationIcon: Padding(padding: const EdgeInsets.all(12), child: Image.asset(_logo, width: 64, height: 64)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: Text(context.t.credits),
              subtitle: Text(context.t.effWordlistCredit),
            ),
            const Divider(height: 1),
          ],
        );
      },
    ),
  );
}
