import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/providers/global_provider.dart';
import '../../core/services/i18n/translations.g.dart';
import '../components/misc/status.dart';
import '../themes/app_theme.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  final Widget? loader;
  final bool checkServer;
  final bool checkDatabase;

  const MainLayout({
    required this.child,
    super.key,
    this.loader,
    this.checkServer = false,
    this.checkDatabase = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAvailabilityChecks();
    });
  }

  @override
  void didUpdateWidget(covariant MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.checkServer != widget.checkServer || oldWidget.checkDatabase != widget.checkDatabase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runAvailabilityChecks();
      });
    }
  }

  Future<void> _runAvailabilityChecks() async {
    if (!mounted) return;

    final global = ref.read(globalProvider.notifier);

    await global.checkConnectivity();

    if (widget.checkServer) {
      await global.checkServerAvailability();
    }

    if (widget.checkDatabase) {
      await global.checkDatabaseAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    final global = ref.watch(globalProvider);

    if (global.isCheckingConnection || global.isCheckingServer || global.isCheckingDatabase) {
      if (widget.loader != null) {
        return widget.loader!;
      }

      return Center(
        child: SpinKitRing(
          color: AppTheme.pickColor(
            light: AppTheme.primaryColor,
            dark: Colors.white,
          ),
          lineWidth: 5.0,
        ),
      );
    }

    if (!global.isConnected) {
      return Status(
        icon: Icons.wifi_off,
        text: context.t.noConnection,
        footerWidget: RebuildBtn(
          rebuild: true,
          onRetry: _runAvailabilityChecks,
        ),
      );
    }

    if (widget.checkServer && !global.isServerAvailable) {
      return Status(
        icon: Icons.warning,
        text: context.t.serverUnavailable,
        footerWidget: RebuildBtn(
          rebuild: true,
          onRetry: _runAvailabilityChecks,
        ),
      );
    }

    if (widget.checkDatabase && !global.isDatabaseAvailable) {
      return Status(
        icon: Icons.warning,
        text: context.t.databaseUnavailable,
        footerWidget: RebuildBtn(
          rebuild: true,
          onRetry: _runAvailabilityChecks,
        ),
      );
    }

    return widget.child;
  }
}

class RebuildBtn extends ConsumerWidget {
  final bool rebuild;
  final VoidCallback? onRetry;

  const RebuildBtn({
    super.key,
    this.rebuild = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      const SizedBox(
        height: 25,
      ),
      ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.t.loading}...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          if (rebuild) ref.read(globalProvider.notifier).rebuild();
          onRetry?.call();
        },
        icon: const Icon(Icons.refresh),
        label: Text(context.t.retry),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
      ),
    ],
  );
}
