import 'package:flutter/material.dart';

/// A small circular badge indicating a player's captain / vice-captain role
/// and the associated points multiplier.
class CaptainBadge extends StatelessWidget {
  const CaptainBadge({
    super.key,
    required this.role,
    this.size = 22,
  });

  /// `C` for captain, `VC` for vice-captain.
  final String role;
  final double size;

  Color _backgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return role.toUpperCase() == 'C' ? scheme.primary : scheme.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = role.toUpperCase() == 'C' ? 'C' : 'VC';
    final multiplier = role.toUpperCase() == 'C' ? '2x' : '1.5x';

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _backgroundColor(context),
        shape: BoxShape.circle,
      ),
      child: Tooltip(
        message: '$role · $multiplier points multiplier',
        child: Text(
          label,
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
