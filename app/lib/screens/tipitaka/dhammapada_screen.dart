import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/dhp_verse.dart';
import '../../services/database_service.dart';
import '../../widgets/empty_state.dart';

class DhammapadaScreen extends StatefulWidget {
  const DhammapadaScreen({super.key});

  @override
  State<DhammapadaScreen> createState() => _DhammapadaScreenState();
}

class _DhammapadaScreenState extends State<DhammapadaScreen> {
  List<Map<String, dynamic>> _chapters = [];
  int _selectedChapter = 1;
  String _selectedChapterTitle = 'Yamakavagga: Pairs';
  List<DhpVerse> _verses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final chaps = await DatabaseService.instance.getDhammapadaChapters();
    if (chaps.isNotEmpty) {
      final first = chaps.first;
      final verses = await DatabaseService.instance.getDhammapadaVerses(first['chapter_num'] as int);
      if (mounted) {
        setState(() {
          _chapters = chaps;
          _selectedChapter = first['chapter_num'] as int;
          _selectedChapterTitle = first['chapter_title'] as String;
          _verses = verses;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectChapter(int chapNum, String title) async {
    setState(() {
      _selectedChapter = chapNum;
      _selectedChapterTitle = title;
      _isLoading = true;
    });
    final verses = await DatabaseService.instance.getDhammapadaVerses(chapNum);
    if (mounted) {
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
    }
  }

  void _shareVerse(DhpVerse v) {
    final text = '''
Dhammapada Verse ${v.verseNum}
(${v.chapterTitle})

${v.verseText}

— Translated by ${v.translator}
Access to Insight
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied Dhammapada verse ${v.verseNum} to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dhammapada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(
              '26 Vaggas • 423 Verses of Truth',
              style: TextStyle(fontSize: 12, color: cs.primary),
            ),
          ],
        ),
      ),
      body: _isLoading && _chapters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chapter picker row
                Material(
                  color: cs.surfaceContainerHighest,
                  child: PopupMenuButton<int>(
                    onSelected: (cNum) {
                      final c = _chapters.firstWhere((c) => c['chapter_num'] == cNum);
                      _selectChapter(cNum, c['chapter_title'] as String);
                    },
                    itemBuilder: (_) => _chapters.map((c) {
                      final cNum = c['chapter_num'] as int;
                      final isSelected = cNum == _selectedChapter;
                      return PopupMenuItem<int>(
                        value: cNum,
                        child: Text(
                          'Ch. $cNum: ${c['chapter_title']}',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                            color: isSelected ? cs.primary : null,
                          ),
                        ),
                      );
                    }).toList(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            'Chapter $_selectedChapter',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.arrow_drop_down, size: 18, color: cs.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedChapterTitle,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${_verses.length} verses',
                            style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: cs.outlineVariant),

                // Verses List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _verses.isEmpty
                          ? const EmptyState(
                              title: 'No Verses Found',
                              message: 'Select a chapter above to view verses.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: _verses.length,
                              itemBuilder: (ctx, i) {
                                final v = _verses[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${v.verseNum}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: cs.primary,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.copy_outlined, size: 16),
                                              tooltip: 'Copy Verse',
                                              onPressed: () => _shareVerse(v),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          v.verseText,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            fontFamily: 'serif',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}
