import 'package:flutter/material.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../reader/sutta_reader_screen.dart';

class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  List<Map<String, dynamic>> _authors = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAuthors();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthors() async {
    final list = await DatabaseService.instance.getAuthorsDirectory();
    if (mounted) {
      setState(() {
        _authors = list;
        _filtered = list;
        _isLoading = false;
      });
    }
  }

  void _filter() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = _authors);
    } else {
      setState(() {
        _filtered = _authors.where((a) {
          final name = (a['author'] as String).toLowerCase();
          return name.contains(q);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authors & Translators', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search authors...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final a = _filtered[i];
                      final name = a['author'] as String;
                      final count = a['text_count'] as int;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.primary.withValues(alpha: 0.12),
                          child: Text(
                            name.isNotEmpty ? name[0] : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('$count translations & essays'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 13),
                        onTap: () async {
                          final texts = await DatabaseService.instance.getTextsByAuthor(name);
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AuthorWorksScreen(authorName: name, texts: texts),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AuthorWorksScreen extends StatelessWidget {
  final String authorName;
  final List<TextItem> texts;

  const AuthorWorksScreen({super.key, required this.authorName, required this.texts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authorName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(
              '${texts.length} works',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: texts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final t = texts[i];
          return ListTile(
            title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              t.suttaRef ?? t.subtitle ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 13),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: t.id)),
              );
            },
          );
        },
      ),
    );
  }
}
