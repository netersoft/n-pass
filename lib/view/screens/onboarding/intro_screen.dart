import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../../core/providers/onboarding/intro_provider.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';

class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intro = ref.watch(introProvider);

    final pageColor = AppTheme.pickColor(
      light: intro.currentIndex.isOdd ? AppTheme.secondaryColor : AppTheme.primaryColor,
      dark: AppColors.blackRussian,
    );

    PageViewModel page(IconData icon, String title, String body) => PageViewModel(
      titleWidget: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'open_sans', fontWeight: FontWeight.w600, color: Colors.white, fontSize: 28.0),
      ),
      bodyWidget: Text(
        body,
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'open_sans', color: Colors.white70, fontSize: 18.0),
      ),
      image: Center(child: Icon(icon, size: 120, color: Colors.white)),
      decoration: PageDecoration(pageColor: pageColor, imageFlex: 2, bodyFlex: 2),
    );

    final introPages = [
      page(Icons.shield_outlined, context.t.introTitle1, context.t.introBody1),
      page(Icons.cloud_off_outlined, context.t.introTitle2, context.t.introBody2),
      page(Icons.key_outlined, context.t.introTitle3, context.t.introBody3),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(backgroundColor: pageColor),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => IntroductionScreen(
            pages: introPages,
            back: Text(
              context.t.introBackText,
              style: TextStyle(
                fontFamily: 'open_sans',
                fontWeight: FontWeight.bold,
                color: AppTheme.pickColor(
                  light: AppTheme.primaryColor,
                  dark: Colors.white,
                ),
              ),
            ),
            next: Text(
              context.t.introNextText,
              style: TextStyle(
                fontFamily: 'open_sans',
                fontWeight: FontWeight.bold,
                color: AppTheme.pickColor(
                  light: AppTheme.primaryColor,
                  dark: Colors.white,
                ),
              ),
            ),
            done: Text(
              context.t.introDoneText,
              style: TextStyle(
                fontFamily: 'open_sans',
                fontWeight: FontWeight.bold,
                color: AppTheme.pickColor(
                  light: AppTheme.primaryColor,
                  dark: Colors.white,
                ),
              ),
            ),
            skip: Text(
              context.t.introSkipText,
              style: TextStyle(
                fontFamily: 'open_sans',
                fontWeight: FontWeight.bold,
                color: AppTheme.pickColor(
                  light: AppTheme.primaryColor,
                  dark: Colors.white,
                ),
              ),
            ),
            dotsDecorator: DotsDecorator(
              activeColor: AppTheme.pickColor(
                light: AppTheme.primaryColor,
                dark: AppTheme.secondaryColor,
              ),
            ),
            showBackButton: true,
            onChange: (index) {
              ref.read(introProvider.notifier).updateIndex(index);
            },
            onDone: () {
              ref.read(introProvider.notifier).onDone();
            },
          ),
        ),
      ),
    );
  }
}
