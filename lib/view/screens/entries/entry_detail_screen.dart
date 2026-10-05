import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/ui/dialog_helper.dart';
import '../../../core/models/vault_entry.dart';
import '../../../core/providers/vault/entries_provider.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/services/di/locator.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../../core/services/shared_preferences/keys.dart';
import '../../../core/services/shared_preferences/service.dart';
import '../../../core/tools/functions/entry_functions.dart';
import '../../../core/tools/functions/password_strength.dart';
import '../../components/vault/copy_feedback.dart';
import '../../components/vault/entry_avatar.dart';
import '../../components/vault/reuse_warning.dart';
import '../../components/vault/strength_meter.dart';
import '../../components/vault/totp_tile.dart';
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
    final sharing = entry == null
        ? const <VaultEntry>[]
        : entriesSharingPassword(ref.watch(entriesProvider).value ?? const [], entry.password, exceptId: entry.id);
    final dateFormat = DateFormat.yMMMd(LocaleSettings.instance.currentLocale.languageCode).add_Hm();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.getAppbarBgColor(),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: entry == null
            ? null
            : [
                IconButton(
                  tooltip: entry.favorite ? context.t.removeFromFavorites : context.t.addToFavorites,
                  icon: Icon(entry.favorite ? Icons.star : Icons.star_border, color: entry.favorite ? Colors.amber : null),
                  onPressed: () => ref.read(entriesProvider.notifier).toggleFavorite(entry),
                ),
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
                if (entry.category.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Chip(avatar: const Icon(Icons.folder_outlined, size: 18), label: Text(entry.category), visualDensity: VisualDensity.compact),
                  ),
                ],
                const SizedBox(height: 20),
                if (entry.username.isNotEmpty) _FieldTile(icon: Icons.person_outline, label: context.t.username, value: entry.username),
                if (entry.email.isNotEmpty) _FieldTile(icon: Icons.alternate_email, label: context.t.emailAddress, value: entry.email),
                if (entry.password.isNotEmpty) _PasswordTile(password: entry.password),
                if (sharing.isNotEmpty) ReuseWarning(titles: sharing.map((e) => e.title).toList()),
                if (entry.totp case final totp?) TotpTile(config: totp),
                if (entry.url.isNotEmpty) _FieldTile(icon: Icons.language, label: context.t.website, value: entry.url, isUrl: true),
                for (final field in entry.customFields.where((f) => f.value.isNotEmpty))
                  if (field.hidden)
                    _SecretTile(icon: Icons.lock_outline, label: field.label, value: field.value)
                  else
                    _FieldTile(icon: Icons.short_text, label: field.label, value: field.value),
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

class _PasswordTile extends StatelessWidget {
  final String password;

  const _PasswordTile({required this.password});

  @override
  Widget build(BuildContext context) => _SecretTile(
    icon: Icons.key,
    label: context.t.password,
    value: password,
    footer: StrengthMeter(strength: estimatePasswordStrength(password)),
  );
}

/// A masked value with show/hide and sensitive copy.
class _SecretTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? footer;

  const _SecretTile({required this.icon, required this.label, required this.value, this.footer});

  @override
  State<_SecretTile> createState() => _SecretTileState();
}

class _SecretTileState extends State<_SecretTile> {
  bool _visible = locator<SharedPreferencesService>().getBool(PrefKeys.revealPasswords, defaultValue: false) ?? false;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(widget.icon),
    title: Text(widget.label, style: Theme.of(context).textTheme.bodySmall),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _visible ? widget.value : '•' * widget.value.length.clamp(8, 16),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: _visible ? 'monospace' : null),
        ),
        if (widget.footer != null) ...[const SizedBox(height: 6), widget.footer!],
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
          onPressed: () => copyWithFeedback(context, field: widget.label, value: widget.value, sensitive: true),
        ),
      ],
    ),
  );
}
