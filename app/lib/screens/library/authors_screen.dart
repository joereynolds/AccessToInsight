import 'package:flutter/material.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                fillColor: isDark ? AppColors.darkCard : AppColors.parchmentCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
                  ),
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
                          backgroundColor: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.5),
                          child: Text(
                            name.isNotEmpty ? name[0] : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
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
                                builder: (_) => _AuthorWorksScreen(authorName: name, texts: texts),
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

class _AuthorWorksScreen extends StatelessWidget {
  final String authorName;
  final List<TextItem> texts;

  const _AuthorWorksScreen({required this.authorName, required this.texts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authorName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text('${texts.length} works', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
