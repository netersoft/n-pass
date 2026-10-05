import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/helpers/router/navigation_helper.dart';
import '../../core/providers/main_provider.dart';
import '../../core/routes/app_route.dart';
import '../../core/services/di/locator.dart';
import '../../core/services/i18n/translations.g.dart';
import '../components/misc/status.dart';
import '../themes/app_theme.dart';

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

  // The vault list replaces this placeholder body.
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(AppBar().preferredSize.height),
      child: ref.read(mainProvider.notifier).selectAppBar(),
    ),
    body: Status(
      icon: Icons.lock_outline,
      text: context.t.noItemFound,
    ),
  );
}
