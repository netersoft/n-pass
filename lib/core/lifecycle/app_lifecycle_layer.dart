import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/logging/log_helper.dart';

class AppLifecycleLayer extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleLayer({
    required this.child,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppLifecycleLayerState();
}

class _AppLifecycleLayerState extends ConsumerState<AppLifecycleLayer> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
      onExitRequested: _onExitRequested,
    );

    super.initState();
  }

  @override
  void dispose() {
    _listener.dispose();

    super.dispose();
  }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        _onDetached();
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.inactive:
        _onInactive();
      case AppLifecycleState.hidden:
        _onHidden();
      case AppLifecycleState.paused:
        _onPaused();
    }
  }

  void _onDetached() {
    LogHelper.i('App detached');
  }

  void _onResumed() {
    LogHelper.i('App resumed');
  }

  void _onInactive() {
    LogHelper.i('App inactive');
  }

  void _onHidden() {
    LogHelper.i('App hidden');
  }

  void _onPaused() {
    LogHelper.i('App paused');
  }

  Future<AppExitResponse> _onExitRequested() async => AppExitResponse.exit;

  @override
  Widget build(BuildContext context) => widget.child;
}
