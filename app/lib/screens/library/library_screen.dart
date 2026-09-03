import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../reader/sutta_reader_screen.dart';
import 'authors_screen.dart';
import 'study_guides_screen.dart';
import 'thai_forest_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhamma Library', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Thai Forest Tradition
          _buildFeatureCard(
            context,
            title: 'Thai Forest Tradition',
            subtitle: 'Living practice lineage of Ajaan Mun, Ajaan Chah, Ajaan Lee & more',
            icon: Icons.forest_outlined,
            color: AppColors.forestSage,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ThaiForestScreen()),
              );
            },
          ),
          const SizedBox(height: 14),

          // Section 2: Authors Directory
          _buildFeatureCard(
            context,
            title: 'Authors & Translators',
            subtitle: 'Bhikkhu Bodhi, Thanissaro Bhikkhu, Nyanaponika Thera, Mahasi Sayadaw',
            icon: Icons.people_outline,
            color: AppColors.terracotta,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthorsScreen()),
              );
            },
          ),
          const SizedBox(height: 14),

          // Section 3: Thematic Study Guides
          _buildFeatureCard(
            context,
            title: 'Thematic Study Guides',
            subtitle: 'Curated anthologies: Wings to Awakening, Kamma, Eightfold Path, Mindfulness',
            icon: Icons.menu_book_outlined,
            color: AppColors.saffron,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudyGuidesScreen()),
              );
            },
          ),
          const SizedBox(height: 24),

          // Featured Recommended Modern Essays
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Essential Modern Essays',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkText : AppColors.parchmentText,
              ),
            ),
          ),
          const SizedBox(height: 10),

          _buildEssayTile(
            context,
            title: 'Refuge: An Introduction',
            author: 'Thanissaro Bhikkhu',
            subtitle: 'The historical and psychological context of taking refuge in Buddha, Dhamma, Sangha.',
            path: 'lib/authors/thanissaro/refuge.html',
          ),
          _buildEssayTile(
            context,
            title: 'The Nobility of the Truths',
            author: 'Bhikkhu Bodhi',
            subtitle: 'Why the Four Noble Truths are noble, and how they transform existential suffering.',
            path: 'lib/authors/bodhi/bps-essay_20.html',
          ),
          _buildEssayTile(
            context,
            title: 'The Power of Mindfulness',
            author: 'Nyanaponika Thera',
            subtitle: 'An inquiry into the profound healing and illuminating efficacy of Bare Attention.',
            path: 'lib/authors/nyanaponika/wheel121.html',
          ),
          _buildEssayTile(
            context,
            title: 'The Four Sublime States',
            author: 'Nyanaponika Thera',
            subtitle: 'Practical contemplations on Metta (Love), Karuna (Compassion), Mudita (Joy), and Upekkha (Equanimity).',
            path: 'lib/authors/nyanaponika/wheel006.html',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEssayTile(
    BuildContext context, {
    required String title,
    required String author,
    required String subtitle,
    required String path,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By $author', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
            const SizedBox(height: 2),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 13),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: path)),
          );
        },
      ),
    );
  }
}
