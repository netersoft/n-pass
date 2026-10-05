import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../../../core/providers/i18n/i18n_fields_provider.dart';
import '../../../core/services/i18n/config.dart';
import '../../themes/app_theme.dart';

class I18nHtmlField extends ConsumerStatefulWidget {
  final String? initialValue;
  final void Function(String?)? onLocaleCodeChanged;
  final void Function(String?)? onChanged;

  const I18nHtmlField({
    super.key,
    this.initialValue,
    this.onLocaleCodeChanged,
    this.onChanged,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _I18nHtmlFieldState();
}

class _I18nHtmlFieldState extends ConsumerState<I18nHtmlField> {
  HtmlEditorController controller = HtmlEditorController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(i18nFieldsProvider.notifier).initHtmlField(widget.initialValue, controller);
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18nFieldsState = ref.watch(i18nFieldsProvider);

    return Column(
      children: [
        DropdownButton<String>(
          value: i18nFieldsState.fieldLocaleCode,
          onChanged: (value) => ref
              .read(i18nFieldsProvider.notifier)
              .onHtmlFieldLocaleCodeChanged(
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
        const SizedBox(width: 10),
        HtmlEditor(
          controller: controller,
          htmlEditorOptions: HtmlEditorOptions(
            darkMode: !AppTheme.isLight(),
            adjustHeightForKeyboard: false,
          ),
          otherOptions: const OtherOptions(height: 200),
          callbacks: Callbacks(
            onChangeContent: (content) => ref
                .read(i18nFieldsProvider.notifier)
                .onHtmlFieldValueChanged(
                  content,
                  widget.onChanged,
                  controller,
                ),
          ),
        ),
      ],
    );
  }
}
