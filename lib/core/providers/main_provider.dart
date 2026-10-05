import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../view/screens/main_screen.dart';

part 'main_provider.g.dart';

final searchTextControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

@riverpod
class Main extends _$Main {
  @override
  MainState build() => const MainState();

  void updateTabIndex(int index) {
    state = state.copyWith(currentTabIndex: index);
  }

  void toggleBottomBar(bool visible) {
    state = state.copyWith(bottomBarIsVisible: visible);
  }

  Widget selectAppBar() {
    switch (state.currentTabIndex) {
      case MainState.searchTabIndex:
        return MainScreen.searchAppBar();
      default:
        return MainScreen.defaultAppBar(state);
    }
  }
}

class MainState {
  final int currentTabIndex;
  final bool bottomBarIsVisible;

  static const int homeTabIndex = 0;
  static const int searchTabIndex = 1;
  static const int notificationsTabIndex = 2;
  static const int pageTabIndex = 3;

  const MainState({
    this.currentTabIndex = 0,
    this.bottomBarIsVisible = true,
  });

  MainState copyWith({int? currentTabIndex, bool? bottomBarIsVisible}) => MainState(
    currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    bottomBarIsVisible: bottomBarIsVisible ?? this.bottomBarIsVisible,
  );
}
