import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../../models/text_item.dart';
import '../../providers/app_state_provider.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pali_badge.dart';
import 'footnotes_sheet.dart';
import 'reader_settings_sheet.dart';

class SuttaReaderScreen extends StatefulWidget {
  final String textId;

  const SuttaReaderScreen({super.key, required this.textId});

  @override
  State<SuttaReaderScreen> createState() => _SuttaReaderScreenState();
}

class _SuttaReaderScreenState extends State<SuttaReaderScreen> {
  TextItem? _item;
  bool _isLoading = true;
  bool _isBookmarked = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadText();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _item == null) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll > 0) {
      final progress = (_scrollController.position.pixels / maxScroll).clamp(0.0, 1.0);
      DatabaseService.instance.updateReadingProgress(_item!.id, progress);
    }
  }

  Future<void> _loadText() async {
    setState(() => _isLoading = true);
    TextItem? item = await DatabaseService.instance.getTextById(widget.textId);
    
    // If not found, try fuzzy match on filename or suffix
    if (item == null) {
      final fileName = p.basename(widget.textId);
      final list = await DatabaseService.instance.searchTexts(fileName, limit: 1);
      if (list.isNotEmpty) {
        item = list.first;
      }
    }

    if (item != null) {
      final bookmarked = await DatabaseService.instance.isBookmarked(item.id);
      if (mounted) {
        setState(() {
          _item = item;
          _isBookmarked = bookmarked;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_item == null) return;
    final newStatus = await DatabaseService.instance.toggleBookmark(_item!.id);
    setState(() => _isBookmarked = newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus ? 'Added to Bookmarks' : 'Removed from Bookmarks'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareText() {
    if (_item == null) return;
    final shareContent = '''
"${_item!.title}" (${_item!.displayReference})
Translated by ${_item!.author}

${_item!.summary.isNotEmpty ? 'Summary: ' + _item!.summary + '\n\n' : ''}Access to Insight: Readings in Theravada Buddhism
https://accesstoinsight.org/${_item!.path}
''';
    Clipboard.setData(ClipboardData(text: shareContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Discourse citation and link copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _handleLinkTap(String url) {
    if (url.startsWith('#')) {
      // Footnote anchor click e.g. #fn-1, #fnt-1
      final match = RegExp(r'(\d+)').firstMatch(url);
      if (match != null) {
        final noteNum = match.group(1)!;
        final noteText = _item?.footnotes[noteNum];
        if (noteText != null && noteText.isNotEmpty) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (ctx) => FootnotesSheet(noteNumber: noteNum, noteText: noteText),
          );
          return true;
        }
      }
      return true;
    }

    // Relative internal sutta link e.g. ../../tipitaka/mn/mn.10.than.html
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final currentDir = p.dirname(_item?.path ?? '');
      final cleanUrl = url.split('#')[0];
      final targetPath = p.normalize(p.join(currentDir, cleanUrl));

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => SuttaReaderScreen(textId: targetPath),
        ),
      );
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final settings = appState.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Text Not Found')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Discourse Not Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unable to locate text with ID: ${widget.textId}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final item = _item!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              item.displayReference,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.saffron : null,
            ),
            tooltip: 'Bookmark',
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: _shareText,
          ),
          IconButton(
            icon: const Icon(Icons.text_format),
            tooltip: 'Display Settings',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) => const ReaderSettingsSheet(),
              );
            },
          ),
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meta Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PaliBadge(label: item.displayReference),
                        const SizedBox(width: 8),
                        if (item.ptsId != null && item.ptsId!.isNotEmpty)
                          Text(
                            'PTS: ${item.ptsId!}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          '${item.wordCount} words • ${item.readingTimeMinutes} min',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: settings.fontFamily,
                        height: 1.25,
                      ),
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.translate,
                          size: 14,
                          color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Translated from Pali by ${item.author.isNotEmpty ? item.author : "Traditional"}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Prominent Summary Box (Makes ancient text immediately digestible!)
              if (item.summary.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 16,
                            color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Overview & Spiritual Context',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.summary,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? AppColors.darkText : AppColors.parchmentText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Main Body Content via HtmlWidget
              HtmlWidget(
                item.contentHtml,
                onTapUrl: (url) => _handleLinkTap(url),
                textStyle: TextStyle(
                  fontSize: settings.fontSize,
                  fontFamily: settings.fontFamily,
                  height: settings.lineHeight,
                  color: isDark ? AppColors.darkText : AppColors.parchmentText,
                ),
                customStylesBuilder: (element) {
                  if (element.className == 'freeverse') {
                    return {
                      'margin-left': '18px',
                      'font-style': 'italic',
                      'padding': '10px 14px',
                      'border-left': '3px solid #D97706',
                    };
                  }
                  if (element.className == 'chapter') {
                    return {'margin-bottom': '16px'};
                  }
                  if (element.localName == 'h4' || element.localName == 'h3') {
                    return {
                      'font-weight': 'bold',
                      'margin-top': '20px',
                      'margin-bottom': '8px',
                      'color': isDark ? '#F59E0B' : '#9A3412',
                    };
                  }
                  if (element.className == 'noteTag') {
                    return {
                      'font-size': '12px',
                      'font-weight': 'bold',
                      'color': isDark ? '#F59E0B' : '#9A3412',
                      'text-decoration': 'none',
                    };
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Footer License & Provenance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attribution & License',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Access to Insight (BCBS Edition). Transcribed from original files by ${item.author}. ${item.license ?? "Licensed under Creative Commons"}.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
