import 'package:flutter/material.dart';

import '../../domain/entities/admin_user_entity.dart';

/// A small colour-coded badge representing a user's role.
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (role) {
      UserRole.user => (
          Colors.grey.shade200,
          Colors.grey.shade800,
          Icons.person_outline,
        ),
      UserRole.moderator => (
          Colors.blue.shade100,
          Colors.blue.shade900,
          Icons.shield_outlined,
        ),
      UserRole.admin => (
          Colors.orange.shade100,
          Colors.orange.shade900,
          Icons.admin_panel_settings_outlined,
        ),
      UserRole.superAdmin => (
          Colors.red.shade100,
          Colors.red.shade900,
          Icons.workspace_premium,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            role.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
