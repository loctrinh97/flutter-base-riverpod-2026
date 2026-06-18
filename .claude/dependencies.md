# Dependencies — INNO Mobile

## Runtime dependencies

| Package | Version | Role | Notes |
|---------|---------|------|-------|
| `flutter_riverpod` | `^2.4.9` | State management | `StateNotifierProvider` per screen |
| `riverpod_annotation` | `^2.3.3` | Codegen annotations for Riverpod | Used with `riverpod_generator` |
| `get_it` | `^9.2.1` | Dependency injection (`locator<T>()`) | Service locator pattern — replaced discontinued GetX |
| `dio` | `^5.4.0` | HTTP client | Wrapped by `ApiClient` — never use Dio directly in ViewModels |
| `shared_preferences` | `^2.2.2` | Key-value persistence (non-sensitive) | Wrapped by `StorageService` |
| `flutter_secure_storage` | `^10.3.1` | Encrypted storage for tokens | Wrapped by `SecureStorageService` |
| `freezed_annotation` | `^2.4.1` | Immutable class annotations | Every state + Failure uses `@freezed` |
| `json_annotation` | `^4.8.1` | JSON serialization annotations | Used in model classes |
| `logger` | `^2.7.0` | Structured logging | Wrapped by `AppLogger(tag)` in `core/utils/logger.dart` |
| `dartz` | `^0.10.1` | Functional types (`Either`, `Option`) | `Either<Failure, T>` for all repo returns |
| `uuid` | `^4.3.3` | UUID generation | Available for generating IDs |
| `intl` | `^0.20.2` | Date/number formatting | Used in `AppFormatters` |
| `flutter_svg` | `^2.0.9` | SVG image rendering | Used in shared widgets |

## Dev dependencies

| Package | Version | Role |
|---------|---------|------|
| `build_runner` | `^2.4.8` | Code generation runner |
| `freezed` | `^2.4.6` | Generates `@freezed` classes |
| `json_serializable` | `^6.7.1` | Generates `fromJson`/`toJson` for models |
| `riverpod_generator` | `^2.3.9` | Generates Riverpod providers from annotations |
| `custom_lint` | `^0.6.0` | Custom lint rules framework |
| `riverpod_lint` | `^2.3.7` | Lint rules specific to Riverpod patterns |
| `flutter_lints` | `^3.0.0` | Flutter/Dart recommended lint rules |

## Packages intentionally NOT included

| Package | Reason excluded |
|---------|----------------|
| `bloc` / `flutter_bloc` | Riverpod chosen instead |
| `provider` | Riverpod is the successor |
| `kiwi` | `get_it` used for DI instead |
| `get` (GetX) | Discontinued — replaced by `get_it` for DI and Flutter `Navigator` for navigation |
| `graphql_flutter` | REST-first; add if GraphQL is needed |
| `connectivity_plus` | Can be added when offline detection is required |
| `amazon_cognito_identity_dart_2` | Auth via REST API; add if Cognito is needed |

## Codegen workflow
```bash
# Run after any change to @freezed, @JsonSerializable, or @riverpod annotated files
dart run build_runner build --delete-conflicting-outputs

# Watch mode during active development
dart run build_runner watch --delete-conflicting-outputs
```

Generated files (`*.freezed.dart`, `*.g.dart`) are in `.gitignore` — always run codegen after pull.
