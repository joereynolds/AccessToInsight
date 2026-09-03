import 'package:flutter/material.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sutta_card.dart';
import '../reader/sutta_reader_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TextItem> _bookmarks = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final b = await DatabaseService.instance.getBookmarkedTexts();
    final h = await DatabaseService.instance.getRecentReadingHistory(limit: 30);
    if (mounted) {
      setState(() {
        _bookmarks = b;
        _history = h;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved & History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? AppColors.saffronMuted : AppColors.terracotta,
          labelColor: isDark ? AppColors.saffronMuted : AppColors.terracotta,
          tabs: [
            Tab(text: 'Bookmarks (${_bookmarks.length})'),
            Tab(text: 'Reading History (${_history.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Bookmarks Tab
                _bookmarks.isEmpty
                    ? const EmptyState(
                        icon: Icons.bookmark_border,
                        title: 'No Bookmarks Yet',
                        message: 'Tap the bookmark icon in the reading screen to save suttas for quick access.',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: _bookmarks.length,
                          itemBuilder: (ctx, i) => SuttaCard(
                            item: _bookmarks[i],
                            isBookmarked: true,
                          ),
                        ),
                      ),

                // History Tab
                _history.isEmpty
                    ? const EmptyState(
                        icon: Icons.history,
                        title: 'No Reading History',
                        message: 'Discourses and essays you read will automatically appear here with your progress.',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _history.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final h = _history[i];
                            final progress = (h['progress'] as num?)?.toDouble() ?? 0.0;
                            final percent = (progress * 100).toInt();

                            return ListTile(
                              title: Text(
                                h['title'] as String? ?? 'Untitled',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h['sutta_ref'] as String? ?? h['nikaya_abbrev'] as String? ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(3),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 4,
                                            backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                            color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('$percent%', style: const TextStyle(fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 13),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SuttaReaderScreen(textId: h['id'] as String),
                                  ),
                                );
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
