import 'package:flutter/material.dart';
import '../../models/daily_contemplation.dart';
import '../../models/ptf_section.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../reader/sutta_reader_screen.dart';
import '../search/search_screen.dart';
import 'daily_contemplation_card.dart';
import 'gradual_path_preview.dart';
import 'starter_tracks.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyContemplation? _dailyContemplation;
  List<PtfSection> _ptfSections = [];
  List<Map<String, dynamic>> _recentHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final daily = await DatabaseService.instance.getDailyContemplation();
    final ptf = await DatabaseService.instance.getPtfSections();
    final history = await DatabaseService.instance.getRecentReadingHistory(limit: 5);

    if (mounted) {
      setState(() {
        _dailyContemplation = daily;
        _ptfSections = ptf;
        _recentHistory = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _openRandomSutta() async {
    final randomItem = await DatabaseService.instance.getRandomText(type: 'sutta');
    if (randomItem != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SuttaReaderScreen(textId: randomItem.id),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecting random discourse...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Access to Insight',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PĀLI CANON',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Readings in Theravada Buddhism',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Random Sutta (Surprise Me)',
            child: IconButton(
              icon: const Icon(Icons.casino_outlined),
              onPressed: _openRandomSutta,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Contemplation Card
                    DailyContemplationCard(contemplation: _dailyContemplation),

                    // Recent Reading (if any)
                    if (_recentHistory.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Continue Reading',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkText : AppColors.parchmentText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: _recentHistory.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (ctx, i) {
                            final h = _recentHistory[i];
                            final progress = (h['progress'] as num?)?.toDouble() ?? 0.0;
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SuttaReaderScreen(textId: h['id'] as String),
                                  ),
                                );
                              },
                              child: Container(
                                width: 220,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          h['sutta_ref'] ?? h['nikaya_abbrev'] ?? 'Discourse',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          h['title'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 4,
                                        backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                        color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
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

                    const SizedBox(height: 20),

                    // Curated Starter Tracks
                    const StarterTracks(),

                    const SizedBox(height: 24),

                    // Gradual Training (Anupubbi-katha)
                    if (_ptfSections.isNotEmpty)
                      GradualPathPreview(sections: _ptfSections),

                    const SizedBox(height: 24),

                    // Quick Canonical Jump Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Pāli Canon Explorations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.darkText : AppColors.parchmentText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCanonCard(
                              context,
                              title: 'Tipitaka',
                              subtitle: 'The Three Baskets',
                              icon: Icons.account_tree_outlined,
                              onTap: () => widget.onTabChange?.call(1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCanonCard(
                              context,
                              title: 'Thai Forest',
                              subtitle: 'Living Masters',
                              icon: Icons.forest_outlined,
                              onTap: () => widget.onTabChange?.call(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCanonCard(
                              context,
                              title: 'Similes & Parables',
                              subtitle: '330+ Imagery of Truth',
                              icon: Icons.lightbulb_outline,
                              onTap: () => widget.onTabChange?.call(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCanonCard(
                              context,
                              title: 'Pāli Glossary',
                              subtitle: '200+ Core Terms',
                              icon: Icons.translate,
                              onTap: () => widget.onTabChange?.call(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCanonCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
