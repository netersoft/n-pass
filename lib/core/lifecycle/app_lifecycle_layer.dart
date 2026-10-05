import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view/themes/app_colors.dart';
import '../../view/themes/app_theme.dart';
import '../helpers/logging/log_helper.dart';
import '../services/auto_lock/service.dart';
import '../services/di/locator.dart';
import '../services/vault/service.dart';

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
  final VaultService _vault = locator<VaultService>();
  final AutoLockService _autoLock = locator<AutoLockService>();

  /// Hides the vault content while the app is not in the foreground, so it
  /// doesn't show in the app switcher (Android also gets FLAG_SECURE).
  bool _obscured = false;

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
    if (_autoLock.onForeground() && _vault.isUnlocked) _vault.lock();
    _setObscured(false);
  }

  void _onInactive() {
    LogHelper.i('App inactive');
    _setObscured(_vault.isUnlocked);
  }

  void _onHidden() {
    LogHelper.i('App hidden');
    _autoLock.onBackground();
    _setObscured(_vault.isUnlocked);
  }

  void _onPaused() {
    LogHelper.i('App paused');
    _autoLock.onBackground();
  }

  void _setObscured(bool value) {
    if (_obscured != value && mounted) setState(() => _obscured = value);
  }

  Future<AppExitResponse> _onExitRequested() async => AppExitResponse.exit;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_obscured)
          ColoredBox(
            color: AppTheme.pickColor(light: AppTheme.primaryColor, dark: AppColors.raisinBlack),
            child: const Center(child: Icon(Icons.lock_outline, size: 72, color: Colors.white)),
          ),
      ],
    ),
  );
}
