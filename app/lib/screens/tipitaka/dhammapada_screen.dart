import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/dhp_verse.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dhammapada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(
              '26 Vaggas • 423 Verses of Truth',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading && _chapters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chapter Horizontal Selector Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    itemCount: _chapters.length,
                    itemBuilder: (ctx, i) {
                      final c = _chapters[i];
                      final cNum = c['chapter_num'] as int;
                      final isSelected = cNum == _selectedChapter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('Ch. $cNum: ${c['chapter_title']}'),
                          selected: isSelected,
                          selectedColor: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.6),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? AppColors.saffronMuted : AppColors.terracotta)
                                : null,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              _selectChapter(cNum, c['chapter_title'] as String);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Selected Chapter Header Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Chapter $_selectedChapter',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedChapterTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${_verses.length} verses',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),

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
                                            CircleAvatar(
                                              radius: 12,
                                              backgroundColor: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.4),
                                              child: Text(
                                                '${v.verseNum}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Dhp ${v.verseNum}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
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
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            fontFamily: 'serif',
                                            color: isDark ? AppColors.darkText : AppColors.parchmentText,
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
