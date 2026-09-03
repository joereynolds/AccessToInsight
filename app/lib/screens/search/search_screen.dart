import 'package:flutter/material.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sutta_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<TextItem> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  final List<String> _suggestions = [
    'First Sermon',
    'Loving-Kindness',
    'Anapanasati',
    'Satipatthana',
    'Not-Self',
    'Four Noble Truths',
    'Simile of the Raft',
    'Ajahn Chah',
    'Sigalovada',
    'Kevatta',
    'Kalama Sutta',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final res = await DatabaseService.instance.searchTexts(clean, limit: 60);

    if (mounted) {
      setState(() {
        _results = res;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search 1,800+ suttas, titles, or concepts...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
            ),
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _results = [];
                  _hasSearched = false;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_controller.text),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick suggestion chips
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final s = _suggestions[i];
                return ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  backgroundColor: isDark ? AppColors.darkCard : AppColors.parchmentCard,
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
                  ),
                  onPressed: () {
                    _controller.text = s;
                    _performSearch(s);
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? const EmptyState(
                        icon: Icons.search,
                        title: 'Search the Pāli Canon',
                        message: 'Type any sutta name (e.g. "Kevatta"), citation (e.g. "MN 10"), author, or key teaching.',
                      )
                    : _results.isEmpty
                        ? EmptyState(
                            icon: Icons.search_off,
                            title: 'No Results Found',
                            message: 'No teachings matched "${_controller.text}". Try broader keywords or canonical titles.',
                          )
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (ctx, i) => SuttaCard(item: _results[i]),
                          ),
          ),
        ],
      ),
    );
  }
}
