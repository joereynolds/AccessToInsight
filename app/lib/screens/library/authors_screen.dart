import 'package:flutter/material.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../utils.dart';
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
                          final authorShort = a['author_short'] as String? ?? '';
                          final texts = await DatabaseService.instance.getTextsByAuthor(authorShort);
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AuthorWorksScreen(
                                  authorName: name,
                                  authorSlug: authorShort.toLowerCase(),
                                  texts: texts,
                                ),
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

class AuthorWorksScreen extends StatefulWidget {
  final String authorName;
  final String authorSlug;
  final List<TextItem> texts;

  const AuthorWorksScreen({
    super.key,
    required this.authorName,
    required this.authorSlug,
    required this.texts,
  });

  @override
  State<AuthorWorksScreen> createState() => _AuthorWorksScreenState();
}

class _AuthorWorksScreenState extends State<AuthorWorksScreen> {
  String? _bio;

  @override
  void initState() {
    super.initState();
    _loadBio();
  }

  Future<void> _loadBio() async {
    try {
      final row = await DatabaseService.instance.getAuthorBio(widget.authorSlug);
      if (mounted && row != null) {
        setState(() => _bio = row['bio'] as String?);
      }
    } catch (e) {
      debugPrint('getAuthorBio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.authorName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(
              '${widget.texts.length} works',
              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.texts.length + (_bio != null ? 1 : 0),
        separatorBuilder: (_, i) => i == 0 && _bio != null ? const SizedBox.shrink() : const Divider(height: 1),
        itemBuilder: (ctx, i) {
          if (_bio != null && i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                _bio!,
                style: TextStyle(fontSize: 13, height: 1.5, color: cs.onSurface.withValues(alpha: 0.7)),
              ),
            );
          }
          final t = widget.texts[_bio != null ? i - 1 : i];
          final ref = t.suttaRef ?? (t.subtitle != null ? stripHtml(t.subtitle!) : '');
          return ListTile(
            title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: ref.isNotEmpty
                ? Text(ref, style: const TextStyle(fontSize: 12))
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${t.readingTimeMinutes} min',
                  style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45)),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios, size: 13),
              ],
            ),
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
