import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/router/navigation_helper.dart';
import '../../routes/app_route.dart';
import '../../services/di/locator.dart';
import '../../services/shared_preferences/keys.dart';
import '../../services/shared_preferences/service.dart';

part 'intro_provider.g.dart';

final _navigationHelper = locator<NavigationHelper>();

@riverpod
class Intro extends _$Intro {
  @override
  IntroState build() => const IntroState();

  void updateIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void onDone() {
    locator<SharedPreferencesService>().setBool(PrefKeys.firstOpening, false);

    _navigationHelper.pushReplacement(const MainRoute().location);
  }
}

class IntroState {
  final int currentIndex;

  const IntroState({this.currentIndex = 0});

  IntroState copyWith({int? currentIndex}) => IntroState(currentIndex: currentIndex ?? this.currentIndex);
}
