import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/vault_entry.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_theme.dart';

/// Asks for the name of a new custom field and whether its value is secret.
/// Resolves to an empty field, or null when cancelled.
Future<CustomField?> showCustomFieldDialog(BuildContext context) => showDialog<CustomField>(context: context, builder: (context) => const _CustomFieldDialog());

class _CustomFieldDialog extends StatefulWidget {
  const _CustomFieldDialog();

  @override
  State<_CustomFieldDialog> createState() => _CustomFieldDialogState();
}

class _CustomFieldDialogState extends State<_CustomFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  bool _hidden = false;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.pop(CustomField(label: _label.text.trim(), hidden: _hidden));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.t.addCustomField, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _label,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: context.t.fieldLabel, hintText: context.t.fieldLabelHint, border: const OutlineInputBorder()),
            validator: (value) => (value ?? '').trim().isEmpty ? context.t.fieldLabelRequired : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.t.hiddenField),
            subtitle: Text(context.t.hiddenFieldHint),
            value: _hidden,
            onChanged: (value) => setState(() => _hidden = value),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => context.pop(), child: Text(context.t.cancel)),
      TextButton(
        onPressed: _submit,
        child: Text(context.t.add, style: const TextStyle(color: AppTheme.primaryColor)),
      ),
    ],
  );
}
