// lib/tools/date_picker_helper.dart

import 'package:flutter/material.dart';

import '../../themes/app_theme.dart';

Future<DateTime?> customDatePicker(BuildContext context) async {
  final DateTime firstDate = DateTime(2000);
  final DateTime initialDate = DateTime.now();
  final DateTime lastDate = DateTime(2100);

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) => AppTheme.isLight()
        ? Theme(data: Theme.of(context).copyWith(), child: child!)
        : Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTheme.secondaryColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.secondaryColor,
                ),
              ),
            ),
            child: child!,
          ),
  );
}
