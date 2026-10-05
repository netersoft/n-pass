import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/ui/dialog_helper.dart';
import '../../../core/models/vault_entry.dart';
import '../../../core/providers/vault/backup_provider.dart';
import '../../../core/providers/vault/create_vault_provider.dart';
import '../../../core/providers/vault/entries_provider.dart';
import '../../../core/services/backup/service.dart';
import '../../../core/services/di/locator.dart';
import '../../../core/services/files/service.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../../core/services/vault/crypto.dart';
import '../../components/vault/password_prompt_dialog.dart';
import '../../themes/app_theme.dart';

enum _ExportTarget { device, share }

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  static void _snack(ScaffoldMessengerState messenger, String text) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final backup = ref.read(backupProvider.notifier);
    final files = locator<FileTransferService>();
    if ((await ref.read(entriesProvider.future)).isEmpty) {
      _snack(messenger, t.nothingToBackUp);
      return;
    }
    if (!context.mounted) return;

    Uint8List? bytes;
    await showPasswordPrompt(
      context,
      title: context.t.exportBackup,
      message: context.t.backupPasswordHint,
      label: context.t.backupPassword,
      submitLabel: context.t.continueLabel,
      confirm: true,
      minLength: CreateVault.minLength,
      onSubmit: (password) async {
        bytes = await backup.export(password);
        return null;
      },
    );
    final data = bytes;
    if (data == null || !context.mounted) return;

    final target = files.canSaveToDevice ? await _pickTarget(context) : _ExportTarget.share;
    if (target == null || !context.mounted) return;

    final name = 'npass-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.${BackupService.fileExtension}';
    final box = context.findRenderObject() as RenderBox?;
    final exported = switch (target) {
      _ExportTarget.device => await files.saveToDevice(name, data),
      _ExportTarget.share => await files.share(
        name,
        data,
        subject: t.backupShareSubject,
        origin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    };
    if (!exported) return;
    await backup.markExported();
    _snack(messenger, t.backupExported);
  }

  Future<_ExportTarget?> _pickTarget(BuildContext context) => showModalBottomSheet<_ExportTarget>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(context.t.exportTo, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: Text(context.t.saveToDevice),
            subtitle: Text(context.t.saveToDeviceHint),
            onTap: () => context.pop(_ExportTarget.device),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(context.t.shareFile),
            subtitle: Text(context.t.shareFileHint),
            onTap: () => context.pop(_ExportTarget.share),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final backup = ref.read(backupProvider.notifier);

    final bytes = await locator<FileTransferService>().pickFile();
    if (bytes == null || !context.mounted) return;
    try {
      backup.validate(bytes);
    } on BackupFormatException catch (e) {
      _snack(messenger, e.newerVersion ? t.backupFromNewerVersion : t.invalidBackupFile);
      return;
    }

    List<VaultEntry>? imported;
    await showPasswordPrompt(
      context,
      title: context.t.importBackup,
      message: context.t.restoreBackupPasswordBody,
      label: context.t.backupPassword,
      submitLabel: context.t.continueLabel,
      onSubmit: (password) async {
        try {
          imported = await backup.decrypt(bytes, password);
          return null;
        } on VaultAuthException {
          return t.wrongPassword;
        }
      },
    );
    final entries = imported;
    if (entries == null || !context.mounted) return;

    final current = await ref.read(entriesProvider.future);
    if (!context.mounted) return;
    final mode = current.isEmpty ? ImportMode.merge : await _pickMode(context, entries.length);
    if (mode == null || !context.mounted) return;
    if (mode == ImportMode.replace) {
      final confirmed = await DialogHelper.confirm(
        context,
        title: context.t.importReplace,
        content: context.t.importReplaceConfirm(accounts: context.t.accountsCount(n: current.length)),
        confirmLabel: context.t.importReplace,
        destructive: true,
      );
      if (!confirmed) return;
    }

    final plan = await backup.restore(entries, mode);
    _snack(messenger, t.importDone(added: plan.added, updated: plan.updated));
  }

  Future<ImportMode?> _pickMode(BuildContext context, int count) => showDialog<ImportMode>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(
        context.t.restoreTitle(accounts: context.t.accountsCount(n: count)),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
      ),
      children: [
        ListTile(
          leading: const Icon(Icons.merge_type),
          title: Text(context.t.importMerge),
          subtitle: Text(context.t.importMergeHint),
          onTap: () => context.pop(ImportMode.merge),
        ),
        ListTile(
          leading: Icon(Icons.restore_page_outlined, color: Theme.of(context).colorScheme.error),
          title: Text(context.t.importReplace),
          subtitle: Text(context.t.importReplaceHint),
          onTap: () => context.pop(ImportMode.replace),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(onPressed: () => context.pop(), child: Text(context.t.cancel)),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupProvider);
    final lastBackupAt = state.lastBackupAt;
    final dateFormat = DateFormat.yMMMd(LocaleSettings.instance.currentLocale.languageCode).add_Hm();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.getAppbarBgColor(),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(context.t.backupAndRestore, style: const TextStyle(color: Colors.white)),
      ),
      body: AbsorbPointer(
        absorbing: state.isBusy,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Icon(Icons.cloud_upload_outlined, size: 56, color: AppTheme.getIconColor()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(context.t.backupBody, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            Text(
              lastBackupAt == null ? context.t.noBackupYet : context.t.lastBackup(date: dateFormat.format(lastBackupAt.toLocal())),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (state.isBusy) const LinearProgressIndicator(),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(context.t.exportBackup),
              subtitle: Text(context.t.exportBackupHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _export(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(context.t.importBackup),
              subtitle: Text(context.t.importBackupHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _import(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
