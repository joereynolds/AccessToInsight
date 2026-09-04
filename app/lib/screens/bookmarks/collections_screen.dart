import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../widgets/empty_state.dart';
import '../reader/sutta_reader_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  List<Map<String, dynamic>> _collections = [];
  final Map<int, List<TextItem>> _items = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cols = await DatabaseService.instance.getCollections();
    final Map<int, List<TextItem>> items = {};
    for (final c in cols) {
      items[c['id'] as int] = await DatabaseService.instance.getCollectionItems(c['id'] as int);
    }
    if (!mounted) return;
    setState(() {
      // Saved always first, then alphabetical
      _collections = [
        ...cols.where((c) => (c['is_default'] as int? ?? 0) == 1),
        ...cols.where((c) => (c['is_default'] as int? ?? 0) == 0),
      ];
      _items.clear();
      _items.addAll(items);
      _isLoading = false;
    });
  }

  Future<void> _createCollection() async {
    final result = await _showEditDialog(context);
    if (!mounted || result == null) return;
    await DatabaseService.instance.createCollection(result.$1, description: result.$2);
    if (mounted) await _load();
  }

  Future<void> _editCollection(Map<String, dynamic> col) async {
    final result = await _showEditDialog(
      context,
      initialName: col['name'] as String,
      initialDesc: col['description'] as String?,
    );
    if (!mounted || result == null) return;
    await DatabaseService.instance.updateCollection(col['id'] as int, result.$1, description: result.$2);
    if (mounted) await _load();
  }

  void _shareCollection(String name, List<TextItem> texts) {
    if (texts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection is empty — nothing to share.')),
      );
      return;
    }
    final buf = StringBuffer();
    buf.writeln(name);
    buf.writeln();
    for (var i = 0; i < texts.length; i++) {
      final t = texts[i];
      final ref = t.suttaRef ?? t.nikayaAbbrev;
      buf.writeln('${i + 1}. ${t.title}${ref.isNotEmpty ? ' ($ref)' : ''}');
      buf.writeln('   https://accesstoinsight.org/${t.path}');
      buf.writeln();
    }
    buf.write('Shared via Access to Insight');
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${texts.length} links copied to clipboard')),
    );
  }

  Future<void> _deleteCollection(Map<String, dynamic> col) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Delete "${col['name']}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await DatabaseService.instance.deleteCollection(col['id'] as int);
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final hasUserCollections = _collections.any((c) => (c['is_default'] as int? ?? 0) == 0);
    final savedCol = _collections.where((c) => (c['is_default'] as int? ?? 0) == 1).firstOrNull;
    final savedTexts = savedCol != null ? (_items[savedCol['id'] as int] ?? []) : <TextItem>[];
    final savedIsEmpty = savedTexts.isEmpty;

    if (_collections.isEmpty || (savedCol == null && !hasUserCollections)) {
      return EmptyState(
        icon: Icons.bookmark_border,
        title: 'Nothing saved yet',
        message: 'Tap the bookmark icon while reading to save suttas to your Saved list.',
        action: FilledButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Collection'),
          onPressed: _createCollection,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // --- Saved (default) collection ---
          if (savedCol != null) ...[
            _SectionHeader(
              icon: Icons.bookmark,
              title: 'Saved',
              count: savedTexts.length,
              onShare: () => _shareCollection('Saved', savedTexts),
              menu: null,
            ),
            if (savedIsEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Tap the bookmark icon while reading to save suttas here.',
                  style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.4)),
                ),
              )
            else
              ..._buildTextRows(context, savedTexts, cs),
            const Divider(height: 1),
          ],

          // --- User collections ---
          ..._collections
              .where((c) => (c['is_default'] as int? ?? 0) == 0)
              .map((col) {
            final id = col['id'] as int;
            final texts = _items[id] ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  icon: Icons.playlist_play,
                  title: col['name'] as String,
                  subtitle: col['description'] as String?,
                  count: texts.length,
                  onShare: () => _shareCollection(col['name'] as String, texts),
                  menu: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
                    onSelected: (v) {
                      if (v == 'edit') _editCollection(col);
                      if (v == 'delete') _deleteCollection(col);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
                if (texts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      'No articles yet — tap + while reading to add some.',
                      style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.4)),
                    ),
                  )
                else
                  ..._buildTextRows(context, texts, cs),
                const Divider(height: 1),
              ],
            );
          }),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('New Collection'),
              onPressed: _createCollection,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTextRows(BuildContext context, List<TextItem> texts, ColorScheme cs) {
    return texts.map((t) => InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: t.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  if (t.author.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(t.author,
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 11, color: cs.onSurface.withValues(alpha: 0.35)),
          ],
        ),
      ),
    )).toList();
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final int count;
  final VoidCallback? onShare;
  final Widget? menu;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.count,
    this.onShare,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface)),
                    const SizedBox(width: 6),
                    Text('$count',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface.withValues(alpha: 0.4))),
                  ],
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!,
                      style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.55),
                          height: 1.35)),
                ],
              ],
            ),
          ),
          if (onShare != null)
            IconButton(
              icon: Icon(Icons.share_outlined, size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
              tooltip: 'Share collection',
              onPressed: onShare,
            ),
          if (menu != null) menu!,
        ],
      ),
    );
  }
}

Future<(String, String?)?> _showEditDialog(
  BuildContext context, {
  String? initialName,
  String? initialDesc,
}) {
  return showDialog<(String, String?)>(
    context: context,
    builder: (ctx) => _CollectionEditDialog(
      initialName: initialName,
      initialDesc: initialDesc,
    ),
  );
}

class _CollectionEditDialog extends StatefulWidget {
  final String? initialName;
  final String? initialDesc;

  const _CollectionEditDialog({this.initialName, this.initialDesc});

  @override
  State<_CollectionEditDialog> createState() => _CollectionEditDialogState();
}

class _CollectionEditDialogState extends State<_CollectionEditDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _descCtrl = TextEditingController(text: widget.initialDesc);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'New Collection' : 'Edit Collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name'),
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;
            final desc = _descCtrl.text.trim();
            Navigator.of(context).pop((name, desc.isEmpty ? null : desc));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
