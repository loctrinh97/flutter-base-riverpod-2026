# Troubleshooting — Known Issues & Fixes

All issues here have already been resolved. Documented so they are never re-investigated.

---

## Android: NDK `source.properties` missing
**Error:**
```
[CXX1101] NDK at /Users/.../sdk/ndk/28.2.13676358 did not have a source.properties file
```
**Cause:** Flutter 3.44.1 requires NDK `28.2.13676358` (hardcoded in `FlutterExtension.kt`).
The NDK directory existed but was corrupted — `source.properties` was absent.

**Fix (already applied — only redo if NDK is deleted):**
```bash
echo "y" | ~/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "ndk;28.2.13676358"
```
Verify:
```bash
cat ~/Library/Android/sdk/ndk/28.2.13676358/source.properties
# Should show: Pkg.Revision = 28.2.13676358
```

---

## iOS/macOS: CocoaPods integration warning on every build
**Warning:**
```
All plugins found for ios are Swift Packages, but your project still has CocoaPods integration.
```
**Cause:** Old `Podfile` and `#include? "Pods/..."` lines in xcconfig files still present
after migrating all plugins to Swift Package Manager.

**Fix (already applied):**
1. `cd ios && LANG=en_US.UTF-8 pod deintegrate`
2. `cd macos && LANG=en_US.UTF-8 pod deintegrate`
3. Delete `ios/Podfile` and `macos/Podfile`
4. Remove `#include? "Pods/..."` line from:
   - `ios/Flutter/Debug.xcconfig`
   - `ios/Flutter/Release.xcconfig`
   - `macos/Flutter/Flutter-Debug.xcconfig`
   - `macos/Flutter/Flutter-Release.xcconfig`

**If `pod` crashes with encoding error:**
CocoaPods requires `LANG=en_US.UTF-8`. Always prefix: `LANG=en_US.UTF-8 pod <command>`.

---

## build_runner: generic `@freezed` class with `json_serializable`
**Error:**
```
[SEVERE] json_serializable: Could not generate fromJson code for data because of type T (type parameter).
```
**Cause:** `json_serializable` cannot auto-generate `fromJson` for generic type parameters
inside `@freezed` classes.

**Fix (already applied in `api_response.dart`):**
Remove `@freezed` + `part '*.g.dart'` from generic wrapper classes.
Write a plain Dart class with a manual `fromJson` factory instead.
`ApiClient` already accepts a `decoder` callback so codegen is not needed there.

---

## `runtimeType` in initializer list
**Error:**
```
The instance member 'runtimeType' can't be accessed in an initializer.
```
**Cause:** `runtimeType` is an instance member; it cannot be used in `: field = expr` syntax.

**Fix (already applied in `base_view_model.dart`):**
```dart
// WRONG
BaseViewModel(super.s) : _log = AppLogger(runtimeType.toString());

// CORRECT
BaseViewModel(super.s) {
  _log = AppLogger(runtimeType.toString());
}
late final AppLogger _log;
```

---

## GetX → GetIt migration (completed)
**Background:** GetX was discontinued. Migrated to `get_it ^9.2.1`.

| Before (GetX) | After (GetIt) |
|---|---|
| `Get.find<T>()` | `locator<T>()` |
| `Get.put<T>(instance)` | `locator.registerSingleton<T>(instance)` |
| `Get.lazyPut<T>(() => T())` | `locator.registerLazySingleton<T>(() => T())` |
| `Get.putAsync(...)` | `await SharedPreferences.getInstance()` in `setupLocator()` |
| `AppBindings extends Bindings` | `Future<void> setupLocator()` in `service_locator.dart` |
| `GetMaterialApp(initialBinding:...)` | `MaterialApp(navigatorKey:, onGenerateRoute:)` |
| `Get.toNamed(route)` | `navigatorKey.currentState!.pushNamed(route)` |
| `Get.offAllNamed(route)` | `navigatorKey.currentState!.pushNamedAndRemoveUntil(route, (_) => false)` |
| `GetPage(name, page, binding)` | `case AppRoutes.xyz: return _page(XyzScreen())` in `AppRouter` |

---

## `BaseView` provider type mismatch (`autoDispose` vs regular)
**Error:**
```
The argument type 'AutoDisposeStateNotifierProvider<VM, S>' can't be assigned
to the parameter type 'StateNotifierProvider<VM, S>'
```
**Cause:** Original `BaseView<VM, S>` used `StateNotifierProvider<VM, S>` as the
parameter type, which rejects `autoDispose` variants.

**Fix (already applied in `base_view.dart`):**
Changed signature to `BaseView<S>` accepting `ProviderListenable<S>` and exposing
`WidgetRef` in the builder. Works with both `autoDispose` and regular providers.
```dart
// New API
BaseView<LoginState>(
  provider: loginViewModelProvider,      // autoDispose or regular — both work
  builder: (context, ref, state) { ... },
)
```

---

---

## `AsyncState<T>` — `this is _Loading` fails outside generated file
**Cause:** `_Loading`, `_Success` etc. are private generated classes. Checking `this is _Loading`
from an extension in a different file doesn't resolve correctly.

**Fix (already applied in `base_state.dart`):**
```dart
// WRONG
bool get isLoading => this is _Loading;

// CORRECT
bool get isLoading => maybeWhen(loading: () => true, orElse: () => false);
```

---

## `dart_code_metrics` conflicts with `build_runner 2.15`
**Error:**
```
dart_code_metrics >=5.7.5 depends on analyzer >=5.1.0 <5.14.0
build_runner >=2.15.0 depends on analyzer >=8.0.0 <14.0.0
```
**Fix:** Replace `dart_code_metrics` with its successor `dart_code_linter: ^4.1.2`
which requires `analyzer >=10.0.0 <14.0.0` (compatible with `build_runner 2.15`).

---

## core/pubspec.yaml — deprecated packages
These were present in `base-flutter/core` and have been replaced:

| Removed | Replacement |
|---------|-------------|
| `device_info` | `device_info_plus` |
| `share` | `share_plus` |
| `contacts_service` | `flutter_contacts` |
| `pedantic` | `flutter_lints` |
| `dart_code_metrics` | `dart_code_linter` |
