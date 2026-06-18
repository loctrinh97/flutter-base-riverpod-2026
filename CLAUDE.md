# INNO Mobile — Project Context for Claude

> Quick-reference file. Read this first, then open `.claude/` docs for deeper detail.

## What this project is
Flutter mobile base template for the INNO workspace.
Architecture: **MVVM + Riverpod** (state) + **GetIt** (DI) + **Flutter Navigator** (navigation).
Modeled after `/Users/ameetkumar2/StudioProjects/INNO/base-flutter` but modernized.

## Workspace layout
```
/Users/ameetkumar2/StudioProjects/INNO/
├── base-flutter/        # Original reference architecture (Coordinator pattern, Kiwi DI)
├── mobile_base/         # THIS PROJECT — active Flutter app template
└── CLAUDE.md            # Workspace-level notes
```

## Key files to know immediately
| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry — calls `setupLocator()`, sets orientation, calls `runApp` |
| `lib/app.dart` | `MaterialApp` + `ProviderScope` + `navigatorKey` + `onGenerateRoute` |
| `lib/core/di/service_locator.dart` | ALL GetIt service registrations. Read before touching DI |
| `lib/core/navigation/app_router.dart` | Route generation — add new screens here |
| `lib/core/navigation/navigation_service.dart` | `navigatorKey` lives here + `NavigationService` |
| `lib/core/base/base_view_model.dart` | Every ViewModel extends this |
| `lib/core/base/base_view.dart` | Every screen uses `BaseView<S>` |
| `lib/core/network/api_client.dart` | Dio wrapper — returns `Either<Failure, T>` |
| `lib/core/navigation/app_routes.dart` | All route name constants live here |
| `lib/shared/constants/app_constants.dart` | `baseUrl` and storage key constants |

## Detailed docs (read when working on that area)
| Doc | When to read |
|-----|-------------|
| `.claude/architecture.md` | Understanding layers, data flow, DI lifecycle |
| `.claude/patterns.md` | How to write ViewModels, states, repositories |
| `.claude/add-feature.md` | Step-by-step checklist for adding any new feature |
| `.claude/troubleshooting.md` | Known issues + fixes already applied to this project |
| `.claude/dependencies.md` | All packages, their role, and why they were chosen |

## Build commands (run from `mobile_base/`)
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after adding @freezed classes
flutter analyze
flutter build apk --debug
flutter run
```

## Critical rules — never violate
1. **No try/catch in ViewModels** — `ApiClient` returns `Either<Failure, T>`; fold it.
2. **Never call `state =` directly** — always use `safeSetState()` from `BaseViewModel`.
3. **`setupLocator()` is async** — always `await` it in `main()` before `runApp`.
4. **Register every new repository in `service_locator.dart`** — not inside the ViewModel.
5. **Resolve dependencies with `locator<T>()`** — never instantiate services manually in ViewModels.
6. **Generated files (`*.freezed.dart`, `*.g.dart`) are git-ignored** — run build_runner after pulling.
7. **`BaseView<S>` takes `ProviderListenable<S>`** — works with both regular and autoDispose providers.
