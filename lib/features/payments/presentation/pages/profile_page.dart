import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../application/payment_providers.dart';
import '../../application/payment_state.dart';
import '../../domain/entities/transaction_entity.dart';
import '../widgets/donation_sheet.dart';
import '../widgets/premium_card.dart';
import 'premium_page.dart';

/// The user's profile / account page.
///
/// Surfaces the premium upsell card, donation entry point, transaction
/// history, and sign-out. It ties together the Paystack payments feature
/// with the authenticated user's profile.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPaymentProfile);
  }

  Future<void> _loadPaymentProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref.read(paymentNotifierProvider.notifier).loadProfile(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final paymentState = ref.watch(paymentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Appearance',
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : switch (paymentState) {
              PaymentInitial() || PaymentLoading() =>
                const Center(child: CircularProgressIndicator()),
              PaymentError(:final message) =>
                _ErrorView(message: message, onRetry: _loadPaymentProfile),
              PaymentLoaded() => _ProfileView(
                  user: user,
                  state: paymentState,
                  onGoPremium: () => _goPremium(context),
                  onDonate: () => _openDonation(context),
                  onSignOut: _signOut,
                ),
            },
    );
  }

  void _goPremium(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PremiumPage()),
    );
  }

  Future<void> _openDonation(BuildContext context) async {
    await DonationSheet.show(context);
  }

  Future<void> _signOut() async {
    await ref.read(authNotifierProvider.notifier).signOut();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.user,
    required this.state,
    required this.onGoPremium,
    required this.onDonate,
    required this.onSignOut,
  });

  final UserEntity user;
  final PaymentLoaded state;
  final VoidCallback onGoPremium;
  final VoidCallback onDonate;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = state.transactions;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _UserHeader(user: user),
        const SizedBox(height: 8),
        PremiumCard(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onGoPremium,
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('Go Premium'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDonate,
                  icon: const Icon(Icons.favorite),
                  label: const Text('Donate'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Transaction History',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No transactions yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...transactions.map(
            (tx) => _TransactionTile(transaction: tx),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user.displayName ?? 'User';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: user.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.photoUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Text(
                    name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});
  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color, label) = switch (transaction.status) {
      TransactionStatus.success => (
          Icons.check_circle,
          Colors.green,
          'Success',
        ),
      TransactionStatus.pending => (
          Icons.hourglass_top,
          Colors.orange,
          'Pending',
        ),
      TransactionStatus.failed => (
          Icons.error,
          Colors.red,
          'Failed',
        ),
      TransactionStatus.abandoned => (
          Icons.cancel,
          Colors.grey,
          'Abandoned',
        ),
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(transaction.planName),
        subtitle: Text(
          '${DateFormat('MMM d, yyyy HH:mm').format(transaction.createdAt.toLocal())}\n'
          'Ref: ${transaction.reference}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₦${transaction.amountNaira.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
