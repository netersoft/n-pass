import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/ui/dialog_helper.dart';
import '../../../core/models/vault_entry.dart';
import '../../../core/providers/vault/entries_provider.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../../core/tools/functions/password_strength.dart';
import '../../components/vault/copy_feedback.dart';
import '../../components/vault/entry_avatar.dart';
import '../../components/vault/strength_meter.dart';
import '../../themes/app_theme.dart';

class EntryDetailScreen extends ConsumerWidget {
  final String id;

  const EntryDetailScreen({required this.id, super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, VaultEntry entry) async {
    final confirmed = await DialogHelper.confirm(
      context,
      title: context.t.deleteEntry,
      content: context.t.deleteEntryConfirm(title: entry.title),
      confirmLabel: context.t.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final entries = ref.read(entriesProvider.notifier);
    context.pop();
    await entries.delete(entry.id);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(t.entryDeleted(title: entry.title)),
        action: SnackBarAction(label: t.undo, onPressed: () => entries.save(entry)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(entryByIdProvider(id));
    final dateFormat = DateFormat.yMMMd(LocaleSettings.instance.currentLocale.languageCode).add_Hm();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.getAppbarBgColor(),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: entry == null
            ? null
            : [
                IconButton(
                  tooltip: context.t.edit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => EditEntryRoute(id: id).push<void>(context),
                ),
                IconButton(tooltip: context.t.deleteEntry, icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, entry)),
              ],
      ),
      body: entry == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                Center(child: EntryAvatar(title: entry.title, radius: 36)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    entry.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                if (entry.username.isNotEmpty) _FieldTile(icon: Icons.person_outline, label: context.t.username, value: entry.username),
                if (entry.email.isNotEmpty) _FieldTile(icon: Icons.alternate_email, label: context.t.emailAddress, value: entry.email),
                if (entry.password.isNotEmpty) _PasswordTile(password: entry.password),
                if (entry.url.isNotEmpty) _FieldTile(icon: Icons.language, label: context.t.website, value: entry.url, isUrl: true),
                if (entry.notes.isNotEmpty) _FieldTile(icon: Icons.notes, label: context.t.notes, value: entry.notes, sensitive: true, multiline: true),
                const SizedBox(height: 24),
                Text(
                  '${context.t.createdOn(date: dateFormat.format(entry.createdAt.toLocal()))}\n'
                  '${context.t.updatedOn(date: dateFormat.format(entry.updatedAt.toLocal()))}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool sensitive;
  final bool multiline;
  final bool isUrl;

  const _FieldTile({
    required this.icon,
    required this.label,
    required this.value,
    this.sensitive = false,
    this.multiline = false,
    this.isUrl = false,
  });

  Uri? get _uri {
    final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
    return uri != null && uri.host.isNotEmpty ? uri : null;
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label, style: Theme.of(context).textTheme.bodySmall),
    subtitle: SelectableText(value, maxLines: multiline ? null : 1, style: Theme.of(context).textTheme.bodyLarge),
    isThreeLine: multiline,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isUrl && _uri != null)
          IconButton(
            tooltip: context.t.openWebsite,
            icon: const Icon(Icons.open_in_new),
            onPressed: () => launchUrl(_uri!, mode: LaunchMode.externalApplication),
          ),
        IconButton(
          tooltip: context.t.copy,
          icon: const Icon(Icons.copy),
          onPressed: () => copyWithFeedback(context, field: label, value: value, sensitive: sensitive),
        ),
      ],
    ),
  );
}

class _PasswordTile extends StatefulWidget {
  final String password;

  const _PasswordTile({required this.password});

  @override
  State<_PasswordTile> createState() => _PasswordTileState();
}

class _PasswordTileState extends State<_PasswordTile> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.key),
    title: Text(context.t.password, style: Theme.of(context).textTheme.bodySmall),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _visible ? widget.password : '•' * widget.password.length.clamp(8, 16),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: _visible ? 'monospace' : null),
        ),
        const SizedBox(height: 6),
        StrengthMeter(strength: estimatePasswordStrength(widget.password)),
      ],
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: _visible ? context.t.hide : context.t.show,
          icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _visible = !_visible),
        ),
        IconButton(
          tooltip: context.t.copy,
          icon: const Icon(Icons.copy),
          onPressed: () => copyWithFeedback(context, field: context.t.password, value: widget.password, sensitive: true),
        ),
      ],
    ),
  );
}
