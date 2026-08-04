import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_button.dart';
import '../../application/payment_providers.dart';
import '../../domain/entities/payment_plan_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../pages/checkout_page.dart';

/// Preset donation amounts in Naira.
const List<int> _presetDonations = [500, 1000, 2000, 5000, 10000, 25000];

/// Bottom sheet that lets a user make a one-off donation via Paystack.
class DonationSheet extends ConsumerStatefulWidget {
  const DonationSheet({super.key});

  @override
  ConsumerState<DonationSheet> createState() => _DonationSheetState();

  /// Shows the donation sheet from a BuildContext.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const DonationSheet(),
    );
  }
}

class _DonationSheetState extends ConsumerState<DonationSheet> {
  final TextEditingController _amountController = TextEditingController();
  final int _minNaira = 100;
  int _selectedPreset = 0;

  PaymentPlanEntity? _buildDonationPlan() {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount < _minNaira) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a donation of at least ₦100')),
      );
      return null;
    }
    return PaymentPlanEntity(
      id: 'donation',
      name: 'Donation',
      description: 'A one-off contribution to support development.',
      amountKobo: amount * 100,
      currency: 'NGN',
      isPremium: false,
    );
  }

  Future<void> _submit() async {
    final plan = _buildDonationPlan();
    if (plan == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to donate.')),
      );
      return;
    }

    final notifier = ref.read(paymentNotifierProvider.notifier);
    final tx = await notifier.initialize(user: user, plan: plan);
    if (tx == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to start donation. Please try again.'),
          ),
        );
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
      _openCheckout(context, tx);
    }
  }

  void _openCheckout(BuildContext context, TransactionEntity tx) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutLauncherPage(transaction: tx),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final processing = ref.watch(paymentProcessingProvider);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Support the project', style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Your donation helps keep AI predictions free for everyone.',
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetDonations.map((amount) {
              return ChoiceChip(
                label: Text('₦$amount'),
                selected: _selectedPreset == amount,
                onSelected: (_) {
                  setState(() {
                    _selectedPreset = amount;
                    _amountController.text = '$amount';
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Custom amount (₦)',
              prefixText: '₦ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Donate via Paystack',
            icon: Icons.favorite,
            loading: processing,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

