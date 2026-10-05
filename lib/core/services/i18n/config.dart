abstract class I18nConfig {
  static List<LangItem> langItems = [
    LangItem(
      label: {
        'fr': 'Français',
        'en': 'French',
      },
      code: 'fr',
    ),
    LangItem(
      label: {
        'fr': 'Anglais',
        'en': 'English',
      },
      code: 'en',
    ),
  ];
}

class LangItem {
  Map<String, String> label;
  String code;

  LangItem({required this.label, required this.code});
}
