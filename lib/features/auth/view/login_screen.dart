import 'package:flutter/material.dart';
import '../../../core/base/base_view.dart';
import '../viewmodel/login_view_model.dart';
import '../state/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => BaseView<LoginState>(
        provider: loginViewModelProvider,
        builder: (context, ref, state) {
          final vm = ref.read(loginViewModelProvider.notifier);
          return _LoginBody(vm: vm, state: state);
        },
      );
}

class _LoginBody extends StatefulWidget {
  const _LoginBody({required this.vm, required this.state});

  final LoginViewModel vm;
  final LoginState state;

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final vm = widget.vm;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Welcome back', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Sign in to your account',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Email
              TextFormField(
                controller: _emailController,
                onChanged: vm.onEmailChanged,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: state.emailError.isNotEmpty ? state.emailError : null,
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                onChanged: vm.onPasswordChanged,
                obscureText: !state.isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText:
                      state.passwordError.isNotEmpty ? state.passwordError : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: vm.togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: vm.navigateToForgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),

              // Error message
              if (state.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Login button
              ElevatedButton(
                onPressed: state.isLoginEnabled && !state.isLoading
                    ? vm.login
                    : null,
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
