import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/helpers/ui/dialog_helper.dart';
import '../../../core/models/vault_entry.dart';
import '../../../core/providers/vault/entries_provider.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../../core/services/vault/service.dart';
import '../../../core/tools/functions/password_strength.dart';
import '../../../core/tools/functions/url_functions.dart';
import '../../components/inputs/password_field.dart';
import '../../components/vault/generator_sheet.dart';
import '../../components/vault/strength_meter.dart';
import '../../themes/app_theme.dart';

/// Creates an entry, or edits the one with [entryId].
class EntryFormScreen extends ConsumerStatefulWidget {
  final String? entryId;

  const EntryFormScreen({super.key, this.entryId});

  @override
  ConsumerState<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends ConsumerState<EntryFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final VaultEntry? _original = widget.entryId == null ? null : ref.read(entryByIdProvider(widget.entryId!));
  late String _password = _original?.password ?? '';
  bool _dirty = false;
  bool _saving = false;

  Future<void> _generate() async {
    final generated = await showGeneratorSheet(context);
    if (generated == null) return;
    _formKey.currentState?.fields['password']?.didChange(generated);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;
    String field(String name) => (values[name] as String? ?? '').trim();

    final now = DateTime.now().toUtc();
    final entry = (_original ?? VaultEntry(id: VaultService.newEntryId(), title: '', createdAt: now, updatedAt: now)).copyWith(
      title: field('title'),
      username: field('username'),
      email: field('email'),
      // Passwords are kept exactly as typed, spaces included.
      password: values['password'] as String? ?? '',
      url: field('url'),
      notes: values['notes'] as String? ?? '',
      updatedAt: now,
    );

    setState(() => _saving = true);
    await ref.read(entriesProvider.notifier).save(entry);
    if (!mounted) return;
    _dirty = false;
    context.pop();
  }

  Future<void> _confirmDiscard() async {
    final discard = await DialogHelper.confirm(
      context,
      title: context.t.discardChangesTitle,
      content: context.t.discardChangesBody,
      confirmLabel: context.t.discard,
      destructive: true,
    );
    if (discard && mounted) {
      setState(() => _dirty = false);
      context.pop();
    }
  }

  String? _validateUrl(String? value) {
    final url = (value ?? '').trim();
    if (url.isEmpty) return null;
    return isUrl(url.contains('://') ? url : 'https://$url', allowLocal: true) ? null : context.t.invalidUrl;
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ? null : context.t.invalidEmail;
  }

  InputDecoration _decoration(String label, IconData icon, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: AppTheme.getIconColor()),
    border: const OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    final original = _original;
    const gap = SizedBox(height: 16);

    return KeyboardDismissOnTap(
      child: PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmDiscard();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.getAppbarBgColor(),
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(original == null ? context.t.newEntry : context.t.editEntry, style: const TextStyle(color: Colors.white)),
            actions: [
              IconButton(tooltip: context.t.save, icon: const Icon(Icons.check), onPressed: _saving ? null : _save),
            ],
          ),
          body: SafeArea(
            child: FormBuilder(
              key: _formKey,
              onChanged: () => _dirty = true,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  FormBuilderTextField(
                    name: 'title',
                    initialValue: original?.title,
                    autofocus: original == null,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(context.t.entryTitle, Icons.label_outline, hint: context.t.entryTitleHint),
                    validator: (value) => (value ?? '').trim().isEmpty ? context.t.entryTitleRequired : null,
                  ),
                  gap,
                  FormBuilderTextField(
                    name: 'username',
                    initialValue: original?.username,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(context.t.username, Icons.person_outline),
                  ),
                  gap,
                  FormBuilderTextField(
                    name: 'email',
                    initialValue: original?.email,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(context.t.emailAddress, Icons.alternate_email),
                    validator: _validateEmail,
                  ),
                  gap,
                  PasswordField(
                    name: 'password',
                    label: context.t.password,
                    initialValue: original?.password,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => setState(() => _password = value ?? ''),
                    actions: [
                      IconButton(tooltip: context.t.generatePassword, icon: const Icon(Icons.casino_outlined), onPressed: _generate),
                    ],
                  ),
                  if (_password.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    StrengthMeter(strength: estimatePasswordStrength(_password)),
                  ],
                  gap,
                  FormBuilderTextField(
                    name: 'url',
                    initialValue: original?.url,
                    autocorrect: false,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(context.t.website, Icons.language, hint: 'example.com'),
                    validator: _validateUrl,
                  ),
                  gap,
                  FormBuilderTextField(
                    name: 'notes',
                    initialValue: original?.notes,
                    minLines: 3,
                    maxLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoration(context.t.notes, Icons.notes),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _saving ? null : _save,
                    child: Text(context.t.save),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
