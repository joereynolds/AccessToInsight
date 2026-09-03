import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/daily_contemplation.dart';
import '../../models/ptf_section.dart';
import '../../providers/app_state_provider.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../reader/sutta_reader_screen.dart';
import '../search/search_screen.dart';
import '../tipitaka/tipitaka_screen.dart';
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

  Color _headingColor(BuildContext context, bool isDark) {
    if (isDark) return AppColors.saffronMuted;
    final style = context.read<AppStateProvider>().settings.themeStyle;
    if (style == AppThemeStyle.insight || style == AppThemeStyle.monochrome) {
      return AppColors.parchmentText;
    }
    return AppColors.terracotta;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = _headingColor(context, isDark);

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
                    color: isDark
                        ? AppColors.saffronMuted
                        : Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Continue Reading',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: headingColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...(_recentHistory.take(3).toList().asMap().entries.map((entry) {
                        final h = entry.value;
                        final progress = (h['progress'] as num?)?.toDouble() ?? 0.0;
                        final percent = (progress * 100).toInt();
                        return InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SuttaReaderScreen(
                                textId: h['id'] as String,
                                initialProgress: progress,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h['title'] as String? ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 5),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 2,
                                          backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$percent%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })),
                    ],

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Curated Starter Tracks
                    StarterTracks(headingColor: headingColor),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Gradual Training (Anupubbi-katha)
                    if (_ptfSections.isNotEmpty)
                      GradualPathPreview(sections: _ptfSections, headingColor: headingColor),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Browse
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Browse',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: headingColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildBrowseRow(context, 'Tipiṭaka', () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TipitakaScreen()),
                      );
                    }, isDark),
                    _buildBrowseRow(context, 'Thai Forest Tradition', () => widget.onTabChange?.call(1), isDark),
                    _buildBrowseRow(context, 'Similes & Parables', () => widget.onTabChange?.call(2), isDark),
                    _buildBrowseRow(context, 'Pāli Glossary', () => widget.onTabChange?.call(2), isDark),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBrowseRow(BuildContext context, String title, VoidCallback? onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
            Icon(
              Icons.arrow_forward_ios,
              size: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}
