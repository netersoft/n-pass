import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/vault/change_password_provider.dart';
import '../../../core/providers/vault/create_vault_provider.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../components/inputs/password_field.dart';
import '../../components/vault/strength_meter.dart';
import '../../themes/app_theme.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _submitted = false;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final values = _formKey.currentState!.value;
    final messenger = ScaffoldMessenger.of(context);
    final changed = await ref.read(changePasswordProvider.notifier).submit(values['current'] as String, values['password'] as String);
    if (!changed || !mounted) return;
    context.pop();
    messenger.showSnackBar(SnackBar(content: Text(t.masterPasswordChanged), behavior: SnackBarBehavior.floating));
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < CreateVault.minLength) return context.t.masterPasswordTooShort(min: CreateVault.minLength);
    if (!ref.read(changePasswordProvider).isStrongEnough) return context.t.masterPasswordTooWeak;
    if (password == _formKey.currentState?.fields['current']?.value) return context.t.sameAsCurrentPassword;
    return null;
  }

  String? _validateConfirmation(String? value) => value != _formKey.currentState?.fields['password']?.value ? context.t.passwordsDoNotMatch : null;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordProvider);
    final notifier = ref.read(changePasswordProvider.notifier);

    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.getAppbarBgColor(),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(context.t.changeMasterPassword, style: const TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                Text(context.t.changeMasterPasswordBody),
                const SizedBox(height: 24),
                PasswordField(
                  name: 'current',
                  label: context.t.currentPassword,
                  autofocus: true,
                  enabled: !state.isSubmitting,
                  textInputAction: TextInputAction.next,
                  errorText: state.wrongCurrentPassword ? context.t.wrongPassword : null,
                  validator: (value) => (value ?? '').isEmpty ? context.t.passwordRequired : null,
                  onChanged: (_) => notifier.clearWrongPassword(),
                ),
                const SizedBox(height: 20),
                PasswordField(
                  name: 'password',
                  label: context.t.newMasterPassword,
                  enabled: !state.isSubmitting,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    notifier.setNewPassword(value ?? '');
                    if (_submitted) _formKey.currentState?.fields['confirmation']?.validate();
                  },
                  validator: _validatePassword,
                ),
                const SizedBox(height: 10),
                StrengthMeter(strength: state.strength),
                const SizedBox(height: 20),
                PasswordField(
                  name: 'confirmation',
                  label: context.t.confirmNewMasterPassword,
                  enabled: !state.isSubmitting,
                  textInputAction: TextInputAction.done,
                  validator: _validateConfirmation,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: state.isSubmitting ? null : _submit,
                  child: state.isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            const SizedBox(width: 12),
                            Text(context.t.changingPassword),
                          ],
                        )
                      : Text(context.t.changeMasterPassword),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
