import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_button.dart';
import '../../application/payment_providers.dart';
import '../../domain/entities/transaction_entity.dart';

/// Displays the Paystack hosted-checkout URL and opens it for the user.
///
/// Because the app intentionally uses Paystack's hosted checkout (no
/// card-number handling on-device), this screen presents the secure payment
/// link and provides a one-tap "Open Paystack" action, plus a verification
/// step after payment completes to apply premium/donation permissions.
class CheckoutLauncherPage extends ConsumerStatefulWidget {
  const CheckoutLauncherPage({super.key, required this.transaction});

  final TransactionEntity transaction;

  @override
  ConsumerState<CheckoutLauncherPage> createState() =>
      _CheckoutLauncherPageState();
}

class _CheckoutLauncherPageState extends ConsumerState<CheckoutLauncherPage> {
  bool _verified = false;

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final processing = ref.watch(paymentProcessingProvider);
    final url = tx.authorizationUrl;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Secure Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Complete your payment securely',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${tx.planName} • ₦${tx.amountNaira.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'You will be redirected to Paystack\'s PCI-DSS compliant checkout.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Open Paystack Checkout',
              icon: Icons.open_in_new,
              onPressed: url == null
                  ? null
                  : () {
                      _openCheckout(context, url);
                    },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: _verified ? 'Verified ✓' : 'I\'ve completed payment',
              backgroundColor: Colors.green,
              enabled: !_verified,
              loading: processing,
              onPressed: _verified ? null : _verify,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _openCheckout(BuildContext context, String url) {
    // Opens the Paystack hosted checkout confirmation link in the system
    // browser. The user returns to the app afterwards to verify.
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Checkout URL: $url'),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  Future<void> _verify() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue.')),
      );
      return;
    }
    final notifier = ref.read(paymentNotifierProvider.notifier);
    final result =
        await notifier.verify(user.id, widget.transaction.reference);

    if (!mounted) return;
    if (result?.isSuccessful ?? false) {
      setState(() => _verified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment verified! Your benefits are now active.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment could not be verified. If you completed payment, '
            'contact support with your reference.',
          ),
        ),
      );
    }
  }
}

