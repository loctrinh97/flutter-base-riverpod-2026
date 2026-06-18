# Architecture — INNO Mobile

## Layer diagram
```
┌─────────────────────────────────────────────┐
│                   UI Layer                   │
│  Screen (StatelessWidget)                    │
│    └── BaseView<S>  (ConsumerStatefulWidget) │
│         watches: ProviderListenable<S>       │
│         reads:   ref.read(provider.notifier) │
└───────────────────┬─────────────────────────┘
                    │ calls methods on
┌───────────────────▼─────────────────────────┐
│              ViewModel Layer                 │
│  XyzViewModel extends BaseViewModel<S>       │
│    • owns state via safeSetState()           │
│    • validates via Validators.*              │
│    • delegates data work to Repository       │
│    • navigates via NavigationService         │
└───────────────────┬─────────────────────────┘
                    │ calls
┌───────────────────▼─────────────────────────┐
│             Repository Layer                 │
│  XyzRepository implements IXyzRepository     │
│    • calls ApiClient (network)               │
│    • calls StorageService / SecureStorage    │
│    • returns Either<Failure, T>              │
└───────────────────┬─────────────────────────┘
                    │ uses
┌───────────────────▼─────────────────────────┐
│              Core Services                   │
│  ApiClient · StorageService                  │
│  SecureStorageService · NavigationService    │
└─────────────────────────────────────────────┘
```

## State management — Riverpod
- Every screen has a `StateNotifierProvider` (or `autoDispose` variant).
- `BaseView<S>` watches state and provides `WidgetRef` to the builder.
- State is an immutable `@freezed` class with `copyWith`.
- UI reads ViewModel via `ref.read(myProvider.notifier)` — never stores it in a field.

## Dependency injection — GetIt service locator
Single function `setupLocator()` in `lib/core/di/service_locator.dart`.
Called once in `main()` before `runApp()`. No per-route bindings.

```
main()
  └── await setupLocator()
        ├── SharedPreferences     (registerSingleton — async resolved first)
        ├── SecureStorageService  (registerSingleton)
        ├── StorageService        (registerLazySingleton)
        ├── NavigationService     (registerSingleton)
        ├── AuthInterceptor       (registerLazySingleton)
        ├── LoggingInterceptor    (registerLazySingleton)
        ├── ApiClient             (registerLazySingleton)
        └── AuthRepository        (registerLazySingleton)
```

### DI registration rules
| Method | When to use |
|---|---|
| `locator.registerSingleton<T>(instance)` | Created eagerly at startup; lives for the entire app lifetime |
| `locator.registerLazySingleton<T>(() => T())` | Created on first access; lives for the entire app lifetime |
| `locator.registerFactory<T>(() => T())` | New instance on every `locator<T>()` call — use for transient objects |

### Resolving a dependency
```dart
// In a Riverpod provider or anywhere outside the widget tree:
locator<NavigationService>()
locator<AuthRepository>()
```

## Error handling flow
```
ApiClient._safeCall()
  ├── DioException  → Failure.network / .unauthorized / .notFound
  ├── AppException  → Failure.unknown
  └── catch-all     → Failure.unknown

Repository.someMethod()
  returns Either<Failure, T>

ViewModel.someAction()
  result.fold(
    (failure) => safeSetState(state.copyWith(errorMessage: mapFailure(failure))),
    (data)    => safeSetState(state.copyWith(data: data)),
  )
```

## Navigation flow
```
ViewModel
  └── _navigationService.push(AppRoutes.home)   // push
  └── _navigationService.pushAndClearStack(...)  // after login/logout
  └── _navigationService.pop()                   // back
```
`NavigationService` wraps Flutter's `Navigator` via `navigatorKey` (GlobalKey).
All route strings live in `AppRoutes` — never hardcode a path.
Route mapping lives in `AppRouter.onGenerateRoute` — add new screens there.

## File structure
```
lib/
├── main.dart                        # bootstrap (setupLocator + runApp)
├── app.dart                         # MaterialApp + ProviderScope + navigatorKey
├── core/
│   ├── base/
│   │   ├── base_view_model.dart     # StateNotifier base (safeSetState, mapFailure, logger)
│   │   ├── base_view.dart           # ConsumerStatefulWidget (ProviderListenable<S>)
│   │   └── base_state.dart          # AsyncState<T> union (idle/loading/success/failure)
│   ├── di/
│   │   └── service_locator.dart     # GetIt setup — ALL registrations live here
│   ├── error/
│   │   ├── app_exception.dart       # sealed AppException hierarchy (throw-style)
│   │   └── failure.dart             # @freezed Failure union (return-style, used with Either)
│   ├── navigation/
│   │   ├── app_routes.dart          # const route strings
│   │   ├── app_router.dart          # onGenerateRoute — maps route name → screen widget
│   │   └── navigation_service.dart  # navigatorKey + INavigationService implementation
│   ├── network/
│   │   ├── api_client.dart          # Dio wrapper → Either<Failure, T>
│   │   ├── api_interceptor.dart     # AuthInterceptor + LoggingInterceptor
│   │   └── api_response.dart        # Plain ApiResponse<T> / PaginatedResponse<T>
│   ├── services/
│   │   ├── storage_service.dart     # SharedPreferences wrapper
│   │   └── secure_storage_service.dart  # FlutterSecureStorage + token helpers
│   ├── utils/
│   │   ├── logger.dart              # AppLogger(tag) wrapping logger package
│   │   └── formatters.dart          # currency, date, relativeTime, compactNumber
│   └── validators/
│       └── validators.dart          # static: email, password, phone, url, compose()
├── features/
│   └── auth/                        # Example feature — copy this for new features
│       ├── repository/auth_repository.dart
│       ├── state/login_state.dart
│       ├── view/login_screen.dart
│       └── viewmodel/login_view_model.dart
└── shared/
    ├── constants/app_constants.dart  # baseUrl, storage keys
    ├── theme/app_theme.dart          # AppColors, AppTheme.light, AppTheme.dark
    └── widgets/                      # shared atoms/molecules (empty — add as needed)
```
