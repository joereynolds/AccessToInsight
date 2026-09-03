import 'package:flutter/material.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sutta_card.dart';

class NikayaListScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String collectionCode;
  final String nikayaAbbrev;

  const NikayaListScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.collectionCode,
    required this.nikayaAbbrev,
  });

  @override
  State<NikayaListScreen> createState() => _NikayaListScreenState();
}

class _NikayaListScreenState extends State<NikayaListScreen> {
  List<TextItem> _allItems = [];
  List<TextItem> _filteredItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTexts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTexts() async {
    setState(() => _isLoading = true);
    List<TextItem> items = [];
    if (widget.collectionCode.isNotEmpty) {
      items = await DatabaseService.instance.getTextsByCollection(widget.collectionCode, limit: 300);
    }
    if (items.isEmpty && widget.nikayaAbbrev.isNotEmpty) {
      items = await DatabaseService.instance.getTextsByNikaya(widget.nikayaAbbrev, limit: 300);
    }

    if (mounted) {
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredItems = _allItems);
    } else {
      setState(() {
        _filteredItems = _allItems.where((item) {
          final titleMatch = item.title.toLowerCase().contains(query);
          final subtitleMatch = item.subtitle?.toLowerCase().contains(query) ?? false;
          final refMatch = item.suttaRef?.toLowerCase().contains(query) ?? false;
          final ptsMatch = item.ptsId?.toLowerCase().contains(query) ?? false;
          final authorMatch = item.author.toLowerCase().contains(query);
          return titleMatch || subtitleMatch || refMatch || ptsMatch || authorMatch;
        }).toList();
      });
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
            Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(
              '${widget.subtitle} (${_allItems.length} suttas)',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter / Search bar within this Nikaya
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Filter by sutta name, number, or topic...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.parchmentCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
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
                : _filteredItems.isEmpty
                    ? EmptyState(
                        title: 'No Discourses Found',
                        message: _searchController.text.isEmpty
                            ? 'No texts available for this collection.'
                            : 'No suttas matched "${_searchController.text}".',
                      )
                    : ListView.builder(
                        itemCount: _filteredItems.length,
                        itemBuilder: (ctx, i) => SuttaCard(item: _filteredItems[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
