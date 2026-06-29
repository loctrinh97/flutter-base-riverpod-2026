# TVF Mobile — Project Context for Claude

> Quick-reference file. Read this first, then open `.claude/` docs for deeper detail.

## What this project is
Flutter mobile base template for the TVF workspace.
Architecture: **MVVM + Riverpod** (state) + **GetIt** (DI) + **Flutter Navigator** (navigation).

## Key files to know immediately
| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry — loads dotenv, calls `setupLocator()`, sets orientation, calls `runApp` |
| `lib/app.dart` | `MaterialApp` + `ProviderScope` + `navigatorKey` + `EasyLoading.init()` + `onGenerateRoute` |
| `lib/core/config/app_config.dart` | Env config singleton — reads all values from dotenv |
| `lib/core/di/service_locator.dart` | ALL GetIt service registrations. Read before touching DI |
| `lib/core/navigation/app_router.dart` | Route generation — add new screens here |
| `lib/core/navigation/navigation_service.dart` | `navigatorKey` lives here + `NavigationService` |
| `lib/core/base/base_view_model.dart` | Every ViewModel extends this |
| `lib/core/base/base_view.dart` | Every screen uses `BaseView<S>` |
| `lib/core/network/api_client.dart` | Dio wrapper — returns `Either<Failure, T>` |
| `lib/core/navigation/app_routes.dart` | All route name constants live here |
| `lib/shared/constants/app_constants.dart` | Storage key constants (baseUrl comes from `AppConfig`) |
| `lib/shared/widgets/app_shimmer.dart` | `AppShimmer` and `ShimmerBox` for skeleton screens |
| `lib/shared/services/loading_service.dart` | `LoadingService` wrapper around `flutter_easyloading` |

## Environment setup
Four environments: **dev · qa · stg · prd**

Each has a corresponding `.env.{env}` file (gitignored — copy from `.env.example`):
```
APP_NAME=TVF Dev
BASE_URL=https://api-dev.example.com
```

Config is loaded at startup via `AppConfig.load(env)` and accessed anywhere as:
```dart
AppConfig.instance.baseUrl
AppConfig.instance.appName
AppConfig.instance.isDev   // bool helpers
```

## Detailed docs (read when working on that area)
| Doc | When to read |
|-----|-------------|
| `.claude/architecture.md` | Understanding layers, data flow, DI lifecycle |
| `.claude/patterns.md` | How to write ViewModels, states, repositories |
| `.claude/add-feature.md` | Step-by-step checklist for adding any new feature |
| `.claude/troubleshooting.md` | Known issues + fixes already applied to this project |
| `.claude/dependencies.md` | All packages, their role, and why they were chosen |

## Build commands
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after adding @freezed classes
flutter analyze

# Run with flavor (controls bundle ID) + dart-define (controls env config)
flutter run --flavor dev --dart-define=ENV=dev
flutter run --flavor qa  --dart-define=ENV=qa
flutter run --flavor stg --dart-define=ENV=stg
flutter run --flavor prd --dart-define=ENV=prd

# Release builds
flutter build apk --flavor prd --dart-define=ENV=prd --release
flutter build ipa --flavor prd --dart-define=ENV=prd
```

## Critical rules — never violate
1. **No try/catch in ViewModels** — `ApiClient` returns `Either<Failure, T>`; fold it.
2. **Never call `state =` directly** — always use `safeSetState()` from `BaseViewModel`.
3. **`AppConfig.load()` must be awaited first** — before `setupLocator()` and `runApp` in `main()`.
4. **`setupLocator()` is async** — always `await` it in `main()` before `runApp`.
5. **Register every new repository in `service_locator.dart`** — not inside the ViewModel.
6. **Resolve dependencies with `locator<T>()`** — never instantiate services manually in ViewModels.
7. **Generated files (`*.freezed.dart`, `*.g.dart`) are git-ignored** — run build_runner after pulling.
8. **`BaseView<S>` takes `ProviderListenable<S>`** — works with both regular and autoDispose providers.
9. **Never put secrets in `.env.*` files** — they are bundled in the binary. Use `SecureStorageService` for tokens.
