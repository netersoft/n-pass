# Flutter Starter

[![Flutter CI](https://github.com/edpage-hq/flutter-starter/actions/workflows/flutter.yml/badge.svg)](https://github.com/edpage-hq/flutter-starter/actions/workflows/flutter.yml)

## Description

A reusable Flutter starter for quickly launching production-oriented mobile apps at edpage-hq. It already includes routing, authentication screens, local encrypted storage, REST API helpers, i18n, theming, onboarding, common form inputs, image/media utilities, paginated lists, and reusable layout/components — see [Optional Feature Packs](#optional-feature-packs) for what to keep or strip per project.

> This repo is the **starter** itself, cloned to bootstrap new projects (see [`project-guidelines`](https://github.com/edpage-hq/project-guidelines) → `startup-checklist.md`). The [`PROJECT_README_TEMPLATE.md`](https://github.com/edpage-hq/project-guidelines/blob/master/templates/PROJECT_README_TEMPLATE.md) sections below are filled in for the starter itself; a downstream project should rewrite them for its own scope.

## Tech stack

- Mobile: Flutter, Dart SDK `>=3.8.0 <4.0.0`
- State management: Riverpod (`riverpod_generator`, code-gen)
- Routing: go_router (`go_router_builder`)
- Local storage: Hive CE + SharedPreferences
- API: REST with `json_serializable`
- i18n: [Slang](https://pub.dev/packages/slang)
- Crash reporting / analytics / push notifications: Firebase (Crashlytics + Analytics + Cloud Messaging)

## Prerequisites

- Flutter SDK matching `>=3.8.0 <4.0.0` (CI runs on the `stable` channel, no pinned patch version)
- A `.env` file (see [Environment variables](#environment-variables))

## Installation

```bash
cp .env.example .env
flutter pub get
dart run slang
dart run build_runner build
flutter run
```

## Environment variables

The `.env` file is bundled as an asset and loaded at runtime — treat every value in it as **public** (API base URL, OAuth client IDs, theme colors), never a real secret. Use backend-issued tokens, secure storage, remote config, or platform build systems for anything sensitive.

| Variable | Description | Example |
|----------|-------------|---------|
| `APP_API_BASE_URL` | Base URL of the backend REST API | `http://localhost:8000` |
| `APP_GOOGLE_AUTH_IOS_CLIENT_ID` | Google Sign-In OAuth client ID for iOS | `xxx.apps.googleusercontent.com` |
| `APP_GOOGLE_AUTH_IOS_CLIENT_ID_REVERSE` | Reversed form of the iOS client ID, used for the iOS URL scheme | `com.googleusercontent.apps.xxx` |
| `APP_GOOGLE_AUTH_ANDROID_DEBUG_CLIENT_ID` | Google Sign-In OAuth client ID for Android debug builds | `xxx.apps.googleusercontent.com` |
| `APP_GOOGLE_AUTH_ANDROID_RELEASE_CLIENT_ID` | Google Sign-In OAuth client ID for Android release builds (set once a release keystore exists) | *(empty until release signing is configured)* |
| `APP_GOOGLE_AUTH_WEB_CLIENT_ID` | Google Sign-In OAuth web client ID (used as the `serverClientId` on mobile) | `xxx.apps.googleusercontent.com` |
| `APP_PRIMARY_COLOR` | Primary theme color, hex | `#0000CD` |
| `APP_SECONDARY_COLOR` | Secondary theme color, hex | `#009ee3` |
| `APP_ACCENT_COLOR` | Accent theme color, hex | `#f5f5f5` |

The Google client IDs shipped in `.env.example` point to a shared placeholder Google Cloud project for out-of-the-box Google Sign-In testing — replace them with your own project's IDs before shipping.

## Running tests

```bash
flutter test
# with coverage, as run in CI:
flutter test --coverage
```

## Environments

Not applicable to this repo — it is the starter, not a deployed project. Fill in this table in the README of each project cloned from it:

| Env        | URL | Deployment |
|------------|-----|------------|
| Staging    |     |            |
| Production |     |            |

## Contacts

Not applicable to this repo. Fill in for each project cloned from it:

- Tech lead:
- Product owner:

## New Project Checklist

1. Update `.env` with public app configuration only. Do not put real secrets in a mobile app bundle.
2. Rename the visible app name:

    ```bash
    dart run rename_app:main all="My App Name"
    ```

3. Change package identifiers:

    ```bash
    dart run change_app_package_name:main com.company.product
    ```

4. Replace launcher assets under `assets/images/launcher/`.
5. Regenerate launcher icons and splash:

    ```bash
    dart run icons_launcher:create
    dart run flutter_native_splash:create
    ```

6. Set up crash reporting for your own Firebase project:

    ```bash
    dart pub global activate flutterfire_cli
    flutterfire configure
    ```

    This overwrites the placeholder `lib/firebase_options.dart`. Until you do this, `CrashReportingService` detects the placeholder and skips initialization instead of reporting to a project that doesn't exist -- see [Firebase (Crash Reporting + Analytics + Push Notifications)](#firebase-crash-reporting--analytics--push-notifications).

7. Run quality checks:

    ```bash
    dart format .
    flutter analyze
    flutter test
    ```

## Architecture

The app is split into two main layers:

- `lib/core/`: state, services, routing, models, helpers, data access, storage, and cross-cutting logic.
- `lib/view/`: screens, layouts, reusable widgets, and themes.

Runtime composition starts from:

- `lib/main.dart`: entry point only.
- `lib/core/bootstrap/app_bootstrap.dart`: Flutter, env, Hive, DI, locale, and query-cache bootstrap.
- `lib/app.dart`: root app widget, theme, and router view.
- `lib/core/lifecycle/app_lifecycle_layer.dart`: app lifecycle side effects.

Internationalisation uses [Slang](https://pub.dev/packages/slang) with type-safe generated translations (`context.t`). Source files are in `assets/i18n/*.i18n.json` (base locale: fr). Locale is initialised from the device locale at bootstrap via `LocaleSettings.useDeviceLocale()`.

## Project Structure

```txt
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp.router + TranslationProvider
├── core/
│   ├── bootstrap/                     # App initialisation (env, Hive, DI, locale)
│   ├── services/                      # API, auth, DI, Hive, i18n, location, media
│   ├── routes/                        # go_router_builder route defs + GoRouter factory
│   ├── providers/                     # Riverpod providers (auth, settings, navigation, etc.)
│   ├── data/                          # Queries + mutations (CachedQuery)
│   ├── models/                        # JSON-serializable models (json_annotation)
│   ├── enums/                         # Typed constants
│   ├── helpers/                       # Auth, connectivity, device info, dialogs, etc.
│   ├── extensions/                    # String, Color, DateTime extensions
│   └── tools/                         # Utils, formatters, constants
├── view/
│   ├── themes/                        # AppTheme, AppColors (from .env)
│   ├── screens/                       # Auth, account, content, onboarding, main
│   ├── components/                    # Reusable widgets (inputs, lists, loaders, etc.)
│   └── layouts/                       # Main layout (connectivity checks, toasts)
├── assets/
│   ├── i18n/                          # Translation source files (*.i18n.json)
│   └── images/                        # Launcher icons, splash, Lottie animations
└── test/                              # Unit tests
```

Generated files (`*.g.dart`, `*.config.dart`) are excluded from git — they are rebuilt via `dart run build_runner build`.

## State And Dependency Management

All providers use `@riverpod` code generation. Riverpod is the app-facing state management layer.

`GetIt` is used for infrastructure singletons such as shared preferences, Hive, and navigation. New state should prefer Riverpod providers, while low-level platform services can remain injectable through `GetIt`.

## Routing

Routes are centralized in `lib/core/routes/app_route.dart` (type-safe `go_router_builder` definitions) and `lib/core/routes/router.dart` (GoRouter factory).

Use `createRouter()` when a test or alternate app shell needs injectable auth/access dependencies. The default exported `router` is kept for normal runtime usage.

`appRouteRedirect` (in `router.dart`) handles two guards: `authPaths` (redirects logged-out users away from routes like `ProfileRoute`) and `accessRequiredPaths`, a permission-based guard that ships empty by default. To lock a route behind a permission, add its `.location` to `accessRequiredPaths` — the guard then checks a `page-<location-with-dashes>` permission via `AccessHelper.userHasAccessTo`.

## API Layer

Queries, mutations, and other call sites go through the `ApiService` static facade, which just forwards to an `ApiClient` instance resolved from DI (`locator<ApiClient>()`, registered as a singleton in `AppModule`). This keeps existing call sites (`ApiService.makeRequest(...)`, `ApiService.getItem(...)`, etc.) unchanged while `ApiClient` itself is a normal, constructor-injectable class — no static mutable state.

`ApiClient` supports:

- Central base URL from `.env`.
- Default JSON/mobile headers.
- Constructor-injected HTTP client and token provider (for tests, construct `ApiClient(client: ..., tokenProvider: ...)` directly, or register a fake in GetIt via `setupTestLocator(apiClient: ...)`).
- Request timeout through `ApiConfig.requestTimeout`.
- Basic `ApiResponse` normalization.

Queries and mutations live under `lib/core/data/queries/` and `lib/core/data/mutations/`.

## Firebase (Crash Reporting + Analytics + Push Notifications)

Uses Firebase (Crashlytics + Analytics + Cloud Messaging) over Sentry/Amplitude/Mixpanel/OneSignal: all free at unlimited volume, which matters more here than a richer dashboard since this starter is meant to be reused across many projects that would otherwise all share one paid-tier quota, and all three share the same project/config.

- `lib/core/services/firebase/service.dart` (`FirebaseSetup`) is the shared entry point: `FirebaseSetup.ensureInitialized()` calls `Firebase.initializeApp()` once, called early in `bootstrapApp()`. `FirebaseSetup.isConfigured` detects whether `lib/firebase_options.dart` is still the shipped placeholder (no real Firebase project) and gates every Firebase-backed service on it.
- **Crash reporting**: `CrashReportingService.init()` (`lib/core/services/crash_reporting/service.dart`) wires `FlutterError.onError`/`PlatformDispatcher.instance.onError` to Crashlytics for uncaught errors. `LogHelper.e`/`LogHelper.f` also forward to Crashlytics as non-fatal errors, so caught-and-logged exceptions across the app get reported too.
- **Analytics**: `AnalyticsService` (`lib/core/services/analytics/service.dart`) wraps `FirebaseAnalytics` (`logEvent`, `logScreenView`, `setUserId`, `setUserProperty`) -- every method is a silent no-op when unconfigured, so call sites never need to check `isConfigured` themselves. Screen views are tracked automatically through a `FirebaseAnalyticsObserver` added to the router's observers (see `lib/core/routes/router.dart`).
- **Push notifications**: `PushNotificationsService.init()` (`lib/core/services/push_notifications/service.dart`) requests notification permission, registers a background message handler, and wires `onMessage`/`onMessageOpenedApp`/`getInitialMessage` (currently just logged -- add navigation and, for a foreground heads-up banner on Android, `flutter_local_notifications` at those hook points once a project needs it). `PushNotificationsService.getToken()` is sent to the backend as `UserDeviceModel.fcmToken` alongside device info, from the same `/user-devices` call sites used for login/register/social auth/app-resume (see `lib/core/lifecycle/app_lifecycle_layer.dart` and `lib/core/providers/auth/`) -- there is no separate registration path to keep in sync.
  - **Android**: works out of the box (`POST_NOTIFICATIONS` permission already in the manifest).
  - **iOS**: `Runner.entitlements` and `Info.plist` are already set up (APNs entitlement, `remote-notification` background mode), but Xcode still needs the **Push Notifications** capability enabled once under Signing & Capabilities before a real device can register -- and, like Crashlytics/Analytics, this needs a real Apple Developer account, which a shared starter template can't ship with.
- Until you run `flutterfire configure` (see the New Project Checklist), everything above stays a safe no-op instead of reporting to a project that doesn't exist.

## Optional Feature Packs

This starter intentionally includes more than a minimal app. For a new project, decide which packs to keep:

- Auth: login, registration, forgot password, Google, Apple, phone auth.
- Account: profile, profile item, settings.
- Content: news, ads, pages, useful information.
- Media: image picker/crop/compress and video compression.
- Location: permissions, location, geocoding, device activity.
- Storage: Hive CE, secure storage, shared preferences.
- UI kit: inputs, paginated lists, loaders, shimmers, status widgets.

If a project does not need a pack, remove its screens, providers, routes, models, services, assets, and dependencies together.

## Quality

```bash
dart format .
flutter analyze
flutter test
```

Code generation:

```bash
dart run slang
dart run build_runner build
```

Generated files (`*.g.dart`) must **not** be edited manually. They are regenerated via the commands above.

## Build Flavors (dev / staging / prod)

Flavors here only separate **app identity** (so dev/staging/prod can be installed side by side on the same device/simulator) — environment *configuration* (API URLs, keys) still comes from a single `.env`, provided at build time exactly as today (`cp .env.example .env` locally, `echo "$ENV_FILE" > .env` in CI). Point that `.env` at whichever backend a given build should talk to; there's no separate `.env.dev`/`.env.staging`/`.env.prod` file to keep in sync. A project that genuinely needs the env content itself to differ per installed build can extend this later.

- **Android** — ready to use, verified with a real build:

  ```bash
  flutter run --flavor dev
  flutter build apk --flavor staging --release
  flutter build apk --flavor prod --release
  ```

  Each flavor gets its own `applicationId` suffix (`.dev`, `.staging`, none for `prod`) and app name (`android/app/build.gradle`), so all three can be installed at once. `AndroidManifest.xml`'s label already points at the per-flavor resource.

- **iOS** — needs one manual step per flavor before `--flavor` works, since duplicating build configurations/schemes safely requires Xcode itself (not something to hand-edit in `project.pbxproj`):

  1. Open `ios/Runner.xcworkspace` in Xcode.
  2. For each flavor (`dev`, `staging`, `prod`): **Product → Scheme → Manage Schemes** → duplicate an existing scheme, name it exactly the flavor name (case-sensitive — `flutter build ios --flavor dev` looks for a scheme literally named `dev`).
  3. For each new scheme, duplicate the Debug/Release/Profile build configurations (**Project → Info → Configurations**) and give the duplicates a distinct `PRODUCT_BUNDLE_IDENTIFIER` (e.g. append `.dev`) so they can coexist on a device the same way the Android flavors do; point each new scheme at its matching configurations.
  4. Commit the resulting `project.pbxproj` and `.xcscheme` changes.

  Until that's done, `flutter build ios`/`flutter run` without `--flavor` continues to work unchanged.

## Release Builds

Pushing a `v*` tag (or running the workflow manually) triggers two build jobs in CI, after the quality job passes:

- **Android**: `flutter build apk --release --flavor prod`, uploaded as a workflow artifact. Signed with the debug key until the project has its own `key.properties` + keystore (see `android/app/build.gradle`) — good for smoke-testing and manual QA, not for a Play Store release.
- **iOS**: `flutter build ios --release --no-codesign` — verifies the iOS side still compiles. It does not produce an installable `.ipa`; that requires real Apple Developer signing (Fastlane match, an App Store Connect API key, etc.), which a shared starter template can't ship with. Not flavor-aware yet, per the manual iOS step above.

Add your own signing and store-publishing steps once a downstream project has its own Android keystore and Apple Developer account.
