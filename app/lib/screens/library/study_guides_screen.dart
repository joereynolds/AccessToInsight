import 'package:flutter/material.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../reader/sutta_reader_screen.dart';

class StudyGuidesScreen extends StatefulWidget {
  const StudyGuidesScreen({super.key});

  @override
  State<StudyGuidesScreen> createState() => _StudyGuidesScreenState();
}

class _StudyGuidesScreenState extends State<StudyGuidesScreen> {
  List<TextItem> _guides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    final list = await DatabaseService.instance.getStudyGuides();
    if (mounted) {
      setState(() {
        _guides = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Guides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.collections_bookmark_outlined, color: isDark ? AppColors.saffronMuted : AppColors.terracotta),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Thematic anthologies and structured reading courses suitable for individual reflection and study groups.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkText : AppColors.parchmentText,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._guides.map((g) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: g.summary.isNotEmpty
                            ? Text(g.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))
                            : (g.subtitle != null ? Text(g.subtitle!, style: const TextStyle(fontSize: 12)) : null),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 13),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: g.id)),
                          );
                        },
                      ),
                    )),
              ],
            ),
    );
  }
}
