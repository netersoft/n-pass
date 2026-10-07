#!/usr/bin/env python3
"""Builds the public privacy policy pages from the in-app HTML.

The app ships the policy as HTML fragments (assets/docs/<locale>/). The store
listings need it at a public URL, served by GitHub Pages from the
netersoft/netersoft.github.io repository. Run this after editing the policy,
then commit and push that repository:

    python3 tool/build_privacy_pages.py ../netersoft.github.io

Writes <site>/n-pass/privacy/index.html (fr) and
<site>/n-pass/privacy/en/index.html.
"""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE_URL = 'https://netersoft.github.io/n-pass/privacy/'

LOCALES = {
    # locale: (output dir relative to n-pass/privacy, page title, switch label)
    'fr': ('', 'Politique de confidentialité – NPass', 'English'),
    'en': ('en/', 'Privacy policy – NPass', 'Français'),
}

TEMPLATE = """<!doctype html>
<html lang="{lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<link rel="canonical" href="{url}">
{alternates}
{redirect}<style>
  :root {{ color-scheme: light dark; --text: #202124; --muted: #5f6368; --bg: #ffffff; --accent: #0000cd; --line: #e0e0e0; }}
  @media (prefers-color-scheme: dark) {{
    :root {{ --text: #f2f2f2; --muted: #a9a9a9; --bg: #202124; --accent: #b4bcff; --line: #3c4043; }}
  }}
  body {{ margin: 0; background: var(--bg); color: var(--text); font: 16px/1.6 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }}
  main {{ max-width: 720px; margin: 0 auto; padding: 24px 16px 48px; }}
  nav {{ display: flex; justify-content: space-between; align-items: center; padding-bottom: 12px; border-bottom: 1px solid var(--line); }}
  nav strong {{ color: var(--accent); font-size: 18px; }}
  a {{ color: var(--accent); }}
  h1 {{ font-size: 28px; line-height: 1.25; margin: 24px 0 4px; }}
  h2 {{ font-size: 20px; margin: 28px 0 8px; }}
  em {{ color: var(--muted); }}
  li {{ margin: 6px 0; }}
</style>
</head>
<body>
<main>
<nav><strong>NPass</strong><a href="{switch_href}" hreflang="{switch_lang}" onclick="try {{ localStorage.setItem('lang', '{switch_lang}'); }} catch (e) {{}}">{switch_label}</a></nav>
{body}
</main>
</body>
</html>
"""

# Same rule as the netersoft.github.io home page: the French page sends browsers
# whose preferred language isn't French to the English one, unless a language
# was picked with a language link on the site (shared localStorage key).
REDIRECT = """<script>
(function () {
  var lang = null;
  try { lang = localStorage.getItem('lang'); } catch (e) {}
  if (!lang) {
    var langs = navigator.languages && navigator.languages.length ? navigator.languages : [navigator.language || ''];
    lang = /^fr(-|$)/i.test(langs[0]) ? 'fr' : 'en';
  }
  if (lang === 'en') location.replace('en/' + location.search + location.hash);
})();
</script>
"""


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    out = Path(sys.argv[1]).expanduser() / 'n-pass' / 'privacy'
    alternates = '\n'.join(
        f'<link rel="alternate" hreflang="{lang}" href="{BASE_URL}{sub}">' for lang, (sub, _, _) in LOCALES.items()
    )
    for lang, (sub, title, switch_label) in LOCALES.items():
        other = next(l for l in LOCALES if l != lang)
        body = (ROOT / 'assets' / 'docs' / lang / 'privacy_policy.html').read_text(encoding='utf-8').strip()
        page = TEMPLATE.format(
            lang=lang,
            title=title,
            url=BASE_URL + sub,
            alternates=alternates,
            redirect=REDIRECT if lang == 'fr' else '',
            switch_href=BASE_URL + LOCALES[other][0],
            switch_lang=other,
            switch_label=switch_label,
            body=body,
        )
        target = out / sub / 'index.html'
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(page, encoding='utf-8')
        print(target)


if __name__ == '__main__':
    main()
