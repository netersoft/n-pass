import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/totp_config.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../../core/tools/functions/totp.dart';
import '../../themes/app_theme.dart';
import 'copy_feedback.dart';

/// The current 2FA code with a countdown to the next one.
class TotpTile extends StatefulWidget {
  final TotpConfig config;

  const TotpTile({required this.config, super.key});

  @override
  State<TotpTile> createState() => _TotpTileState();
}

class _TotpTileState extends State<TotpTile> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final code = generateTotp(widget.config, now);
    final remaining = totpSecondsRemaining(widget.config, now);
    final ending = remaining <= 5;

    return ListTile(
      leading: const Icon(Icons.verified_user_outlined),
      title: Text(context.t.totpCode, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(
        formatTotp(code),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontFamily: 'monospace',
          letterSpacing: 2,
          color: ending ? Theme.of(context).colorScheme.error : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: remaining / widget.config.period,
                  strokeWidth: 3,
                  color: ending ? Theme.of(context).colorScheme.error : AppTheme.primaryColor,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                ),
                Text('$remaining', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          IconButton(
            tooltip: context.t.copy,
            icon: const Icon(Icons.copy),
            onPressed: () => copyWithFeedback(context, field: context.t.totpCode, value: code, sensitive: true),
          ),
        ],
      ),
    );
  }
}
