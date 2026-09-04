import 'package:flutter/material.dart';
import '../services/database_service.dart';

Future<void> showAddToCollectionSheet(BuildContext context, String textId) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AddToCollectionSheet(textId: textId),
  );
}

class _AddToCollectionSheet extends StatefulWidget {
  final String textId;
  const _AddToCollectionSheet({required this.textId});

  @override
  State<_AddToCollectionSheet> createState() => _AddToCollectionSheetState();
}

class _AddToCollectionSheetState extends State<_AddToCollectionSheet> {
  List<Map<String, dynamic>> _collections = [];
  Set<int> _memberOf = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cols = await DatabaseService.instance.getCollections();
    final ids = await DatabaseService.instance.getCollectionIdsForText(widget.textId);
    if (mounted) {
      setState(() {
        // Saved first, then user collections
        _collections = [
          ...cols.where((c) => (c['is_default'] as int? ?? 0) == 1),
          ...cols.where((c) => (c['is_default'] as int? ?? 0) == 0),
        ];
        _memberOf = ids;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(int collectionId) async {
    if (_memberOf.contains(collectionId)) {
      await DatabaseService.instance.removeFromCollection(collectionId, widget.textId);
      setState(() => _memberOf.remove(collectionId));
    } else {
      await DatabaseService.instance.addToCollection(collectionId, widget.textId);
      setState(() => _memberOf.add(collectionId));
    }
  }

  Future<void> _createNew() async {
    final result = await showDialog<(String, String?)>(
      context: context,
      builder: (_) => const _CreateCollectionDialog(),
    );
    if (result == null) return;
    final id = await DatabaseService.instance.createCollection(result.$1, description: result.$2);
    await DatabaseService.instance.addToCollection(id, widget.textId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Row(
              children: [
                Text('Save to...',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                  onPressed: _createNew,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ...(_collections.map((col) {
              final id = col['id'] as int;
              final isDefault = (col['is_default'] as int? ?? 0) == 1;
              final inCollection = _memberOf.contains(id);
              return ListTile(
                leading: Icon(
                  inCollection
                      ? (isDefault ? Icons.bookmark : Icons.check_circle)
                      : (isDefault ? Icons.bookmark_border : Icons.circle_outlined),
                  color: inCollection ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
                ),
                title: Text(col['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: (col['description'] as String?)?.isNotEmpty == true
                    ? Text(col['description'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)))
                    : null,
                onTap: () => _toggle(id),
              );
            })),
        ],
      ),
    );
  }
}

class _CreateCollectionDialog extends StatefulWidget {
  const _CreateCollectionDialog();

  @override
  State<_CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<_CreateCollectionDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Morning Practice'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'What is this collection about?',
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
                context, (name, _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim()));
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
