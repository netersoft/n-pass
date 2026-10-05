import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/helpers/logging/log_helper.dart';
import '../../../core/providers/auth/google_auth_provider.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';

class GoogleAuth extends ConsumerWidget {
  const GoogleAuth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(googleAuthProvider);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final unableToLoginText = context.t.unableToLogin;
          try {
            var result = await ref.read(googleAuthProvider.notifier).googleSignIn();
            if (context.mounted && result.ticket != null) {
              unawaited(
                TwoFactorChallengeRoute(
                  $extra: TwoFactorChallengeExtra(ticket: result.ticket!),
                ).push(context),
              );
            } else if (result.success && context.mounted) {
              const MainRoute().pushReplacement(context);
            }
          } catch (e) {
            LogHelper.e('error = $e');
            unawaited(EasyLoading.showError(unableToLoginText));
          }
        },
        icon: SvgPicture.asset(
          'assets/images/google.svg',
          width: 21,
        ),
        label: Text(context.t.continueWithGoogle),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.3,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
