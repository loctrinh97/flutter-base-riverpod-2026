import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_interceptor.dart';
import '../navigation/navigation_service.dart';
import '../services/secure_storage_service.dart';
import '../services/storage_service.dart';
import '../../shared/constants/app_constants.dart';
import '../../features/auth/repository/auth_repository.dart';

/// Global service locator instance.
/// Use [locator<T>()] anywhere in the app to resolve a registered service.
final GetIt locator = GetIt.instance;

/// Registers all application services.
/// Called once in [main()] before [runApp()].
Future<void> setupLocator() async {
  // ── Storage ────────────────────────────────────────────────────────────────
  // SharedPreferences requires async init — resolved here so everything below
  // can register synchronously.
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  locator.registerSingleton<SecureStorageService>(SecureStorageService());

  locator.registerLazySingleton<StorageService>(
    () => StorageService(locator<SharedPreferences>()),
  );

  // ── Navigation ─────────────────────────────────────────────────────────────
  locator.registerSingleton<NavigationService>(NavigationService());

  // ── Network ────────────────────────────────────────────────────────────────
  locator.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(locator<SecureStorageService>()),
  );

  locator.registerLazySingleton<LoggingInterceptor>(LoggingInterceptor.new);

  locator.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: AppConstants.baseUrl,
      authInterceptor: locator<AuthInterceptor>(),
      loggingInterceptor: locator<LoggingInterceptor>(),
    ),
  );

  // ── Repositories ───────────────────────────────────────────────────────────
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiClient: locator<ApiClient>(),
      secureStorage: locator<SecureStorageService>(),
    ),
  );
}
