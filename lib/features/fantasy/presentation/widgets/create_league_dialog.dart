import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/fantasy_league_entity.dart';

/// Dialog for creating a new fantasy league.
class CreateLeagueDialog extends StatefulWidget {
  const CreateLeagueDialog({super.key});

  @override
  State<CreateLeagueDialog> createState() => _CreateLeagueDialogState();
}

class _CreateLeagueDialogState extends State<CreateLeagueDialog> {
  final _nameController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _descController = TextEditingController();
  LeagueVisibility _visibility = LeagueVisibility.public;
  double _budget = 100;

  @override
  void dispose() {
    _nameController.dispose();
    _teamNameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Create League'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'League Name *',
              icon: Icons.emoji_events,
              controller: _nameController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Your Team Name',
              icon: Icons.shield_outlined,
              controller: _teamNameController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Description (optional)',
              icon: Icons.description_outlined,
              controller: _descController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Visibility:'),
                const SizedBox(width: 12),
                SegmentedButton<LeagueVisibility>(
                  segments: const [
                    ButtonSegment(
                      value: LeagueVisibility.public,
                      label: Text('Public'),
                      icon: Icon(Icons.public),
                    ),
                    ButtonSegment(
                      value: LeagueVisibility.private,
                      label: Text('Private'),
                      icon: Icon(Icons.lock_outline),
                    ),
                  ],
                  selected: {_visibility},
                  onSelectionChanged: (v) =>
                      setState(() => _visibility = v.first),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Budget:'),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: _budget,
                    min: 50,
                    max: 200,
                    divisions: 6,
                    label: '£${_budget.toStringAsFixed(0)}M',
                    onChanged: (v) => setState(() => _budget = v),
                  ),
                ),
                Text('£${_budget.toStringAsFixed(0)}M',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _nameController.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop({
                    'name': _nameController.text.trim(),
                    'teamName': _teamNameController.text.trim().isNotEmpty
                        ? _teamNameController.text.trim()
                        : '${_nameController.text.trim()} FC',
                    'visibility': _visibility,
                    'description': _descController.text.trim().isNotEmpty
                        ? _descController.text.trim()
                        : null,
                    'startBudget': _budget,
                  }),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

/// Convenience method to show the dialog.
Future<Map<String, dynamic>?> showCreateLeagueDialog(BuildContext context) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => const CreateLeagueDialog(),
  );
}

