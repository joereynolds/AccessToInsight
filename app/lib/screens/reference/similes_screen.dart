import 'package:flutter/material.dart';
import '../../models/simile_item.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/simile_card.dart';

class SimilesScreen extends StatefulWidget {
  const SimilesScreen({super.key});

  @override
  State<SimilesScreen> createState() => _SimilesScreenState();
}

class _SimilesScreenState extends State<SimilesScreen> {
  List<SimileItem> _items = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSimiles();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSimiles({String? query}) async {
    setState(() => _isLoading = true);
    final list = await DatabaseService.instance.getSimiles(query: query);
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    _loadSimiles(query: _searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search similes (e.g. raft, arrow, acrobat, city)...',
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
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? EmptyState(
                      title: 'No Similes Found',
                      message: 'No parables or similes matched "${_searchController.text}".',
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (ctx, i) => SimileCard(item: _items[i]),
                    ),
        ),
      ],
    );
  }
}
