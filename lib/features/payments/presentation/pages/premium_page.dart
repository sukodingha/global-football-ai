import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_button.dart';
import '../../application/payment_providers.dart';
import '../../domain/entities/payment_plan_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import 'checkout_page.dart';

/// Premium membership upsell page with monthly and yearly plans.
class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  PaymentPlanEntity _selectedPlan = PremiumPlans.monthly;

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    final processing = ref.watch(paymentProcessingProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Go Premium')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isPremium) ...[
            const Card(
              color: Color(0xFFB8860B),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'You are already a Premium member. Enjoy the full experience!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Unlock the full AI experience',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a plan that fits you. Cancel anytime.',
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _PlanCard(
            plan: PremiumPlans.monthly,
            selected: _selectedPlan.id == PremiumPlans.monthly.id,
            onTap: () => setState(() => _selectedPlan = PremiumPlans.monthly),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            plan: PremiumPlans.yearly,
            selected: _selectedPlan.id == PremiumPlans.yearly.id,
            onTap: () => setState(() => _selectedPlan = PremiumPlans.yearly),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Continue to Paystack',
            icon: Icons.verified_user,
            loading: processing,
            onPressed: isPremium ? null : _continue,
          ),
        ],
      ),
    );
  }

  Future<void> _continue() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue.')),
      );
      return;
    }
    final notifier = ref.read(paymentNotifierProvider.notifier);
    final tx = await notifier.initialize(user: user, plan: _selectedPlan);
    if (tx == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to start checkout. Please try again.'),
          ),
        );
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CheckoutLauncherPage(transaction: tx),
        ),
      );
    }
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PaymentPlanEntity plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? theme.colorScheme.primary : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦${plan.amountNaira.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF008000),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.description,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ...plan.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Expanded(child: Text(f)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
