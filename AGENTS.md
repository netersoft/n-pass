# Flutter Starter - Agent Guide

## Project Setup

```bash
# Install dependencies
flutter pub get

# Generate Slang translations
dart run slang

# Run codegen (Riverpod, JSON serializable, Hive)
dart run build_runner build

# Run app
flutter run
```

## Essential Commands

```bash
# Rename app (all displays)
dart run rename_app:main all="My App Name"

# Change Android/iOS package name
dart run change_app_package_name:main com.new.package.name

# Generate launcher icons (from assets/images/launcher/icon.png)
dart run icons_launcher:create

# Generate splash screen
dart run flutter_native_splash:create

# Remove default splash
dart run flutter_native_splash:remove
```

## Code Quality

```bash
# Lint + static analysis
flutter analyze
dart analyze

# Format
dart format .
```

## Architecture

- **Entry point**: `lib/main.dart`
- **Core layer** (`lib/core/`): providers, services, models, routes, helpers, data
- **View layer** (`lib/view/`): screens, components, layouts, themes
- **State management**: Riverpod with code generation (`riverpod_generator`)
- **Routing**: go_router
- **Local storage**: Hive CE + SharedPreferences
- **API**: REST with json_serializable

## Environment

- Copy `.env.example` to `.env` before running
- SDK: `>=3.8.0 <4.0.0`

## Testing

Unit tests live under `test/` (`api/`, `helpers/`, `providers/`), using `mocktail` with a
GetIt test-locator override (`test/helpers/test_utils.dart`) to mock infrastructure
singletons. There are no widget, golden, or integration tests yet.

```bash
flutter test
```
