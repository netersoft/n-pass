import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/vault/create_vault_provider.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../components/inputs/password_field.dart';
import '../../components/vault/strength_meter.dart';
import '../../themes/app_theme.dart';

class CreateVaultScreen extends ConsumerStatefulWidget {
  const CreateVaultScreen({super.key});

  @override
  ConsumerState<CreateVaultScreen> createState() => _CreateVaultScreenState();
}

class _CreateVaultScreenState extends ConsumerState<CreateVaultScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _showAcknowledgeError = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    AppTheme.setStatusBarColor();
  }

  Future<void> _submit() async {
    final state = ref.read(createVaultProvider);
    final formValid = _formKey.currentState?.saveAndValidate() ?? false;
    setState(() {
      _submitted = true;
      _showAcknowledgeError = !state.acknowledged;
    });
    if (!formValid || !state.acknowledged) return;

    final password = _formKey.currentState!.value['password'] as String;
    final messenger = ScaffoldMessenger.of(context);
    final biometricsEnabled = await ref.read(createVaultProvider.notifier).submit(password);
    if (!biometricsEnabled) {
      messenger.showSnackBar(SnackBar(content: Text(t.biometricsEnableFailed), behavior: SnackBarBehavior.floating));
    }
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < CreateVault.minLength) return context.t.masterPasswordTooShort(min: CreateVault.minLength);
    if (!ref.read(createVaultProvider).isStrongEnough) return context.t.masterPasswordTooWeak;
    return null;
  }

  String? _validateConfirmation(String? value) => value != _formKey.currentState?.fields['password']?.value ? context.t.passwordsDoNotMatch : null;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createVaultProvider);
    final notifier = ref.read(createVaultProvider.notifier);

    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: AppTheme.getAppbarBgColor(),
          title: Text(context.t.appName, style: const TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: FormBuilder(
            key: _formKey,
            // Errors refresh as the user types once they tried to submit.
            autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                Icon(Icons.shield_outlined, size: 56, color: AppTheme.getIconColor()),
                const SizedBox(height: 16),
                Text(
                  context.t.createVaultTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(context.t.createVaultBody, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                PasswordField(
                  name: 'password',
                  label: context.t.masterPassword,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isSubmitting,
                  onChanged: (value) {
                    notifier.setPassword(value ?? '');
                    if (_submitted) _formKey.currentState?.fields['confirmation']?.validate();
                  },
                  validator: _validatePassword,
                ),
                const SizedBox(height: 10),
                StrengthMeter(strength: state.strength),
                const SizedBox(height: 20),
                PasswordField(
                  name: 'confirmation',
                  label: context.t.confirmMasterPassword,
                  textInputAction: TextInputAction.done,
                  enabled: !state.isSubmitting,
                  validator: _validateConfirmation,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                _WarningCard(text: context.t.masterPasswordWarning),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: state.acknowledged,
                  onChanged: state.isSubmitting
                      ? null
                      : (value) {
                          notifier.setAcknowledged(value ?? false);
                          if (value ?? false) setState(() => _showAcknowledgeError = false);
                        },
                  title: Text(context.t.masterPasswordUnderstood),
                  subtitle: _showAcknowledgeError ? Text(context.t.pleaseAcknowledge, style: TextStyle(color: Theme.of(context).colorScheme.error)) : null,
                ),
                if (state.biometricsAvailable)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.fingerprint),
                    value: state.useBiometrics,
                    onChanged: state.isSubmitting ? null : notifier.setUseBiometrics,
                    title: Text(context.t.useBiometrics),
                    subtitle: Text(context.t.useBiometricsHint),
                  ),
                const SizedBox(height: 24),
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
                            Text(context.t.creatingVault),
                          ],
                        )
                      : Text(context.t.createVault),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String text;

  const _WarningCard({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.orange.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
