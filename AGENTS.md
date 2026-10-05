# NPass - Agent Guide

Offline password manager (Android + iOS), Flutter rewrite of the legacy native app kept in `.legacy/` (git-ignored, reference only).

## Project Setup

```bash
flutter pub get
dart run slang
dart run build_runner build --delete-conflicting-outputs
flutter run --flavor dev   # Android (flavors: dev, staging, prod)
flutter run                # iOS
```

## Essential Commands

```bash
# Redraw the icon sources (vector padlock, needs cairosvg and Pillow),
# then generate launcher icons and the native splash from them
python3 tool/generate_icons.py
dart run icons_launcher:create

# Generate splash screen
dart run flutter_native_splash:create
```

## Code Quality

```bash
dart format .
flutter analyze
flutter test
```

## Architecture

- **Entry point**: `lib/main.dart`
- **Core layer** (`lib/core/`): providers, services, routes, helpers, tools
- **View layer** (`lib/view/`): screens, components, themes
- **State management**: Riverpod with code generation (`riverpod_generator`)
- **Routing**: go_router (`go_router_builder`)
- **Local storage**: Hive CE + `flutter_secure_storage` + SharedPreferences
- **i18n**: Slang, `assets/i18n/*.i18n.json` (base locale fr)

## Constraints

- Fully offline: no backend, no Firebase, no analytics or ad SDKs. Check the merged Android manifest for unexpected permissions when adding a plugin.
- Android `applicationId` is `com.neteru.n_pass` (existing Play Store listing); iOS bundle id is `com.neteru.npass`.

## Testing

Unit tests live under `test/`, using `mocktail` with a GetIt test-locator override (`test/helpers/test_utils.dart`).

```bash
flutter test
```
