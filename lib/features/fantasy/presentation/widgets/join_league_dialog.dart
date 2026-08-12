import 'package:flutter/material.dart';

import '../../../../core/widgets/app_text_field.dart';

/// Dialog for joining a fantasy league by entering a 6-character join code.
class JoinLeagueDialog extends StatefulWidget {
  const JoinLeagueDialog({super.key});

  @override
  State<JoinLeagueDialog> createState() => _JoinLeagueDialogState();
}

class _JoinLeagueDialogState extends State<JoinLeagueDialog> {
  final _codeController = TextEditingController();
  final _teamNameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join League'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Join Code *',
              icon: Icons.vpn_key_outlined,
              controller: _codeController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Your Team Name *',
              icon: Icons.shield_outlined,
              controller: _teamNameController,
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
          onPressed: _codeController.text.trim().length == 6 &&
                  _teamNameController.text.trim().isNotEmpty
              ? () => Navigator.of(context).pop({
                    'code': _codeController.text.trim().toUpperCase(),
                    'teamName': _teamNameController.text.trim(),
                  })
              : null,
          child: const Text('Join'),
        ),
      ],
    );
  }
}

/// Convenience method to show the dialog.
Future<Map<String, dynamic>?> showJoinLeagueDialog(BuildContext context) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => const JoinLeagueDialog(),
  );
}

