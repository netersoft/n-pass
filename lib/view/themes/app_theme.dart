import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/enums/app_brightness.dart';
import '../../core/extensions/color_extension.dart';
import '../../core/services/di/locator.dart';
import '../../core/services/shared_preferences/keys.dart';
import '../../core/services/shared_preferences/service.dart';
import '../../core/tools/constants/delays.dart';
import '../../core/tools/functions/color_functions.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static final Color primaryColor = ColorX.fromHex(
    dotenv.get('APP_PRIMARY_COLOR'),
  );
  static final Color secondaryColor = ColorX.fromHex(
    dotenv.get('APP_SECONDARY_COLOR'),
  );
  static final Color accentColor = ColorX.fromHex(
    dotenv.get('APP_ACCENT_COLOR'),
  );

  static const String _fontFamily = 'montserrat';

  static final SharedPreferencesService prefs = locator<SharedPreferencesService>();

  static bool isLight() {
    String? brightness = prefs.getString(
      PrefKeys.brightness,
      defaultValue: AppBrightness.system.name,
    );

    if (brightness == AppBrightness.light.name) return true;

    if (brightness == AppBrightness.dark.name) return false;

    return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
  }

  static Color getContentRelativeColor(Color color) {
    if (color == primaryColor) return Colors.white;

    return isColorDark(color) ? Colors.white : Colors.black;
  }

  static dynamic pickByTheme({required dynamic light, required dynamic dark}) => isLight() ? light : dark;

  static Color pickColor({required Color light, required Color dark}) => isLight() ? light : dark;

  static Color getBgDefaultColor() => isLight() ? Colors.white : AppColors.blackRussian;

  static Color getAppbarBgColor() => isLight() ? primaryColor : AppColors.raisinBlack;

  static Color getIconColor() => isLight() ? primaryColor : accentColor;

  static Color getTextColor() => isLight() ? AppColors.blackRussian : AppColors.concrete;

  static void setStatusBarColor() {
    Future.delayed(const Duration(milliseconds: Delays.veryShort), () {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: isLight() ? primaryColor : AppColors.blackRussian,
        ),
      );
    });
  }

  static ThemeData setup(BuildContext context, {bool lightTheme = true}) => isLight() ? _buildLightTheme(context) : _buildDarkTheme(context);

  static ThemeData _buildLightTheme(BuildContext context) {
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      canvasColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.accent,
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(secondary: Colors.white),
      ),
      fontFamily: _fontFamily,
      colorScheme: colorScheme.copyWith(
        secondary: secondaryColor,
        surface: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(indicatorColor: Colors.white),
    );
    return base.copyWith(
      textTheme: base.textTheme,
      primaryTextTheme: base.primaryTextTheme,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.black38;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return null;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.black26;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.black45;
        }),
      ),
    );
  }

  static ThemeData _buildDarkTheme(BuildContext context) {
    final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      primaryColorDark: primaryColor,
      primaryColorLight: secondaryColor,
      canvasColor: AppColors.blackRussian,
      scaffoldBackgroundColor: AppColors.blackRussian,
      buttonTheme: ButtonThemeData(
        colorScheme: colorScheme,
        textTheme: ButtonTextTheme.primary,
      ),
      fontFamily: _fontFamily,
      colorScheme: colorScheme.copyWith(
        secondary: secondaryColor,
        surface: AppColors.blackRussian,
      ),
      tabBarTheme: const TabBarThemeData(indicatorColor: Colors.white),
    );
    return base.copyWith(
      textTheme: base.textTheme,
      primaryTextTheme: base.primaryTextTheme,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return null;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.white24;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white30;
          }
          return Colors.white54;
        }),
      ),
    );
  }
}
