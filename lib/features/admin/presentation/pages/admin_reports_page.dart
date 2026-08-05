import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/admin_providers.dart';
import '../../domain/entities/admin_analytics_entity.dart';
import '../../domain/entities/admin_revenue_entity.dart';

/// Tab for generating & viewing system reports.
class AdminReportsPage extends ConsumerStatefulWidget {
  const AdminReportsPage({super.key});

  @override
  ConsumerState<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends ConsumerState<AdminReportsPage> {
  String _generatedReport = '';
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(adminAnalyticsProvider);
    final revenue = ref.watch(adminRevenueProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('System Reports', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Generate on-demand CSV reports covering platform analytics and financial performance. Copy the report to export it.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report Builder',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _DataRow(
                  label: 'Analytics snapshot',
                  value: analytics == null
                      ? 'Not loaded'
                      : '${analytics.totalUsers} users, ${analytics.totalPredictions} predictions',
                ),
                _DataRow(
                  label: 'Revenue snapshot',
                  value: revenue == null
                      ? 'Not loaded'
                      : '${revenue.totalTransactions} transactions',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: (analytics == null || revenue == null)
                            ? null
                            : () {
                                final csv = ref
                                    .read(adminNotifierProvider.notifier)
                                    .generateReport();
                                setState(() {
                                  _generatedReport = csv;
                                  _copied = false;
                                });
                              },
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Generate Report'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _generatedReport.isEmpty
                            ? null
                            : () async {
                                await _copy(context);
                              },
                        icon: Icon(
                            _copied ? Icons.check : Icons.copy_all_outlined),
                        label: Text(_copied ? 'Copied!' : 'Copy CSV'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_generatedReport.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Generated Report', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: SelectableText(
                  _generatedReport,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _generatedReport));
    if (!mounted) return;
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report copied to clipboard.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
