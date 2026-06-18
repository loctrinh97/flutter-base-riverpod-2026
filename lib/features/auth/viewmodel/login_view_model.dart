import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base/base_view_model.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/validators/validators.dart';
import '../repository/auth_repository.dart';
import '../state/login_state.dart';

class LoginViewModel extends BaseViewModel<LoginState> {
  LoginViewModel({
    required IAuthRepository authRepository,
    required NavigationService navigationService,
  })  : _authRepository = authRepository,
        _navigationService = navigationService,
        super(const LoginState());

  final IAuthRepository _authRepository;
  final NavigationService _navigationService;

  void onEmailChanged(String value) {
    final error = Validators.email(value) ?? '';
    safeSetState(state.copyWith(
      email: value,
      emailError: error,
      isLoginEnabled: _canLogin(email: value, password: state.password),
      errorMessage: null,
    ));
  }

  void onPasswordChanged(String value) {
    final error = Validators.password(value) ?? '';
    safeSetState(state.copyWith(
      password: value,
      passwordError: error,
      isLoginEnabled: _canLogin(email: state.email, password: value),
      errorMessage: null,
    ));
  }

  void togglePasswordVisibility() =>
      safeSetState(state.copyWith(isPasswordVisible: !state.isPasswordVisible));

  Future<void> login() async {
    if (!state.isLoginEnabled) return;

    safeSetState(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _authRepository.login(state.email, state.password);

    result.fold(
      (failure) => safeSetState(state.copyWith(
        isLoading: false,
        errorMessage: mapFailure(failure),
      )),
      (_) {
        safeSetState(state.copyWith(isLoading: false));
        _navigationService.pushAndClearStack(AppRoutes.home);
      },
    );
  }

  void navigateToForgotPassword() =>
      _navigationService.push(AppRoutes.forgotPassword);

  bool _canLogin({required String email, required String password}) =>
      Validators.email(email) == null && Validators.password(password) == null;
}

// Riverpod provider
final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(
    authRepository: locator<AuthRepository>(),
    navigationService: locator<NavigationService>(),
  ),
);
