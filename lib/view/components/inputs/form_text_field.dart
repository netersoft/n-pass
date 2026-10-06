import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../core/services/i18n/translations.g.dart';

import '../../themes/app_theme.dart';

class FormTextField extends StatelessWidget {
  final String name;
  final String hint;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final String? Function(String?)? validator;
  final ValueChanged<String?>? onChanged;
  final double? bottomSpace;
  final bool showDivider;

  const FormTextField({
    required this.name,
    required this.hint,
    super.key,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.bottomSpace = 20,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      FormBuilderTextField(
        name: name,
        initialValue: initialValue,
        style: TextStyle(color: AppTheme.getTextColor()),
        cursorColor: Theme.of(context).colorScheme.primary,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        minLines: 1,
        decoration: InputDecoration(
          hintText: t[hint],
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          border: InputBorder.none,
          icon: icon != null
              ? Icon(
                  icon,
                  color: AppTheme.getIconColor(),
                  size: 18,
                )
              : null,
        ),
        validator: validator,
        onChanged: onChanged,
      ),
      if (showDivider) Divider(color: Colors.grey.shade600),
      SizedBox(height: bottomSpace),
    ],
  );
}
