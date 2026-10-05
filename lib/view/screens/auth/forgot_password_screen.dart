import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth/forgot_password_provider.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final AuthExtra? extra;

  const ForgotPasswordScreen({super.key, this.extra});

  @override
  Widget build(BuildContext context) {
    final displayBackButton = extra?.displayBackButton ?? true;
    final displayPageFooter = extra?.displayPageFooter ?? false;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppTheme.getAppbarBgColor(),
        leading: displayBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.pop();
                },
              )
            : const SizedBox.shrink(),
      ),
      body: KeyboardDismissOnTap(
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.all(20.0),
          color: AppTheme.pickColor(
            light: AppTheme.primaryColor,
            dark: AppColors.raisinBlack,
          ),
          child: ForgotPasswordScreenForm(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: displayPageFooter
            ? const Stack(
                children: [
                  ForgotPasswordScreenBottomBar(),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class ForgotPasswordScreenForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final _emailFieldKey = GlobalKey<FormBuilderFieldState>();

  ForgotPasswordScreenForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgotPassword = ref.watch(forgotPasswordProvider);

    return SingleChildScrollView(
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 5,
            ),
            SvgPicture.asset(
              'assets/images/launcher/logo_reverse.svg',
              width: 200,
            ),
            const SizedBox(
              height: 50,
            ),
            FormBuilderTextField(
              key: _emailFieldKey,
              name: 'email',
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: context.t.emailAddress,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: const Icon(
                  Icons.email,
                  color: Colors.white30,
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
            ),
            Divider(
              color: Colors.grey.shade600,
            ),
            const SizedBox(
              height: 20,
            ),
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
                              .read(forgotPasswordProvider.notifier)
                              .submit(
                                _formKey.currentState!.fields,
                              );
                          if (success) {
                            _formKey.currentState?.reset();
                          }
                        }
                      }
                    },
                    icon: forgotPassword.isLoading
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
                        : const Icon(
                            Icons.lock_reset,
                            color: Colors.white,
                            size: 21,
                          ),
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
            const SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: () {
                context.pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade300,
                textStyle: const TextStyle(
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: Text(context.t.logIn),
            ),
            TextButton(
              onPressed: () {
                const ResetPasswordRoute().push(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade300,
                textStyle: const TextStyle(
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: Text(context.t.resetPasswordToken),
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreenBottomBar extends StatelessWidget {
  const ForgotPasswordScreenBottomBar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 60.0,
    decoration: BoxDecoration(
      color: AppTheme.pickColor(
        light: AppTheme.primaryColor,
        dark: AppColors.raisinBlack,
      ),
      border: const Border(
        top: BorderSide(
          color: Colors.grey,
          width: 0.5,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
          ),
          child: Text(
            context.t.skip,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          onPressed: () {
            context.pushReplacement(const MainRoute().location);
          },
        ),
      ],
    ),
  );
}
