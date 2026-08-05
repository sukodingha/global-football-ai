import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../application/admin_providers.dart';
import '../../domain/entities/admin_competition_entity.dart';
import '../widgets/competition_tile.dart';

/// Tab for managing competitions, fixtures, and team data.
class AdminCompetitionsPage extends ConsumerWidget {
  const AdminCompetitionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitions = ref.watch(adminCompetitionsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _createCompetition(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('New Competition'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: competitions.isEmpty
              ? const EmptyStateView(
                  icon: Icons.emoji_events_outlined,
                  title: 'No competitions',
                  message: 'Add competitions to manage fixtures and teams.',
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    for (final c in competitions)
                      CompetitionTile(
                        competition: c,
                        onToggleFeatured: (featured) => ref
                            .read(adminNotifierProvider.notifier)
                            .toggleCompetitionFeatured(id: c.id, featured: featured),
                        onToggleActive: (active) => ref
                            .read(adminNotifierProvider.notifier)
                            .updateCompetition(c.copyWith(active: active)),
                        onEdit: () => _editCompetition(context, ref, c),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  void _createCompetition(BuildContext context, WidgetRef ref) async {
    final result = await _CompetitionDialog().show(context);
    if (result != null) {
      ref.read(adminNotifierProvider.notifier).createCompetition(result);
    }
  }

  void _editCompetition(
    BuildContext context,
    WidgetRef ref,
    AdminCompetitionEntity c,
  ) async {
    final result = await _CompetitionDialog(existing: c).show(context);
    if (result != null) {
      ref.read(adminNotifierProvider.notifier).updateCompetition(result);
    }
  }
}

class _CompetitionDialog extends StatefulWidget {
  const _CompetitionDialog({this.existing});
  final AdminCompetitionEntity? existing;

  @override
  State<_CompetitionDialog> createState() => _CompetitionDialogState();

  Future<AdminCompetitionEntity?> show(BuildContext context) {
    return showDialog<AdminCompetitionEntity>(
      context: context,
      builder: (_) => this,
    );
  }
}

class _CompetitionDialogState extends State<_CompetitionDialog> {
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _type;
  late final TextEditingController _country;
  bool _featured = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _code = TextEditingController(text: e?.code ?? '');
    _type = TextEditingController(text: e?.type ?? 'LEAGUE');
    _country = TextEditingController(text: e?.country ?? '');
    _featured = e?.featured ?? false;
    _active = e?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _type.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'New Competition' : 'Edit Competition'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _code,
              decoration: const InputDecoration(labelText: 'Code (e.g. PL)'),
            ),
            TextField(
              controller: _type,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: _country,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Featured'),
              value: _featured,
              onChanged: (v) => setState(() => _featured = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final existing = widget.existing;
            Navigator.pop(
              context,
              AdminCompetitionEntity(
                id: existing?.id ?? '',
                name: _name.text.trim(),
                code: _code.text.trim(),
                type: _type.text.trim().isEmpty ? 'LEAGUE' : _type.text.trim(),
                country: _country.text.trim().isEmpty
                    ? null
                    : _country.text.trim(),
                emblem: existing?.emblem,
                currentMatchday: existing?.currentMatchday,
                featured: _featured,
                active: _active,
                totalTeams: existing?.totalTeams ?? 0,
                totalFixtures: existing?.totalFixtures ?? 0,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
