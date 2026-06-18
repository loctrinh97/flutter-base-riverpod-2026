# Code Patterns — INNO Mobile

Canonical examples to follow exactly. Do not invent new patterns.

---

## 1. State (`@freezed`)

```dart
// lib/features/xyz/state/xyz_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'xyz_state.freezed.dart';

@freezed
class XyzState with _$XyzState {
  const factory XyzState({
    // Data fields
    @Default([]) List<Item> items,
    Item? selectedItem,

    // UI control fields
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitEnabled,
    String? errorMessage,
  }) = _XyzState;
}
```
**Rules:**
- All fields have defaults (`@Default`) or are nullable.
- No logic in state — it's pure data.
- After adding: run `dart run build_runner build --delete-conflicting-outputs`.

---

## 2. ViewModel

```dart
// lib/features/xyz/viewmodel/xyz_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base/base_view_model.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/navigation/app_routes.dart';
import '../repository/xyz_repository.dart';
import '../state/xyz_state.dart';

class XyzViewModel extends BaseViewModel<XyzState> {
  XyzViewModel({
    required IXyzRepository repository,
    required NavigationService navigationService,
  })  : _repository = repository,
        _navigationService = navigationService,
        super(const XyzState());

  final IXyzRepository _repository;
  final NavigationService _navigationService;

  // Called once on screen open
  Future<void> init() async {
    safeSetState(state.copyWith(isLoading: true));
    final result = await _repository.fetchItems();
    result.fold(
      (failure) => safeSetState(state.copyWith(
        isLoading: false,
        errorMessage: mapFailure(failure),
      )),
      (items) => safeSetState(state.copyWith(
        isLoading: false,
        items: items,
      )),
    );
  }

  void selectItem(Item item) =>
      safeSetState(state.copyWith(selectedItem: item));

  Future<void> submit() async { /* same fold pattern as init */ }

  void goToDetail(String id) =>
      _navigationService.push(AppRoutes.xyzDetail, arguments: id);
}

// Riverpod provider — always autoDispose for screens
final xyzViewModelProvider =
    StateNotifierProvider.autoDispose<XyzViewModel, XyzState>(
  (ref) => XyzViewModel(
    repository: locator<XyzRepository>(),
    navigationService: locator<NavigationService>(),
  ),
);
```
**Rules:**
- Extend `BaseViewModel<S>` — never `StateNotifier` directly.
- Use `safeSetState()` — never `state =` directly.
- Use `mapFailure(failure)` — never hand-write error strings.
- Provider is declared at the bottom of the ViewModel file.
- Use `autoDispose` for screens; omit it for global/shared state.

---

## 3. Repository

```dart
// lib/features/xyz/repository/xyz_repository.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../core/network/api_client.dart';

abstract interface class IXyzRepository {
  Future<Either<Failure, List<Item>>> fetchItems();
  Future<Either<Failure, Item>> getItem(String id);
}

class XyzRepository implements IXyzRepository {
  XyzRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  @override
  Future<Either<Failure, List<Item>>> fetchItems() =>
      _api.get(
        '/xyz',
        decoder: (json) => (json as List)
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Future<Either<Failure, Item>> getItem(String id) =>
      _api.get(
        '/xyz/$id',
        decoder: (json) => Item.fromJson(json as Map<String, dynamic>),
      );
}
```
**Rules:**
- Always declare an `interface` (`IXyzRepository`) — ViewModel depends on interface, not class.
- Return `Either<Failure, T>` — never throw, never return null for errors.
- No business logic here — just network/storage calls.

---

## 4. Screen (`BaseView`)

```dart
// lib/features/xyz/view/xyz_screen.dart
import 'package:flutter/material.dart';
import '../../../core/base/base_view.dart';
import '../viewmodel/xyz_view_model.dart';
import '../state/xyz_state.dart';

class XyzScreen extends StatelessWidget {
  const XyzScreen({super.key});

  @override
  Widget build(BuildContext context) => BaseView<XyzState>(
        provider: xyzViewModelProvider,
        onInit: (ref) => ref.read(xyzViewModelProvider.notifier).init(),
        builder: (context, ref, state) {
          final vm = ref.read(xyzViewModelProvider.notifier);
          return _XyzBody(vm: vm, state: state);
        },
      );
}

class _XyzBody extends StatelessWidget {
  const _XyzBody({required this.vm, required this.state});
  final XyzViewModel vm;
  final XyzState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.errorMessage != null) return Center(child: Text(state.errorMessage!));
    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(state.items[i].name),
        onTap: () => vm.selectItem(state.items[i]),
      ),
    );
  }
}
```
**Rules:**
- Outer widget is `StatelessWidget` — `BaseView` handles ConsumerState internally.
- Extract body into a separate `_XyzBody` private widget.
- Only pass `vm` and `state` — never pass `ref` down the tree.
- `onInit` is the right place for one-time data loading.

---

## 5. Registering a new repository in DI

Edit `lib/core/di/service_locator.dart` inside `setupLocator()`:

```dart
locator.registerLazySingleton<XyzRepository>(
  () => XyzRepository(apiClient: locator<ApiClient>()),
);
```

Also add the import at the top of `service_locator.dart`:
```dart
import '../../features/xyz/repository/xyz_repository.dart';
```

---

## 6. Adding a new route

**Step 1** — `lib/core/navigation/app_routes.dart`:
```dart
static const xyzDetail = '/xyz/detail';
```

**Step 2** — `lib/core/navigation/app_router.dart` inside the `switch`:
```dart
case AppRoutes.xyzDetail:
  return _page(const XyzDetailScreen());
```

---

## 7. AsyncState<T> — for generic async operations

Use `AsyncState<T>` (from `core/base/base_state.dart`) when the ViewModel
wraps a single async resource (e.g. a detail page load):

```dart
class ItemDetailViewModel extends BaseViewModel<AsyncState<Item>> {
  ItemDetailViewModel(...) : super(const AsyncState.idle());

  Future<void> load(String id) async {
    safeSetState(const AsyncState.loading());
    final result = await _repo.getItem(id);
    result.fold(
      (f) => safeSetState(AsyncState.failure(mapFailure(f))),
      (item) => safeSetState(AsyncState.success(item)),
    );
  }
}
```

In the UI:
```dart
state.when(
  idle:    ()      => const SizedBox(),
  loading: ()      => const CircularProgressIndicator(),
  success: (item)  => ItemWidget(item: item),
  failure: (msg)   => Text(msg, style: errorStyle),
)
```

---

## 8. Validators — composing rules

```dart
// Single rule
TextFormField(validator: Validators.email)

// Composed rules
TextFormField(
  validator: (v) => Validators.compose(v, [
    (v) => Validators.required(v, fieldName: 'Username'),
    (v) => Validators.minLength(v, 3, fieldName: 'Username'),
    (v) => Validators.maxLength(v, 20, fieldName: 'Username'),
  ]),
)
```

---

## 9. Logging

```dart
class MyViewModel extends BaseViewModel<MyState> {
  void doSomething() {
    logDebug('starting doSomething');      // AppLogger.d
    logInfo('result received');            // AppLogger.i
    logWarning('unexpected empty list');   // AppLogger.w
    logError('failed', error, stackTrace); // AppLogger.e
  }
}
```
Tag is set automatically to `runtimeType.toString()`.

---

## 10. Formatters

```dart
AppFormatters.currency(1299.5)              // "$1,299.50"
AppFormatters.date(DateTime.now())          // "Jun 09, 2026"
AppFormatters.relativeTime(someDateTime)    // "3h ago"
AppFormatters.compactNumber(1500000)        // "1.5M"
```
