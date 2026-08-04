import 'package:flutter/material.dart';

import 'preference_toggle_tile.dart';

/// A titled section grouping related [PreferenceToggleTile]s.
class PreferenceSection extends StatelessWidget {
  const PreferenceSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
  });

  final String title;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
              ],
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        ...children,
        const Divider(height: 24),
      ],
    );
  }
}
