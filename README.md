# INNO Mobile Base

Production-ready Flutter base template.
Architecture: **MVVM + Riverpod** (state management) + **GetIt** (dependency injection) + **Flutter Navigator** (navigation).

---

## Table of Contents
1. [Project Structure](#1-project-structure)
2. [Architecture Overview](#2-architecture-overview)
3. [Layer Breakdown](#3-layer-breakdown)
4. [Setup](#4-setup)
5. [Running the App](#5-running-the-app)
6. [Adding a New Feature](#6-adding-a-new-feature)
7. [Skill Files — Claude AI Context](#7-skill-files--claude-ai-context)

---

## 1. Project Structure

```
mobile_base/
├── lib/
│   ├── main.dart                        # Entry point — setupLocator() + runApp
│   ├── app.dart                         # MaterialApp + ProviderScope + navigatorKey
│   ├── core/
│   │   ├── base/
│   │   │   ├── base_view_model.dart     # StateNotifier base class
│   │   │   ├── base_view.dart           # ConsumerStatefulWidget base class
│   │   │   └── base_state.dart          # AsyncState<T> union type
│   │   ├── di/
│   │   │   └── service_locator.dart     # All GetIt service registrations
│   │   ├── error/
│   │   │   ├── app_exception.dart       # Sealed exception hierarchy
│   │   │   └── failure.dart             # Freezed Failure union (used with Either)
│   │   ├── navigation/
│   │   │   ├── app_routes.dart          # Route name constants
│   │   │   ├── app_router.dart          # onGenerateRoute — maps name → screen
│   │   │   └── navigation_service.dart  # navigatorKey + INavigationService impl
│   │   ├── network/
│   │   │   ├── api_client.dart          # Dio wrapper → Either<Failure, T>
│   │   │   ├── api_interceptor.dart     # Auth + logging interceptors
│   │   │   └── api_response.dart        # Generic ApiResponse<T> / PaginatedResponse<T>
│   │   ├── services/
│   │   │   ├── storage_service.dart     # SharedPreferences wrapper
│   │   │   └── secure_storage_service.dart  # Token storage (Keychain / Keystore)
│   │   ├── utils/
│   │   │   ├── logger.dart              # AppLogger(tag)
│   │   │   └── formatters.dart          # Currency, date, relative time
│   │   └── validators/
│   │       └── validators.dart          # Static validation rules
│   ├── features/
│   │   └── auth/                        # Example feature — copy for new features
│   │       ├── repository/auth_repository.dart
│   │       ├── state/login_state.dart
│   │       ├── view/login_screen.dart
│   │       └── viewmodel/login_view_model.dart
│   └── shared/
│       ├── constants/app_constants.dart # baseUrl, storage keys
│       ├── theme/app_theme.dart         # AppColors, light/dark ThemeData
│       └── widgets/                     # Shared atoms/molecules
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/
├── CLAUDE.md                            # Claude AI context (auto-loaded)
└── .claude/                             # Detailed Claude AI skill docs
    ├── architecture.md
    ├── patterns.md
    ├── add-feature.md
    ├── troubleshooting.md
    └── dependencies.md
```

---

## 2. Architecture Overview

### Data flow

```
┌──────────────────────────────────────────────┐
│                  UI Layer                     │
│  Screen (StatelessWidget)                     │
│    └── BaseView<S>                            │
│         • watches state via ProviderListenable│
│         • reads ViewModel via ref.read(...)   │
└───────────────────┬──────────────────────────┘
                    │ calls methods on
┌───────────────────▼──────────────────────────┐
│              ViewModel Layer                  │
│  XyzViewModel extends BaseViewModel<S>        │
│    • owns and updates state (safeSetState)    │
│    • validates input (Validators.*)           │
│    • navigates (NavigationService)            │
│    • delegates data work to Repository        │
└───────────────────┬──────────────────────────┘
                    │ returns Either<Failure, T>
┌───────────────────▼──────────────────────────┐
│             Repository Layer                  │
│  XyzRepository implements IXyzRepository      │
│    • calls ApiClient (network)                │
│    • calls StorageService / SecureStorage     │
│    • never throws — always returns Either     │
└───────────────────┬──────────────────────────┘
                    │ uses
┌───────────────────▼──────────────────────────┐
│              Core Services                    │
│  ApiClient · StorageService                   │
│  SecureStorageService · NavigationService     │
└──────────────────────────────────────────────┘
```

### Dependency injection — GetIt service locator

```
main()
  └── await setupLocator()              ← registers all services before runApp
        ├── SharedPreferences           (registerSingleton — async resolved first)
        ├── SecureStorageService        (registerSingleton)
        ├── StorageService              (registerLazySingleton)
        ├── NavigationService           (registerSingleton)
        ├── AuthInterceptor             (registerLazySingleton)
        ├── LoggingInterceptor          (registerLazySingleton)
        ├── ApiClient                   (registerLazySingleton)
        └── AuthRepository              (registerLazySingleton)
        │
        ▼
  runApp(App())
    └── MaterialApp(navigatorKey: navigatorKey, onGenerateRoute: AppRouter.onGenerateRoute)
```

### Error handling chain

```
ApiClient._safeCall()
  ├── timeout          → Failure.network("Request timed out")
  ├── 401              → Failure.unauthorized()
  ├── 404              → Failure.notFound()
  ├── other HTTP error → Failure.network(message, statusCode)
  ├── no internet      → Failure.network("No internet connection")
  └── unknown          → Failure.unknown()

Repository returns Either<Failure, T>

ViewModel.someAction()
  result.fold(
    (failure) → safeSetState(state.copyWith(errorMessage: mapFailure(failure))),
    (data)    → safeSetState(state.copyWith(data: data)),
  )
```

### Example — Login flow

```
LoginScreen
  │  user taps "Sign In"
  ▼
LoginViewModel.login()
  │  validates via Validators.email / Validators.password
  │  calls
  ▼
AuthRepository.login(email, password)
  │  POST /auth/login via ApiClient
  │  saves tokens to SecureStorageService
  │  returns Either<Failure, LoginResponse>
  ▼
LoginViewModel.login() — folds result
  ├── failure → state.copyWith(errorMessage: mapFailure(f))
  └── success → NavigationService.pushAndClearStack(AppRoutes.home)
```

---

## 3. Layer Breakdown

### `core/base/`
| File | Purpose |
|------|---------|
| `BaseViewModel<S>` | Extends `StateNotifier<S>`. Provides `safeSetState()`, `mapFailure()`, and tagged logger. Never disposed while in use. |
| `BaseView<S>` | `ConsumerStatefulWidget` that watches any `ProviderListenable<S>` and passes `WidgetRef` to builder. Works with both regular and `autoDispose` providers. |
| `AsyncState<T>` | Freezed union: `idle` / `loading` / `success(T)` / `failure(String)`. Use for single-resource screens. |

### `core/di/`
| File | Purpose |
|------|---------|
| `service_locator.dart` | Single `setupLocator()` function — registers every service into `GetIt`. Awaited in `main()` before `runApp`. Resolve anywhere with `locator<T>()`. |

### `core/navigation/`
| File | Purpose |
|------|---------|
| `app_routes.dart` | All route name constants. Never hardcode route strings anywhere else. |
| `app_router.dart` | `AppRouter.onGenerateRoute` — switch statement mapping route name → screen widget. Add new screens here. |
| `navigation_service.dart` | `navigatorKey` (GlobalKey) lives here. `NavigationService` wraps Flutter's `Navigator` for programmatic navigation without a `BuildContext`. |

### `core/error/`
| Type | When to use |
|------|------------|
| `AppException` (sealed) | When you need to `throw` — internal errors only. |
| `Failure` (freezed union) | When you need to `return` an error — all repository return types. |

### `core/network/`
| File | Purpose |
|------|---------|
| `ApiClient` | Dio wrapper with `get/post/put/patch/delete`. Every method returns `Either<Failure, T>`. Accepts a `decoder` callback for type-safe deserialization. |
| `AuthInterceptor` | Injects `Authorization: Bearer <token>` header on every request. |
| `LoggingInterceptor` | Logs `[METHOD] url` and status codes in debug mode only. |
| `ApiResponse<T>` | Plain generic wrapper (`success`, `message`, `data`, `statusCode`). No codegen needed — decoded manually via `decoder` callback. |

### `core/services/`
| File | Purpose |
|------|---------|
| `StorageService` | Wraps `SharedPreferences`. Use for non-sensitive data (language, theme, flags). |
| `SecureStorageService` | Wraps `FlutterSecureStorage`. Use for tokens. Provides `saveAccessToken`, `getAccessToken`, `clearTokens` helpers. |

### `core/validators/`
```dart
Validators.email(value)          // → String? error
Validators.password(value)       // → String? error (min 8, uppercase, number)
Validators.phone(value)          // → String? error
Validators.required(value)       // → String? error
Validators.compose(value, rules) // → first failing rule's error
```

### `core/utils/`
```dart
AppLogger('TAG').d/i/w/e(message)          // structured logging

AppFormatters.currency(1299.5)             // "$1,299.50"
AppFormatters.date(dt)                     // "Jun 09, 2026"
AppFormatters.relativeTime(dt)             // "3h ago"
AppFormatters.compactNumber(1500000)       // "1.5M"
```

### `core/navigation/`
```dart
// All route names (never hardcode strings):
AppRoutes.splash / .login / .home / .forgotPassword

// NavigationService methods:
_nav.push(AppRoutes.home)
_nav.pushReplacement(AppRoutes.login)
_nav.pushAndClearStack(AppRoutes.home)     // use after login/logout
_nav.pop()
_nav.showDialog(MyDialog())
_nav.showBottomSheet(MySheet())
_nav.showSnackbar('Something went wrong')
```

---

## 4. Setup

### Prerequisites
| Tool | Version | Check command |
|------|---------|---------------|
| Flutter | 3.44.1+ | `flutter --version` |
| Dart | 3.12.0+ | `dart --version` |
| Xcode (iOS/macOS) | 14+ | `xcode-select -p` |
| Android Studio | Latest | SDK Manager → NDK `28.2.13676358` |
| CocoaPods | Latest | `pod --version` |
| Ruby | 3.x | `ruby --version` |

> ⚠️ **NDK note:** Flutter 3.44.1 requires NDK `28.2.13676358` specifically.
> If missing: `echo "y" | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "ndk;28.2.13676358"`

> ⚠️ **CocoaPods note:** Always prefix pod commands with `LANG=en_US.UTF-8` to avoid Ruby encoding crashes:
> `LANG=en_US.UTF-8 pod install`

### Step 1 — Install Flutter dependencies
```bash
cd mobile_base
flutter pub get
```

### Step 2 — Generate code
Run after every change to `@freezed` or `@JsonSerializable` classes:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 3 — iOS setup
```bash
cd ios
LANG=en_US.UTF-8 pod install
cd ..
```

### Step 4 — Configure the base URL
Edit `lib/shared/constants/app_constants.dart`:
```dart
static const baseUrl = 'https://api.your-domain.com';
```

---

## 5. Running the App

### Run debug on connected device
```bash
flutter run
```

### Run on specific device
```bash
flutter devices                               # list devices
flutter run -d <device-id>
```

### Build

| Command | Output |
|---------|--------|
| `flutter build apk --debug` | Android debug APK |
| `flutter build apk --release` | Android release APK |
| `flutter build ios --debug` | iOS debug |
| `flutter build ipa` | iOS release archive |

### Code quality
```bash
flutter analyze                               # static analysis — must pass before PR
flutter test                                  # unit + widget tests
dart run build_runner build --delete-conflicting-outputs  # regenerate files
```

---

## 6. Adding a New Feature

### 1. Create the directory
```
lib/features/<name>/
  ├── repository/<name>_repository.dart
  ├── state/<name>_state.dart
  ├── view/<name>_screen.dart
  └── viewmodel/<name>_view_model.dart
```

### 2. Define the state
```dart
@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    User? user,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ProfileState;
}
// Then run: dart run build_runner build --delete-conflicting-outputs
```

### 3. Create the repository
```dart
abstract interface class IProfileRepository {
  Future<Either<Failure, User>> getProfile();
}

class ProfileRepository implements IProfileRepository {
  ProfileRepository({required ApiClient apiClient}) : _api = apiClient;
  final ApiClient _api;

  @override
  Future<Either<Failure, User>> getProfile() =>
      _api.get('/profile', decoder: (json) => User.fromJson(json));
}
```

### 4. Create the ViewModel
```dart
class ProfileViewModel extends BaseViewModel<ProfileState> {
  ProfileViewModel({required IProfileRepository repo, required NavigationService nav})
      : _repo = repo, _nav = nav, super(const ProfileState());

  Future<void> init() async {
    safeSetState(state.copyWith(isLoading: true));
    final result = await _repo.getProfile();
    result.fold(
      (f) => safeSetState(state.copyWith(isLoading: false, errorMessage: mapFailure(f))),
      (user) => safeSetState(state.copyWith(isLoading: false, user: user)),
    );
  }
}

final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>(
  (ref) => ProfileViewModel(
    repo: locator<ProfileRepository>(),
    nav: locator<NavigationService>(),
  ),
);
```

### 5. Build the screen
```dart
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => BaseView<ProfileState>(
        provider: profileViewModelProvider,
        onInit: (ref) => ref.read(profileViewModelProvider.notifier).init(),
        builder: (context, ref, state) {
          final vm = ref.read(profileViewModelProvider.notifier);
          return _ProfileBody(vm: vm, state: state);
        },
      );
}
```

### 6. Register in DI
`lib/core/di/service_locator.dart` — inside `setupLocator()`:
```dart
locator.registerLazySingleton<ProfileRepository>(
  () => ProfileRepository(apiClient: locator<ApiClient>()),
);
```

### 7. Add the route
`lib/core/navigation/app_routes.dart`:
```dart
static const profile = '/profile';
```

`lib/core/navigation/app_router.dart` — inside the `switch`:
```dart
case AppRoutes.profile:
  return _page(const ProfileScreen());
```

---

## 7. Skill Files — Claude AI Context

This project ships with `CLAUDE.md` files that give Claude AI full project context at the start of every session — no re-explaining the architecture needed.

### How it works

Claude Code reads `CLAUDE.md` files **automatically** when a session opens:
```
Auto-loaded (no action needed):
  ~/StudioProjects/INNO/CLAUDE.md              ← workspace overview
  ~/StudioProjects/INNO/mobile_base/CLAUDE.md  ← this project's context
```

### On-demand docs (`.claude/` folder)

These are too large to auto-load. Reference them by name when needed:

```
"Read .claude/patterns.md and add a notifications feature"
"Check .claude/troubleshooting.md — getting a Gradle build error"
"Follow .claude/add-feature.md to create the payment screen"
"Read .claude/architecture.md — where should I add offline caching?"
```

### Available skill files

| File | Read when... |
|------|-------------|
| `.claude/architecture.md` | Touching DI, navigation, error flow, or overall structure |
| `.claude/patterns.md` | Writing any ViewModel, state, repository, or screen |
| `.claude/add-feature.md` | Starting any new screen or feature |
| `.claude/troubleshooting.md` | Hitting a build, analyzer, or runtime error |
| `.claude/dependencies.md` | Changing `pubspec.yaml` or questioning package choices |

### Keeping skill files accurate
```
"Update .claude/troubleshooting.md — add the NDK issue we just fixed"
"Update .claude/patterns.md — add the infinite scroll pattern we agreed on"
"Update .claude/dependencies.md — we added connectivity_plus"
```

---

## 8. Related Projects

| Project | Path | Use when |
|---------|------|---------|
| `mobile_base` | *(this project)* | Starting any new INNO Flutter app |
### Architecture comparison

| | `mobile_base` | `base-flutter` |
|--|---------------|----------------|
| Pattern | ViewModel → Repository | Coordinator → UseCase → Service |
| State management | Riverpod 2.x | Riverpod 1.x |
| DI | GetIt (`locator<T>()`) | Kiwi (`DIContainer`) |
| Error handling | `Either<Failure, T>` | try/catch in UseCases |
| Navigation | `NavigationService` (Flutter Navigator + GlobalKey) | `NavigationManager` (custom) |
| Structure | Single package | Mono-repo (5 packages) |
| Dart SDK | `>=3.0.0 <4.0.0` | `>=3.0.0 <4.0.0` |
