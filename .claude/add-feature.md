# Adding a New Feature — Checklist

Copy this checklist every time. Feature name example: `profile`.

---

## Step-by-step

### 1. Create directory structure
```
lib/features/<name>/
    ├── repository/
    │   └── <name>_repository.dart
    ├── state/
    │   └── <name>_state.dart
    ├── view/
    │   └── <name>_screen.dart
    └── viewmodel/
        └── <name>_view_model.dart
```

### 2. Define the state
File: `lib/features/<name>/state/<name>_state.dart`
- Use `@freezed` class.
- All UI-relevant fields: data, `isLoading`, `errorMessage`, form field errors.
- Run codegen after: `dart run build_runner build --delete-conflicting-outputs`

### 3. Define the repository interface + implementation
File: `lib/features/<name>/repository/<name>_repository.dart`
- Declare `abstract interface class IXyzRepository`.
- Implement `XyzRepository` using `ApiClient`.
- Return `Either<Failure, T>` for every method.

### 4. Write the ViewModel
File: `lib/features/<name>/viewmodel/<name>_view_model.dart`
- Extend `BaseViewModel<XyzState>`.
- Inject `IXyzRepository` and `NavigationService`.
- Declare `StateNotifierProvider.autoDispose` at the bottom.
- Use `safeSetState()` and `mapFailure()` throughout.

### 5. Build the screen
File: `lib/features/<name>/view/<name>_screen.dart`
- Wrap with `BaseView<XyzState>(provider: xyzViewModelProvider, ...)`.
- Call `onInit: (ref) => ref.read(...notifier).init()` for initial data loads.
- Extract the body into a private `_XyzBody` widget.

### 6. Register in DI
File: `lib/core/di/service_locator.dart` — inside `setupLocator()`:
```dart
locator.registerLazySingleton<XyzRepository>(
  () => XyzRepository(apiClient: locator<ApiClient>()),
);
```
Also add the import at the top of `service_locator.dart`.

### 7. Add the route
File: `lib/core/navigation/app_routes.dart`:
```dart
static const xyz = '/xyz';
```

File: `lib/core/navigation/app_router.dart` — inside the `switch`:
```dart
case AppRoutes.xyz:
  return _page(const XyzScreen());
```

### 8. Navigate to the screen
From a ViewModel:
```dart
_navigationService.push(AppRoutes.xyz);
// or with arguments:
_navigationService.push(AppRoutes.xyz, arguments: {'id': item.id});
```

### 9. Run checks
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

---

## Quick template — minimal feature scaffold

```dart
// STATE
@freezed
class FeatureState with _$FeatureState {
  const factory FeatureState({
    @Default([]) List<Item> items,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _FeatureState;
}

// VIEW MODEL
class FeatureViewModel extends BaseViewModel<FeatureState> {
  FeatureViewModel({required IFeatureRepository repo, required NavigationService nav})
      : _repo = repo, _nav = nav, super(const FeatureState());
  final IFeatureRepository _repo;
  final NavigationService _nav;

  Future<void> init() async {
    safeSetState(state.copyWith(isLoading: true));
    final result = await _repo.fetchItems();
    result.fold(
      (f) => safeSetState(state.copyWith(isLoading: false, errorMessage: mapFailure(f))),
      (items) => safeSetState(state.copyWith(isLoading: false, items: items)),
    );
  }
}

final featureViewModelProvider =
    StateNotifierProvider.autoDispose<FeatureViewModel, FeatureState>(
  (ref) => FeatureViewModel(
    repo: locator<FeatureRepository>(),
    nav: locator<NavigationService>(),
  ),
);

// SCREEN
class FeatureScreen extends StatelessWidget {
  const FeatureScreen({super.key});
  @override
  Widget build(BuildContext context) => BaseView<FeatureState>(
        provider: featureViewModelProvider,
        onInit: (ref) => ref.read(featureViewModelProvider.notifier).init(),
        builder: (context, ref, state) {
          final vm = ref.read(featureViewModelProvider.notifier);
          return _FeatureBody(vm: vm, state: state);
        },
      );
}
```
