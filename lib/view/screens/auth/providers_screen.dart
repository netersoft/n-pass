import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../components/auth/apple_auth.dart';
import '../../components/auth/google_auth.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';

class ProvidersScreen extends StatelessWidget {
  final AuthExtra? extra;

  const ProvidersScreen({super.key, this.extra});

  @override
  Widget build(BuildContext context) {
    final displayBackButton = extra?.displayBackButton ?? true;
    final displayPageFooter = extra?.displayPageFooter ?? false;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppTheme.getAppbarBgColor(),
        leading: displayBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.pop();
                },
              )
            : const SizedBox.shrink(),
      ),
      body: KeyboardDismissOnTap(
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.all(20.0),
          color: AppTheme.pickColor(
            light: AppTheme.primaryColor,
            dark: AppColors.raisinBlack,
          ),
          child: const ProvidersScreenContent(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: displayPageFooter
            ? const Stack(
                children: [
                  ProvidersScreenBottomBar(),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class ProvidersScreenContent extends StatelessWidget {
  const ProvidersScreenContent({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      children: <Widget>[
        SvgPicture.asset(
          AppTheme.pickByTheme(
            light: 'assets/images/launcher/icon_reverse.svg',
            dark: 'assets/images/launcher/icon_reverse.svg',
          ),
          width: 75.0,
        ),
        const SizedBox(
          height: 25,
        ),
        Text(
          context.t.logInOrCreateAccount,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 21.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                unawaited(const LoginRoute().push(context));
              },
              icon: const Icon(Icons.email, color: Colors.white, size: 21),
              label: Text(context.t.continueWithEmailAddress),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
                elevation: 0.3,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 12.0, right: 20.0),
                child: Divider(
                  color: Colors.grey.shade200,
                  thickness: 0.5,
                  height: 36,
                ),
              ),
            ),
            Text(
              context.t.OR,
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 12.0),
                child: Divider(
                  color: Colors.grey.shade200,
                  thickness: 0.5,
                  height: 36,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: GoogleAuth(),
        ),
        if (Platform.isIOS) ...[
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: AppleAuth(),
          ),
        ],
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              children: <TextSpan>[
                TextSpan(text: '${context.t.byContinuingYouAgreeThe} '),
                TextSpan(
                  text: context.t.termsOfUse.toLowerCase(),
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                  ),
                ),
                TextSpan(text: ' ${context.t.andA} '),
                TextSpan(
                  text: context.t.privacyPolicy.toLowerCase(),
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    ),
  );
}

class ProvidersScreenBottomBar extends StatelessWidget {
  const ProvidersScreenBottomBar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 60.0,
    decoration: BoxDecoration(
      color: AppTheme.pickColor(
        light: AppTheme.primaryColor,
        dark: AppColors.raisinBlack,
      ),
      border: const Border(
        top: BorderSide(
          color: Colors.grey,
          width: 0.5,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
          ),
          child: Text(
            context.t.skip,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          onPressed: () {
            context.pushReplacement(const MainRoute().location);
          },
        ),
      ],
    ),
  );
}
