import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth/register_provider.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';

class RegisterScreen extends StatelessWidget {
  final AuthExtra? extra;

  const RegisterScreen({super.key, this.extra});

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
          child: RegisterScreenForm(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: displayPageFooter
            ? const Stack(
                children: [
                  RegisterScreenBottomBar(),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class RegisterScreenForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final _emailFieldKey = GlobalKey<FormBuilderFieldState>();

  RegisterScreenForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final register = ref.watch(registerProvider);

    return SingleChildScrollView(
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            SvgPicture.asset(
              'assets/images/launcher/logo_reverse.svg',
              width: 200,
            ),
            const SizedBox(
              height: 20,
            ),
            FormBuilderTextField(
              name: 'name',
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: context.t.name,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: const Icon(
                  Icons.person,
                  color: Colors.white30,
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            Divider(
              color: Colors.grey.shade600,
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
            FormBuilderTextField(
              name: 'password',
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: context.t.password,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: const Icon(
                  Icons.lock,
                  color: Colors.white30,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    register.passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white30,
                  ),
                  onPressed: () {
                    ref.read(registerProvider.notifier).togglePasswordVisibility();
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              obscureText: !register.passwordVisible,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(8),
              ]),
            ),
            Divider(
              color: Colors.grey.shade600,
            ),
            FormBuilderTextField(
              name: 'passwordConfirmation',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: context.t.confirmPassword,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: const Icon(
                  Icons.lock,
                  color: Colors.white30,
                ),
              ),
              obscureText: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (value) => _formKey.currentState?.fields['password']?.value != value ? context.t.passwordsDoNotMatch : null,
              ]),
            ),
            Divider(
              color: Colors.grey.shade600,
            ),
            FormBuilderFieldDecoration<bool>(
              name: 'accept',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.equal(
                  true,
                  errorText: context.t.youMustAcceptConditions,
                ),
              ]),
              initialValue: false,
              decoration: InputDecoration(
                labelText: context.t.acceptTermsOfUsePrivacyPolicy,
              ),
              builder: (FormFieldState<bool?> field) => InputDecorator(
                decoration: InputDecoration(
                  errorText: field.errorText,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '${context.t.iHaveReadAndAcceptThe} '),
                          TextSpan(
                            text: context.t.termsOfUse.toLowerCase(),
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' ${context.t.andA} '),
                          TextSpan(
                            text: context.t.privacyPolicy.toLowerCase(),
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onChanged: field.didChange,
                    value: field.value ?? false,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate(
                            autoScrollWhenFocusOnInvalid: true,
                          ) ??
                          false) {
                        if (_formKey.currentState != null) {
                          var success = await ref
                              .read(registerProvider.notifier)
                              .submit(
                                _formKey.currentState!.fields,
                              );
                          if (success) {
                            _formKey.currentState?.reset();

                            if (context.mounted) {
                              const MainRoute().pushReplacement(context);
                            }
                          }
                        }
                      }
                    },
                    icon: register.isLoading
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
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                    label: Text(context.t.register),
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
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey.shade300, fontSize: 16),
                children: <TextSpan>[
                  TextSpan(text: '${context.t.alreadyHaveAnAccount} '),
                  TextSpan(
                    text: context.t.logIn,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.pop();
                      },
                  ),
                ],
              ),
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

class RegisterScreenBottomBar extends StatelessWidget {
  const RegisterScreenBottomBar({super.key});

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
