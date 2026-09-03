import 'package:flutter/material.dart';
import '../../models/text_item.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../reader/sutta_reader_screen.dart';

class ThaiForestScreen extends StatelessWidget {
  const ThaiForestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final masters = [
      _MasterInfo(
        slug: 'chah',
        name: 'Ajaan Chah',
        paliTitle: 'Phra Bodhinyana Thera',
        years: '1918–1992',
        bio: 'Famed for his earthy, humorous, and direct similes pointing immediately to the nature of the mind and letting go.',
        collection: 'thai/chah',
        icon: Icons.nature_people_outlined,
      ),
      _MasterInfo(
        slug: 'lee',
        name: 'Ajaan Lee Dhammadharo',
        paliTitle: 'Phra Suddhidhammaransi',
        years: '1907–1961',
        bio: 'Master of breath meditation (ānāpānasati), jhāna concentration, and channeling breath energy through the body.',
        collection: 'thai/lee',
        icon: Icons.air_outlined,
      ),
      _MasterInfo(
        slug: 'boowa',
        name: 'Ajaan Mahā Boowa',
        paliTitle: 'Phra Dhamma Visuddhi Mongkol',
        years: '1913–2011',
        bio: 'Renowned for his uncompromising ascetic vigor, profound talks on the citta (mind), and the biography of Ajaan Mun.',
        collection: 'thai/boowa',
        icon: Icons.shield_outlined,
      ),
      _MasterInfo(
        slug: 'mun',
        name: 'Ajaan Mun Bhūridatta',
        paliTitle: 'Phra Kru Vinayadhara',
        years: '1870–1949',
        bio: 'The towering founding father of the modern Thai Forest meditation lineage who revived forest ascetic wandering (dhutaṅga).',
        collection: 'thai/mun',
        icon: Icons.terrain_outlined,
      ),
      _MasterInfo(
        slug: 'kee',
        name: 'Upāsikā Kee Nanayon',
        paliTitle: 'K. Khao-suan-luang',
        years: '1901–1978',
        bio: 'One of the foremost female lay practitioners of Thailand, famed for penetrative mindfulness instructions and self-honesty.',
        collection: 'thai/kee',
        icon: Icons.spa_outlined,
      ),
      _MasterInfo(
        slug: 'fuang',
        name: 'Ajaan Fuang Jotiko',
        paliTitle: 'Wat Asokaram & Dhammasathit',
        years: '1915–1986',
        bio: 'Primary disciple of Ajaan Lee and teacher of Thanissaro Bhikkhu; master of practical, down-to-earth Dhamma wisdom.',
        collection: 'thai/fuang',
        icon: Icons.psychology_outlined,
      ),
      _MasterInfo(
        slug: 'dune',
        name: 'Ajaan Dune Atulo',
        paliTitle: 'Phra Rajavudhācariya',
        years: '1888–1983',
        bio: 'Senior disciple of Ajaan Mun; celebrated for his concise, laser-sharp maxims on the mind stopping thought in its tracks.',
        collection: 'thai/dune',
        icon: Icons.lightbulb_outline,
      ),
      _MasterInfo(
        slug: 'thate',
        name: 'Ajaan Thate Desaransi',
        paliTitle: 'Phra Nirodharansi',
        years: '1902–1994',
        bio: 'Long-standing forest meditation elder whose clear manuals on "Buddho" meditation guided thousands of monks and lay meditators.',
        collection: 'thai/thate',
        icon: Icons.wb_sunny_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thai Forest Tradition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(
              'The Kammaṭṭhāna Lineage',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
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
                    Icon(
                      Icons.forest,
                      color: isDark ? AppColors.saffronMuted : AppColors.forestSage,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'The Living Forest Tradition',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.saffronMuted : AppColors.forestSage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Founded in the deep jungles of northeast Thailand by Ajaan Mun, the Forest Tradition returns to the simplicity, wilderness austerity, and practical meditation of the Buddha’s original disciples.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: isDark ? AppColors.darkText : AppColors.parchmentText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...masters.map((m) => _buildMasterCard(context, m)),
        ],
      ),
    );
  }

  Widget _buildMasterCard(BuildContext context, _MasterInfo m) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final texts = await DatabaseService.instance.getTextsByCollection(m.collection);
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _MasterWorksScreen(master: m, texts: texts),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.5),
                    child: Icon(m.icon, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${m.paliTitle} (${m.years})',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                m.bio,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? AppColors.darkText : AppColors.parchmentText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasterWorksScreen extends StatelessWidget {
  final _MasterInfo master;
  final List<TextItem> texts;

  const _MasterWorksScreen({required this.master, required this.texts});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(master.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(
              '${texts.length} talks & books',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
              ),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: texts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final t = texts[i];
          return ListTile(
            title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: t.summary.isNotEmpty
                ? Text(t.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))
                : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 13),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: t.id)),
              );
            },
          );
        },
      ),
    );
  }
}

class _MasterInfo {
  final String slug;
  final String name;
  final String paliTitle;
  final String years;
  final String bio;
  final String collection;
  final IconData icon;

  _MasterInfo({
    required this.slug,
    required this.name,
    required this.paliTitle,
    required this.years,
    required this.bio,
    required this.collection,
    required this.icon,
  });
}
