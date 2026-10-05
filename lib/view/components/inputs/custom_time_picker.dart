import 'package:flutter/material.dart';

import '../../themes/app_theme.dart';

Future<TimeOfDay?> customTimePicker(BuildContext context) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(), // heure actuelle
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: AppTheme.primaryColor,
          onPrimary: AppTheme.pickColor(
            light: Colors.white,
            dark: AppTheme.primaryColor,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
          ),
        ),
      ),
      child: child!,
    ),
  );
  return picked;
}
