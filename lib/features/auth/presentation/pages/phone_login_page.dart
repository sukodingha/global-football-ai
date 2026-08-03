import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../application/auth_notifier.dart';
import '../widgets/auth_scaffold.dart';

/// Phone login page that sends an OTP verification code.
class PhoneLoginPage extends ConsumerStatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  ConsumerState<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends ConsumerState<PhoneLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final notifier = ref.read(authNotifierProvider.notifier);
    final error = await notifier.sendPhoneVerificationCode(
      phoneNumber: _phoneController.text.trim(),
      onCodeSent: (verificationId) {
        if (mounted) {
          context.go(
            AppConstants.routeOtpVerification,
            extra: verificationId,
          );
        }
      },
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

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Phone Login',
      subtitle: 'Enter your phone number to receive a verification code',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: (value) => PhoneValidator.validate(value).message,
              onFieldSubmitted: (_) => _handleSendCode(),
            ),
            const SizedBox(height: 8),
            const Text(
              'Include country code, e.g. +1 555 123 4567',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Send Verification Code',
              onPressed: _handleSendCode,
              loading: _submitting,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go(AppConstants.routeLogin);
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
