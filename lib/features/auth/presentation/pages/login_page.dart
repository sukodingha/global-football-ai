import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/social_auth_button.dart';

/// Login page with email/password, social, phone, and biometric options.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  bool _socialLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final notifier = ref.read(authNotifierProvider.notifier);
    final error = await notifier.loginWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (mounted) {
      setState(() => _submitting = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _socialLoading = true);
    final notifier = ref.read(authNotifierProvider.notifier);
    final error = await notifier.signInWithGoogle();
    if (mounted) {
      setState(() => _socialLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        context.go(AppConstants.routeHome);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _socialLoading = true);
    final notifier = ref.read(authNotifierProvider.notifier);
    final error = await notifier.signInWithApple();
    if (mounted) {
      setState(() => _socialLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    final error = await notifier.loginWithBiometrics();
    if (mounted && error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricAvailable = ref.watch(biometricAvailabilityProvider).value ?? false;

    return AuthScaffold(
      title: 'Welcome Back',
      subtitle: 'Sign in to continue to Global Football AI',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) => EmailValidator.validate(value).message,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: (value) => PasswordValidator.validate(value).message,
              onFieldSubmitted: (_) => _handleLogin(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.go(AppConstants.routeForgotPassword);
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Sign In',
              onPressed: _handleLogin,
              loading: _submitting,
            ),
            if (biometricAvailable) ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'Sign in with Biometrics',
                onPressed: _handleBiometricLogin,
                icon: Icons.fingerprint,
                backgroundColor: Colors.black87,
              ),
            ],
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            SocialAuthButton(
              label: 'Continue with Google',
              icon: Icons.g_mobiledata,
              loading: _socialLoading,
              onPressed: _handleGoogleSignIn,
            ),
            const SizedBox(height: 12),
            SocialAuthButton(
              label: 'Continue with Apple',
              icon: Icons.apple,
              loading: _socialLoading,
              onPressed: _handleAppleSignIn,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                context.go(AppConstants.routePhoneLogin);
              },
              icon: const Icon(Icons.phone_android),
              label: const Text('Continue with Phone'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account?'),
                TextButton(
                  onPressed: () {
                    context.go(AppConstants.routeRegister);
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
