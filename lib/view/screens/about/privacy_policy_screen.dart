import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_theme.dart';

/// The privacy policy, bundled with the app so it reads offline.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppTheme.getAppbarBgColor(),
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(context.t.privacyPolicy, style: const TextStyle(color: Colors.white)),
    ),
    body: FutureBuilder<String>(
      future: rootBundle.loadString('assets/docs/${LocaleSettings.instance.currentLocale.languageCode}/privacy_policy.html'),
      builder: (context, snapshot) => switch (snapshot.data) {
        final html? => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: HtmlWidget(html, textStyle: Theme.of(context).textTheme.bodyMedium),
        ),
        null => const Center(child: CircularProgressIndicator()),
      },
    ),
  );
}
