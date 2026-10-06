import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_theme.dart';

class ErrorScreen extends StatelessWidget {
  final GoException? error;

  const ErrorScreen(this.error, {super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0.0,
      title: Text(
        context.t.pageNotFound,
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
    body: ErrorScreenContent(error: error),
  );
}

class ErrorScreenContent extends StatelessWidget {
  final GoException? error;

  const ErrorScreenContent({super.key, this.error});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_outlined, size: 160, color: Colors.orange),
          const SizedBox(height: 10),
          Text(
            error?.message ?? context.t.anErrorOccurred,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: () {
              context.pushReplacement(const RedirectionRoute().location);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(context.t.backToHome),
          ),
        ],
      ),
    ),
  );
}
