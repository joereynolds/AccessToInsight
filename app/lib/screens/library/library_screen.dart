import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../gradual_path/gradual_path_screen.dart';
import '../reader/sutta_reader_screen.dart';
import '../tipitaka/dhammapada_screen.dart';
import '../tipitaka/tipitaka_screen.dart';
import 'all_texts_screen.dart';
import 'authors_screen.dart';
import 'study_guides_screen.dart';
import 'thai_forest_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted;
    final headingColor = isDark ? AppColors.darkText : AppColors.parchmentText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhamma Library', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _sectionHeader('Collections', headingColor),
          const SizedBox(height: 8),
          _buildCollectionRow(context, isDark,
            icon: Icons.account_balance_outlined,
            title: 'Tipiṭaka',
            subtitle: 'The Pāli Canon — Sutta, Vinaya & Abhidhamma Piṭakas',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TipitakaScreen())),
          ),
          _buildCollectionRow(context, isDark,
            icon: Icons.forest_outlined,
            title: 'Thai Forest Tradition',
            subtitle: 'Ajaan Mun, Ajaan Chah, Ajaan Lee, Ajaan Fuang & more',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThaiForestScreen())),
          ),
          _buildCollectionRow(context, isDark,
            icon: Icons.auto_stories_outlined,
            title: 'Dhammapada',
            subtitle: '423 verses on the path — the most widely read Pāli text',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DhammapadaScreen())),
          ),
          _buildCollectionRow(context, isDark,
            icon: Icons.route_outlined,
            title: 'A Path to Freedom',
            subtitle: 'Gradual training from generosity through to liberation',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GradualPathScreen())),
          ),
          _buildCollectionRow(context, isDark,
            icon: Icons.menu_book_outlined,
            title: 'Thematic Study Guides',
            subtitle: 'Wings to Awakening, Kamma, Eightfold Path, Mindfulness',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudyGuidesScreen())),
          ),
          _buildCollectionRow(context, isDark,
            icon: Icons.people_outline,
            title: 'Authors & Translators',
            subtitle: 'Bhikkhu Bodhi, Thanissaro Bhikkhu, Nyanaponika Thera & more',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthorsScreen())),
          ),
          _buildCollectionRow(context, isDark,
            icon: Icons.help_outline,
            title: 'Frequently Asked Questions',
            subtitle: 'About Access to Insight, the texts, and how to use the site',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: 'faq.html'))),
          ),
          _buildCollectionRow(context, isDark,
            icon: Icons.list_alt_outlined,
            title: 'All Pages',
            subtitle: 'Browse all 1,800+ texts grouped by collection',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllTextsScreen())),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),

          _sectionHeader('Foundational Teachings', headingColor),
          const SizedBox(height: 4),
          _subHeader('The Buddha\'s core teachings on suffering and liberation', mutedColor),
          const SizedBox(height: 8),
          _buildEssayTile(context, isDark,
            title: 'The Four Noble Truths',
            author: 'Thanissaro Bhikkhu',
            path: 'lib/study/truths.html',
          ),
          _buildEssayTile(context, isDark,
            title: 'The Nobility of the Truths',
            author: 'Bhikkhu Bodhi',
            path: 'lib/authors/bodhi/bps-essay_20.html',
          ),
          _buildEssayTile(context, isDark,
            title: 'Kamma: The Principle of Action',
            author: 'Thanissaro Bhikkhu',
            path: 'lib/study/kamma.html',
          ),
          _buildEssayTile(context, isDark,
            title: 'Wings to Awakening',
            author: 'Thanissaro Bhikkhu',
            path: 'lib/authors/thanissaro/wings/index.html',
          ),

          const SizedBox(height: 20),
          _sectionHeader('Meditation & Mind', headingColor),
          const SizedBox(height: 4),
          _subHeader('Practical guides to practice and contemplation', mutedColor),
          const SizedBox(height: 8),
          _buildEssayTile(context, isDark,
            title: 'The Power of Mindfulness',
            author: 'Nyanaponika Thera',
            path: 'lib/authors/nyanaponika/wheel121.html',
          ),
          _buildEssayTile(context, isDark,
            title: 'The Four Sublime States',
            author: 'Nyanaponika Thera',
            path: 'lib/authors/nyanaponika/wheel006.html',
          ),
          _buildEssayTile(context, isDark,
            title: 'Meditations',
            author: 'Thanissaro Bhikkhu',
            path: 'lib/authors/thanissaro/meditations.html',
          ),

          const SizedBox(height: 20),
          _sectionHeader('Taking Refuge', headingColor),
          const SizedBox(height: 4),
          _subHeader('Orientation in the Buddha, Dhamma, and Sangha', mutedColor),
          const SizedBox(height: 8),
          _buildEssayTile(context, isDark,
            title: 'Refuge: An Introduction',
            author: 'Thanissaro Bhikkhu',
            path: 'lib/authors/thanissaro/refuge.html',
          ),
          _buildEssayTile(context, isDark,
            title: 'A Gift of Dhamma',
            author: 'Ajahn Chah',
            path: 'lib/thai/chah/giftofdhamma.html',
          ),
          _buildEssayTile(context, isDark,
            title: 'The Quest for Meaning',
            author: 'Bhikkhu Bodhi',
            path: 'lib/authors/bodhi/bps-essay_14.html',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _subHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: TextStyle(fontSize: 13, color: color, height: 1.3)),
    );
  }

  Widget _buildCollectionRow(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted;
    final iconColor = isDark ? AppColors.darkTextMuted : Colors.grey.shade500;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: mutedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildEssayTile(
    BuildContext context,
    bool isDark, {
    required String title,
    required String author,
    required String path,
  }) {
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: path)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(author, style: TextStyle(fontSize: 12, color: mutedColor)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: mutedColor),
          ],
        ),
      ),
    );
  }
}
