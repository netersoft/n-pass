import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/helpers/router/navigation_helper.dart';
import '../../core/helpers/ui/dialog_helper.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/account/profile_provider.dart';
import '../../core/providers/main_provider.dart';
import '../../core/routes/app_route.dart';
import '../../core/services/di/locator.dart';
import '../../core/services/hive/keys.dart';
import '../../core/services/i18n/translations.g.dart';
import '../components/image/user_avatar.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import 'main/home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static Widget defaultAppBar(
    MainState mainProvider,
  ) => AppBar(
    elevation: 0.0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/launcher/logo_reverse.svg',
          width: 90.0,
        ),
      ],
    ),
    actions: [
      IconButton(
        onPressed: () {
          locator<NavigationHelper>().push(const SettingsRoute().location);
        },
        icon: const Icon(
          Icons.settings,
          color: Colors.white,
        ),
      ),
    ],
    backgroundColor: AppTheme.getAppbarBgColor(),
    iconTheme: const IconThemeData(color: Colors.white),
  );

  static Widget searchAppBar() => AppBar(
    elevation: 0.0,
    actions: <Widget>[
      const SizedBox(
        width: 60,
      ),
      Expanded(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            ref.watch(mainProvider);
            final controller = ref.watch(searchTextControllerProvider);
            return TextField(
              cursorColor: Colors.white,
              controller: controller,
              style: const TextStyle(fontSize: 18, color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.white54,
                ),
                hintText: context.t.search,
              ),
              onChanged: (value) {},
            );
          },
        ),
      ),
    ],
    backgroundColor: AppTheme.getAppbarBgColor(),
    iconTheme: const IconThemeData(color: Colors.white),
  );

  @override
  Widget build(BuildContext context) => const KeyboardDismissOnTap(child: CentralContainer());
}

class CentralContainer extends ConsumerStatefulWidget {
  const CentralContainer({super.key});

  @override
  ConsumerState<CentralContainer> createState() => _CentralContainerState();
}

class _CentralContainerState extends ConsumerState<CentralContainer> {
  @override
  void initState() {
    super.initState();

    AppTheme.setStatusBarColor();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(AppBar().preferredSize.height),
      child: ref.read(mainProvider.notifier).selectAppBar(),
    ),
    body: const HomeScreen(),
    drawer: Drawer(
      backgroundColor: AppTheme.pickColor(
        light: Colors.white,
        dark: AppColors.blackRussian,
      ),
      child: ValueListenableBuilder(
        valueListenable: Hive.box(HiveKeys.auth).listenable(),
        builder: (context, Box box, _) {
          UserModel? userData = box.get(HiveKeys.authUserData);
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              if (userData != null)
                GestureDetector(
                  onTap: () {
                    const ProfileRoute().push(context);
                  },
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: AppTheme.pickColor(
                        light: AppTheme.primaryColor,
                        dark: AppColors.raisinBlack,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        UserAvatar(
                          userData: userData,
                          backgroundColor: Colors.black87,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          userData.name ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          userData.email ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppTheme.pickColor(
                      light: AppTheme.primaryColor,
                      dark: AppColors.raisinBlack,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.t.welcome,
                        style: const TextStyle(
                          fontSize: 21,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          const ProvidersRoute().push(context);
                        },
                        icon: const Icon(Icons.login, color: Colors.white, size: 21),
                        label: Text(context.t.logIn),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              if (userData != null)
                ListTile(
                  title: Text(context.t.myProfile),
                  leading: const Icon(Icons.account_circle),
                  onTap: () {
                    const ProfileRoute().push(context);
                  },
                )
              else
                const SizedBox.shrink(),
              ListTile(
                title: Text(context.t.settings),
                leading: const Icon(Icons.settings),
                onTap: () {
                  const SettingsRoute().push(context);
                },
              ),
              if (userData != null)
                ListTile(
                  title: Text(context.t.logOut),
                  leading: const Icon(Icons.logout),
                  onTap: () {
                    DialogHelper.showContent(
                      context,
                      title: Text(
                        context.t.about,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      content: Text(context.t.sureToLogOut),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            context.t.cancel,
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
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
                            ),
                          ),
                          onPressed: () {
                            ref.read(profileProvider.notifier).logout();
                            context.pop();
                          },
                        ),
                      ],
                    );
                  },
                )
              else
                const SizedBox.shrink(),
            ],
          );
        },
      ),
    ),
  );
}
