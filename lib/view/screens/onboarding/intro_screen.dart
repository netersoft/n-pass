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

    final introPages = [
      PageViewModel(
        titleWidget: Column(
          children: [
            Text(
              context.t.appName,
              style: const TextStyle(
                fontFamily: 'open_sans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 42.0,
              ),
            ),
            const Text(
              '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'open_sans',
                color: Colors.grey,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
        bodyWidget: const SizedBox.shrink(),
        image: const Column(),
        decoration: PageDecoration(
          pageColor: AppTheme.pickColor(
            light: (intro.currentIndex + 1).isEven ? AppTheme.secondaryColor : AppTheme.primaryColor,
            dark: AppColors.blackRussian,
          ),
          imageAlignment: Alignment.topCenter,
          imageFlex: 3,
        ),
        reverse: true,
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: AppTheme.pickColor(
            light: (intro.currentIndex + 1).isEven ? AppTheme.secondaryColor : AppTheme.primaryColor,
            dark: AppColors.blackRussian,
          ),
        ),
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
