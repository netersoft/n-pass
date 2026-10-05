import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../themes/app_theme.dart';

/// Obscured text field with a show/hide toggle. Disables suggestions and
/// autocorrect so the keyboard doesn't learn the password.
class PasswordField extends StatefulWidget {
  final String name;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String?>? onChanged;
  final ValueChanged<String?>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final String? errorText;

  const PasswordField({
    required this.name,
    required this.label,
    super.key,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) => FormBuilderTextField(
    name: widget.name,
    obscureText: _obscured,
    enableSuggestions: false,
    autocorrect: false,
    autofocus: widget.autofocus,
    enabled: widget.enabled,
    keyboardType: TextInputType.visiblePassword,
    textInputAction: widget.textInputAction,
    cursorColor: AppTheme.primaryColor,
    style: TextStyle(color: AppTheme.getTextColor()),
    decoration: InputDecoration(
      labelText: widget.label,
      errorText: widget.errorText,
      errorMaxLines: 3,
      prefixIcon: Icon(Icons.key, color: AppTheme.getIconColor()),
      suffixIcon: IconButton(
        icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
      border: const OutlineInputBorder(),
    ),
    validator: widget.validator,
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
  );
}
