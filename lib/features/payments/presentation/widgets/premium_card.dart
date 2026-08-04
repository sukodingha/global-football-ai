import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/payment_providers.dart';
import '../../domain/entities/subscription_entity.dart';

/// Shows the user's premium status or invites them to upgrade.
class PremiumCard extends ConsumerWidget {
  const PremiumCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final isPremium = subscription?.isActive ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPremium
                ? [const Color(0xFFB8860B), const Color(0xFFFFD700)]
                : [Theme.of(context).colorScheme.primary, const Color(0xFF673AB7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isPremium ? Icons.workspace_premium : Icons.stars,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'Premium Active' : 'Unlock Premium',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium
                        ? _activeText(subscription)
                        : 'Get unlimited AI predictions, correct score, player props and ad-free experience.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _activeText(SubscriptionEntity? sub) {
    final end = sub?.currentPeriodEnd;
    if (end == null) return 'Enjoy your premium benefits.';
    final days = end.difference(DateTime.now()).inDays;
    if (days <= 0) return 'Your premium plan is active.';
    return 'Your premium plan renews in $days day${days == 1 ? '' : 's'}.';
  }
}

