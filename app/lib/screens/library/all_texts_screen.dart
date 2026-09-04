import 'package:flutter/material.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../reader/sutta_reader_screen.dart';

class AllTextsScreen extends StatefulWidget {
  const AllTextsScreen({super.key});

  @override
  State<AllTextsScreen> createState() => _AllTextsScreenState();
}

class _AllTextsScreenState extends State<AllTextsScreen> {
  List<TextItem> _all = [];
  String _query = '';
  bool _isLoading = true;
  final _searchController = TextEditingController();

  static const _groupOrder = [
    'Dīgha Nikāya',
    'Majjhima Nikāya',
    'Saṃyutta Nikāya',
    'Aṅguttara Nikāya',
    'Dhammapada',
    'Udāna',
    'Sutta Nipāta',
    'Itivuttaka',
    'Theragāthā',
    'Therīgāthā',
    'Khuddaka — Other',
    'Vinaya Piṭaka',
    'Thai Forest Tradition',
    'Thanissaro Bhikkhu',
    'Bhikkhu Bodhi',
    'Nyanaponika Thera',
    'Other Authors',
    'Study Guides',
    'Path to Freedom',
    'General Library',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await DatabaseService.instance.getAllTextsMetadata();
    if (mounted) setState(() { _all = all; _isLoading = false; });
  }

  String _groupFor(TextItem t) {
    final col = t.collection;
    final nik = t.nikayaAbbrev;
    if (nik == 'DN') return 'Dīgha Nikāya';
    if (nik == 'MN') return 'Majjhima Nikāya';
    if (nik == 'SN') return 'Saṃyutta Nikāya';
    if (nik == 'AN') return 'Aṅguttara Nikāya';
    if (col == 'kn/dhp') return 'Dhammapada';
    if (col == 'kn/ud') return 'Udāna';
    if (col == 'kn/snp') return 'Sutta Nipāta';
    if (col == 'kn/iti') return 'Itivuttaka';
    if (col == 'kn/thag') return 'Theragāthā';
    if (col == 'kn/thig') return 'Therīgāthā';
    if (col.startsWith('kn/')) return 'Khuddaka — Other';
    if (nik == 'Vin') return 'Vinaya Piṭaka';
    if (col.startsWith('thai/')) return 'Thai Forest Tradition';
    if (col == 'authors/thanissaro') return 'Thanissaro Bhikkhu';
    if (col == 'authors/bodhi') return 'Bhikkhu Bodhi';
    if (col == 'authors/nyanaponika') return 'Nyanaponika Thera';
    if (col.startsWith('authors/')) return 'Other Authors';
    if (nik == 'Study') return 'Study Guides';
    if (nik == 'PTF') return 'Path to Freedom';
    return 'General Library';
  }

  Map<String, List<TextItem>> _buildGroups(List<TextItem> items) {
    final map = <String, List<TextItem>>{};
    for (final t in items) {
      final g = _groupFor(t);
      map.putIfAbsent(g, () => []).add(t);
    }
    return map;
  }

  List<TextItem> get _filtered {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((t) =>
      t.title.toLowerCase().contains(q) ||
      t.author.toLowerCase().contains(q) ||
      (t.suttaRef?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted;
    final groups = _buildGroups(_filtered);
    final orderedKeys = _groupOrder.where(groups.containsKey).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Pages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: 'Filter by title, author, or reference…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                filled: true,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
              ? Center(
                  child: Text('No results for "$_query"',
                      style: TextStyle(color: mutedColor)),
                )
              : ListView.builder(
                  itemCount: orderedKeys.length,
                  itemBuilder: (ctx, i) {
                    final groupName = orderedKeys[i];
                    final items = groups[groupName]!;
                    final expanded = _query.isNotEmpty;
                    return ExpansionTile(
                      key: PageStorageKey(groupName),
                      initiallyExpanded: expanded,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        groupName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${items.length} ${items.length == 1 ? 'text' : 'texts'}',
                        style: TextStyle(fontSize: 12, color: mutedColor),
                      ),
                      children: items.map((t) => _buildRow(context, t, mutedColor)).toList(),
                    );
                  },
                ),
    );
  }

  Widget _buildRow(BuildContext context, TextItem t, Color mutedColor) {
    final ref = t.suttaRef?.isNotEmpty == true ? t.suttaRef! : null;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: t.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  if (t.author.isNotEmpty || ref != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [if (ref != null) ref, if (t.author.isNotEmpty) t.author].join(' · '),
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 11, color: mutedColor),
          ],
        ),
      ),
    );
  }
}
