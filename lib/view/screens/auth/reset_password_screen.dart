import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth/reset_password_provider.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0.0,
      backgroundColor: AppTheme.getAppbarBgColor(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          context.pop();
        },
      ),
    ),
    body: KeyboardDismissOnTap(
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(20.0),
        color: AppTheme.pickColor(
          light: AppTheme.primaryColor,
          dark: AppColors.raisinBlack,
        ),
        child: ResetPasswordForm(),
      ),
    ),
  );
}

class ResetPasswordForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  ResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetPassword = ref.watch(resetPasswordProvider);

    return SingleChildScrollView(
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 5),
            SvgPicture.asset(
              'assets/images/launcher/logo_reverse.svg',
              width: 200,
            ),
            const SizedBox(height: 30),
            FormBuilderTextField(
              name: 'token',
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: context.t.resetPasswordToken,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: const Icon(Icons.vpn_key, color: Colors.white30),
              ),
              validator: FormBuilderValidators.required(),
            ),
            Divider(color: Colors.grey.shade600),
            FormBuilderTextField(
              name: 'email',
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: context.t.emailAddress,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: const Icon(Icons.email, color: Colors.white30),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
            ),
            Divider(color: Colors.grey.shade600),
            FormBuilderTextField(
              name: 'password',
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: context.t.newPassword,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: const Icon(Icons.lock, color: Colors.white30),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(8),
              ]),
            ),
            Divider(color: Colors.grey.shade600),
            FormBuilderTextField(
              name: 'passwordConfirmation',
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: context.t.confirmPassword,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: const Icon(Icons.lock, color: Colors.white30),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (value) => _formKey.currentState?.fields['password']?.value != value ? context.t.passwordsDoNotMatch : null,
              ]),
            ),
            Divider(color: Colors.grey.shade600),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate(
                            autoScrollWhenFocusOnInvalid: true,
                          ) ??
                          false) {
                        if (_formKey.currentState != null) {
                          var success = await ref
                              .read(resetPasswordProvider.notifier)
                              .submit(
                                _formKey.currentState!.fields,
                              );

                          if (success && context.mounted) {
                            context
                              ..pop()
                              ..pop();
                          }
                        }
                      }
                    },
                    icon: resetPassword.isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const SpinKitRing(
                              color: Colors.white,
                              lineWidth: 2.5,
                              size: 24,
                            ),
                          )
                        : const Icon(Icons.lock_reset, color: Colors.white, size: 21),
                    label: Text(context.t.resetPassword),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
