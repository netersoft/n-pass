import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/i18n/i18n_fields_provider.dart';
import '../../../core/services/i18n/config.dart';

class I18nTextField extends ConsumerStatefulWidget {
  final String name;
  final String? initialValue;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  final void Function(String?)? onLocaleCodeChanged;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final TextInputAction? textInputAction;

  const I18nTextField({
    required this.name,
    super.key,
    this.initialValue,
    this.decoration,
    this.validator,
    this.onLocaleCodeChanged,
    this.onChanged,
    this.onSaved,
    this.readOnly = false,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.textInputAction,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _I18nTextFieldState();
}

class _I18nTextFieldState extends ConsumerState<I18nTextField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(i18nFieldsProvider.notifier).initTextField(widget.initialValue, controller);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18nFieldsState = ref.watch(i18nFieldsProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 5,
          child: FormBuilderTextField(
            name: widget.name,
            decoration: widget.decoration ?? const InputDecoration(),
            validator: widget.validator,
            onChanged: (value) => ref
                .read(i18nFieldsProvider.notifier)
                .onTextFieldValueChanged(
                  value,
                  widget.onChanged,
                  controller,
                ),
            onSaved: (value) => ref
                .read(i18nFieldsProvider.notifier)
                .onTextFieldValueChanged(
                  value,
                  widget.onSaved,
                  controller,
                ),
            readOnly: widget.readOnly,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            controller: controller,
            autofocus: widget.autofocus,
            textInputAction: widget.textInputAction,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: DropdownButton<String>(
            value: i18nFieldsState.fieldLocaleCode,
            onChanged: (value) => ref
                .read(i18nFieldsProvider.notifier)
                .onTextFieldLocaleCodeChanged(
                  value,
                  widget.onLocaleCodeChanged,
                  controller,
                ),
            items: I18nConfig.langItems
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.code,
                    child: Text(item.code.toUpperCase()),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
