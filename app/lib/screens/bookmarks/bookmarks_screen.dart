import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../widgets/add_to_collection_sheet.dart';
import '../reader/sutta_reader_screen.dart';
import 'collections_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final h = await DatabaseService.instance.getRecentReadingHistory(limit: 50);
    if (mounted) {
      setState(() {
        _history = h;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          tabs: [
            const Tab(text: 'Collections'),
            Tab(text: 'History (${_history.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Collections tab (includes Saved)
          const CollectionsScreen(),

          // History tab
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _history.isEmpty
                  ? const _EmptyHistory()
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final h = _history[i];
                          final progress = (h['progress'] as num?)?.toDouble() ?? 0.0;
                          final percent = (progress * 100).toInt();
                          final textId = h['text_id'] as String;

                          return Dismissible(
                            key: ValueKey(textId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red.shade700,
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            onDismissed: (_) async {
                              setState(() => _history.removeAt(i));
                              await DatabaseService.instance.deleteHistoryEntry(textId);
                            },
                            child: ListTile(
                              title: Text(
                                h['title'] as String? ?? 'Untitled',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h['sutta_ref'] as String? ?? h['nikaya_abbrev'] as String? ?? '',
                                    style: TextStyle(fontSize: 12, color: cs.primary),
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
                                            backgroundColor:
                                                isDark ? Colors.white12 : Colors.black12,
                                            color: cs.primary,
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
                              onLongPress: () => showAddToCollectionSheet(context, textId),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SuttaReaderScreen(
                                      textId: textId,
                                      initialProgress: progress,
                                    ),
                                  ),
                                );
                              },
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: cs.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            Text('No reading history',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.55))),
            const SizedBox(height: 8),
            Text(
              'Suttas you read will appear here with your progress.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ),
    );
  }
}
