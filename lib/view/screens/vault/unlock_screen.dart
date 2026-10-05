import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/ui/dialog_helper.dart';
import '../../../core/providers/vault/unlock_provider.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../components/inputs/password_field.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    AppTheme.setStatusBarColor();
    // Offer biometrics right away, like the system lock screen does.
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(unlockProvider.notifier).unlockWithBiometrics());
  }

  void _unlock() {
    final password = _formKey.currentState?.fields['password']?.value as String? ?? '';
    if (password.isEmpty) return;
    ref.read(unlockProvider.notifier).unlockWithPassword(password);
  }

  Future<void> _forgotPassword() async {
    final erase = await DialogHelper.confirm(
      context,
      title: context.t.forgotMasterPassword,
      content: context.t.forgotMasterPasswordBody,
      confirmLabel: context.t.eraseVault,
      destructive: true,
    );
    if (!erase || !mounted) return;
    final confirmed = await DialogHelper.confirm(
      context,
      title: context.t.eraseVault,
      content: context.t.eraseVaultConfirm,
      confirmLabel: context.t.eraseVault,
      destructive: true,
    );
    if (confirmed) await ref.read(unlockProvider.notifier).eraseVault();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unlockProvider);
    final notifier = ref.read(unlockProvider.notifier);

    final errorText = switch (state.message) {
      UnlockMessage.wrongPassword => context.t.wrongPassword,
      UnlockMessage.biometricsChanged => context.t.biometricsChanged,
      UnlockMessage.none => null,
    };

    return KeyboardDismissOnTap(
      child: Scaffold(
        backgroundColor: AppTheme.pickColor(light: AppTheme.primaryColor, dark: AppColors.raisinBlack),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, size: 72, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    context.t.appName,
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(context.t.vaultLocked, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 32),
                  Card(
                    color: AppTheme.getBgDefaultColor(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          children: [
                            PasswordField(
                              name: 'password',
                              label: context.t.masterPassword,
                              autofocus: !state.biometricsEnabled,
                              enabled: !state.isUnlocking,
                              textInputAction: TextInputAction.done,
                              errorText: errorText,
                              onChanged: (_) {
                                if (state.message != UnlockMessage.none) notifier.clearMessage();
                              },
                              onSubmitted: (_) => _unlock(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(52),
                                    ),
                                    onPressed: state.isUnlocking ? null : _unlock,
                                    child: Text(state.isUnlocking ? context.t.unlocking : context.t.unlock),
                                  ),
                                ),
                                if (state.biometricsEnabled) ...[
                                  const SizedBox(width: 12),
                                  IconButton.outlined(
                                    iconSize: 30,
                                    tooltip: context.t.useBiometrics,
                                    onPressed: state.isUnlocking ? null : notifier.unlockWithBiometrics,
                                    icon: const Icon(Icons.fingerprint),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: state.isUnlocking ? null : _forgotPassword,
                    child: Text(context.t.forgotMasterPassword, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
