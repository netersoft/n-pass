import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../core/helpers/ui/dialog_helper.dart';
import '../../../core/providers/account/profile_provider.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../components/image/user_avatar.dart';
import '../../themes/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0.0,
      title: Text(
        context.t.myProfile,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: AppTheme.getAppbarBgColor(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          context.pop();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            const EditProfileRoute().push(context);
          },
        ),
      ],
    ),
    body: const ProfileScreenContent(),
  );
}

class ProfileScreenContent extends ConsumerWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final userData = profile.userData;

    double listPadding = (MediaQuery.of(context).size.width - 810) / 2;

    return SettingsList(
      contentPadding: MediaQuery.of(context).size.width > 810 ? EdgeInsets.symmetric(horizontal: listPadding) : const EdgeInsets.only(bottom: 10),
      sections: [
        CustomSettingsSection(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: userData != null ? UserAvatar(userData: userData) : const SizedBox.shrink(),
          ),
        ),
        SettingsSection(
          title: Text(context.t.basicInformation),
          tiles: [
            SettingsTile(
              title: Text(context.t.name),
              leading: const Icon(Icons.person),
              trailing: Text(userData?.name ?? ''),
            ),
            SettingsTile(
              title: Text(context.t.email),
              leading: const Icon(Icons.email),
              trailing: Text(userData?.email ?? ''),
            ),
            SettingsTile(
              title: const Text('2FA'),
              leading: Icon(userData?.hasTwoFactorEnabled ?? false ? Icons.verified_user : Icons.no_accounts),
              trailing: Text(
                userData?.hasTwoFactorEnabled ?? false ? context.t.twoFactorEnabled : context.t.twoFactorDisabled,
              ),
            ),
          ],
        ),
        if (userData != null && userData.emailVerifiedAt == null)
          SettingsSection(
            tiles: [
              SettingsTile.navigation(
                title: Text(context.t.resendVerificationEmail),
                leading: const Icon(Icons.mark_email_unread),
                onPressed: (context) {
                  ref.read(profileProvider.notifier).resendVerificationEmail();
                },
              ),
            ],
          )
        else
          const CustomSettingsSection(child: SizedBox.shrink()),
        SettingsSection(
          title: Text(context.t.account),
          tiles: [
            SettingsTile(
              title: Text(
                context.t.logOut,
                style: const TextStyle(color: Colors.red),
              ),
              leading: const Icon(Icons.logout, color: Colors.red),
              onPressed: (context) {
                DialogHelper.showContent(
                  context,
                  title: Text(
                    context.t.logOut,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  content: Text(
                    context.t.sureToLogOut,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        context.t.cancel,
                        style: TextStyle(
                          color: AppTheme.secondaryColor,
                          fontSize: 16.0,
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        context.t.yes,
                        style: TextStyle(
                          color: AppTheme.pickColor(
                            light: Colors.black,
                            dark: Colors.white,
                          ),
                          fontSize: 16.0,
                        ),
                      ),
                      onPressed: () {
                        ref.read(profileProvider.notifier).logout();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
