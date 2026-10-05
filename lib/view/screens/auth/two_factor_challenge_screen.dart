import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth/two_factor_challenge_provider.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_theme.dart';

class TwoFactorChallengeScreen extends StatelessWidget {
  final TwoFactorChallengeExtra extra;

  const TwoFactorChallengeScreen({required this.extra, super.key});

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
        child: TwoFactorChallengeForm(ticket: extra.ticket),
      ),
    ),
  );
}

class TwoFactorChallengeForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final String ticket;

  TwoFactorChallengeForm({required this.ticket, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(twoFactorChallengeProvider);

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
            if (challenge.useRecoveryCode)
              FormBuilderTextField(
                name: 'recoveryCode',
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: context.t.recoveryCode,
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  icon: const Icon(Icons.key, color: Colors.white30),
                ),
                validator: FormBuilderValidators.required(),
              )
            else
              FormBuilderTextField(
                name: 'code',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: context.t.verificationCode,
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  icon: const Icon(Icons.pin, color: Colors.white30),
                ),
                validator: FormBuilderValidators.required(),
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
                              .read(twoFactorChallengeProvider.notifier)
                              .submit(
                                ticket,
                                _formKey.currentState!.fields,
                              );

                          if (success && context.mounted) {
                            const MainRoute().pushReplacement(context);
                          }
                        }
                      }
                    },
                    icon: challenge.isLoading
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
                        : const Icon(Icons.check, color: Colors.white, size: 21),
                    label: Text(context.t.verify),
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
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                ref.read(twoFactorChallengeProvider.notifier).toggleUseRecoveryCode();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade300,
                textStyle: const TextStyle(
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: Text(
                challenge.useRecoveryCode ? context.t.useVerificationCodeInstead : context.t.useRecoveryCodeInstead,
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
