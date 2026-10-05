import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_theme.dart';
import '../inputs/password_field.dart';

/// Asks for a password in a dialog and resolves to it, or to null when
/// cancelled.
///
/// With [confirm], a second field must match and the password needs at least
/// [minLength] characters. [onSubmit] runs while the dialog shows a progress
/// indicator; it returns an error message to keep the dialog open (e.g.
/// wrong password), or null to close it.
Future<String?> showPasswordPrompt(
  BuildContext context, {
  required String title,
  required String submitLabel,
  String? message,
  String? label,
  bool confirm = false,
  int minLength = 0,
  Future<String?> Function(String password)? onSubmit,
}) => showDialog<String>(
  context: context,
  barrierDismissible: false,
  builder: (context) => _PasswordPromptDialog(
    title: title,
    submitLabel: submitLabel,
    message: message,
    label: label,
    confirm: confirm,
    minLength: minLength,
    onSubmit: onSubmit,
  ),
);

class _PasswordPromptDialog extends StatefulWidget {
  final String title;
  final String submitLabel;
  final String? message;
  final String? label;
  final bool confirm;
  final int minLength;
  final Future<String?> Function(String password)? onSubmit;

  const _PasswordPromptDialog({
    required this.title,
    required this.submitLabel,
    required this.confirm,
    required this.minLength,
    this.message,
    this.label,
    this.onSubmit,
  });

  @override
  State<_PasswordPromptDialog> createState() => _PasswordPromptDialogState();
}

class _PasswordPromptDialogState extends State<_PasswordPromptDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _error;
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy || !(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final password = _formKey.currentState!.value['password'] as String;

    final onSubmit = widget.onSubmit;
    if (onSubmit != null) {
      setState(() {
        _busy = true;
        _error = null;
      });
      final error = await onSubmit(password);
      if (!mounted) return;
      if (error != null) {
        setState(() {
          _busy = false;
          _error = error;
        });
        return;
      }
    }
    if (mounted) context.pop(password);
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return context.t.passwordRequired;
    if (password.length < widget.minLength) return context.t.masterPasswordTooShort(min: widget.minLength);
    return null;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
    content: FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.message != null) ...[Text(widget.message!), const SizedBox(height: 16)],
            PasswordField(
              name: 'password',
              label: widget.label ?? context.t.password,
              autofocus: true,
              enabled: !_busy,
              errorText: _error,
              textInputAction: widget.confirm ? TextInputAction.next : TextInputAction.done,
              validator: _validatePassword,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: widget.confirm ? null : (_) => _submit(),
            ),
            if (widget.confirm) ...[
              const SizedBox(height: 12),
              PasswordField(
                name: 'confirmation',
                label: context.t.confirmBackupPassword,
                enabled: !_busy,
                textInputAction: TextInputAction.done,
                validator: (value) => value != _formKey.currentState?.fields['password']?.value ? context.t.passwordsDoNotMatch : null,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: _busy ? null : () => context.pop(), child: Text(context.t.cancel)),
      TextButton(
        onPressed: _busy ? null : _submit,
        child: _busy
            ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(widget.submitLabel, style: const TextStyle(color: AppTheme.primaryColor)),
      ),
    ],
  );
}
