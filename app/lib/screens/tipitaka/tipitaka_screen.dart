import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../reader/sutta_reader_screen.dart';
import 'dhammapada_screen.dart';
import 'nikaya_list_screen.dart';

class TipitakaScreen extends StatefulWidget {
  const TipitakaScreen({super.key});

  @override
  State<TipitakaScreen> createState() => _TipitakaScreenState();
}

class _TipitakaScreenState extends State<TipitakaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCounts() async {
    final counts = await DatabaseService.instance.getTipitakaCounts();
    if (mounted) {
      setState(() {
        _counts = counts;
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
            const Text(
              'Tipiṭaka',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              'The Three Baskets of the Pāli Canon',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Sutta Piṭaka'),
            Tab(text: 'Vinaya Piṭaka'),
            Tab(text: 'Abhidhamma'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Sutta Pitaka
          _buildSuttaPitakaTab(context),

          // 2. Vinaya Pitaka
          _buildVinayaTab(context),

          // 3. Abhidhamma Pitaka
          _buildAbhidhammaTab(context),
        ],
      ),
    );
  }

  Widget _buildSuttaPitakaTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nikayas = [
      _NikayaCardData(
        abbrev: 'DN',
        title: 'Dīgha Nikāya',
        subtitle: 'The Long Collection (34 Suttas)',
        description: 'Extensive, profound discourses on cosmology, ascetic practice, miracles, ethics, and the Buddha’s final days.',
        count: _counts['DN'] ?? 16,
        collectionCode: 'dn',
        color: const Color(0xFFD97706),
      ),
      _NikayaCardData(
        abbrev: 'MN',
        title: 'Majjhima Nikāya',
        subtitle: 'The Middle-length Collection (152 Suttas)',
        description: 'Comprehensive core teachings: meditation on the breath, mindfulness frames, karma, similes, and dialogues with seekers.',
        count: _counts['MN'] ?? 142,
        collectionCode: 'mn',
        color: const Color(0xFF2563EB),
      ),
      _NikayaCardData(
        abbrev: 'SN',
        title: 'Saṃyutta Nikāya',
        subtitle: 'The Connected Collection (56 Samyuttas in 5 Vaggas)',
        description: 'Thematic groupings on Dependent Co-arising, the 5 Aggregates, the 6 Sense Bases, the Noble Eightfold Path, and the 4 Truths.',
        count: _counts['SN'] ?? 300,
        collectionCode: 'sn',
        color: const Color(0xFF059669),
      ),
      _NikayaCardData(
        abbrev: 'AN',
        title: 'Aṅguttara Nikāya',
        subtitle: 'The Further-Factored Collection (Numbered Sets 1 to 11)',
        description: 'The Buddha’s analytical teachings organized numerically: from the single thing to cultivate up to eleven factors of awakening.',
        count: _counts['AN'] ?? 300,
        collectionCode: 'an',
        color: const Color(0xFF9333EA),
      ),
    ];

    final khuddakaItems = [
      _KhuddakaBook('Dhp', 'Dhammapada', '423 Verses of Truth in 26 Chapters', isDhp: true),
      _KhuddakaBook('Ud', 'Udāna', 'Inspired utterances and origin stories', collection: 'kn/ud'),
      _KhuddakaBook('Iti', 'Itivuttaka', '"Thus it was said": Short ethical discourses', collection: 'kn/iti'),
      _KhuddakaBook('Snp', 'Sutta Nipāta', 'Ancient verses, poetic dialogues & rhymed path', collection: 'kn/snp'),
      _KhuddakaBook('Thag', 'Theragāthā', 'Verses of the Elder Monks celebrating awakening', collection: 'kn/thag'),
      _KhuddakaBook('Thig', 'Therīgāthā', 'Verses of the Elder Nuns celebrating liberation', collection: 'kn/thig'),
      _KhuddakaBook('Khp', 'Khuddakapātha', 'Short foundational recitation passages', collection: 'kn/khp'),
      _KhuddakaBook('Miln', 'Milindapañha', 'Questions of King Menander to Venerable Nagasena', collection: 'kn/miln'),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Intro Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (Theme.of(context).colorScheme.primary).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_stories,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'The Sutta Piṭaka holds over 1,000 translations across the Five Great Nikāyas.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? AppColors.darkText : AppColors.parchmentText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Four Main Nikayas
        ...nikayas.map((n) => _buildNikayaCard(context, n)),

        const SizedBox(height: 20),

        // Khuddaka Nikaya Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Khuddaka Nikāya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkText : AppColors.parchmentText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'KN: MINOR TEXTS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Beloved poetic, inspirational, and monastic literature',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Khuddaka Nikaya Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemCount: khuddakaItems.length,
            itemBuilder: (ctx, i) {
              final item = khuddakaItems[i];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (item.isDhp) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DhammapadaScreen()),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NikayaListScreen(
                          title: item.title,
                          subtitle: item.subtitle,
                          collectionCode: item.collection,
                          nikayaAbbrev: 'KN',
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.abbrev,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Icon(
                            item.isDhp ? Icons.stars : Icons.arrow_forward,
                            size: 14,
                            color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNikayaCard(BuildContext context, _NikayaCardData n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NikayaListScreen(
                title: n.title,
                subtitle: n.subtitle,
                collectionCode: n.collectionCode,
                nikayaAbbrev: n.abbrev,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: n.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      n.abbrev,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: n.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      n.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                n.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                n.description,
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

  Widget _buildVinayaTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPitakaInfoCard(
          title: 'Vinaya Piṭaka: The Basket of Discipline',
          description:
              'The rules of conduct governing daily life within the Sangha of monks (bhikkhus) and nuns (bhikkhunis). Origin stories explain how the Buddha solved disputes and maintained harmony within a spiritual community.',
          icon: Icons.gavel_outlined,
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          context,
          title: 'The Buddhist Monastic Code (Vol. I & II)',
          subtitle: 'Thanissaro Bhikkhu’s detailed commentary on the Pātimokkha',
          path: 'tipitaka/vin/index.html',
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          context,
          title: 'Browse All Vinaya Suttas & Rules',
          subtitle: 'Origins and stories behind the disciplinary codes',
          collectionCode: 'vinaya',
        ),
      ],
    );
  }

  Widget _buildAbhidhammaTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPitakaInfoCard(
          title: 'Abhidhamma Piṭaka: Ultimate Realities',
          description:
              'Analytical treatises systematically categorizing consciousness (citta), mental factors (cetasika), matter (rūpa), and liberation (Nibbāna).',
          icon: Icons.schema_outlined,
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          context,
          title: 'Abhidhamma Pitaka Overview',
          subtitle: 'Introduction to the analytic methods of Theravada psychology',
          path: 'tipitaka/abhi/index.html',
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          context,
          title: 'Browse Abhidhamma Texts',
          subtitle: 'Studies and essays on the seven books of the Abhidhamma',
          collectionCode: 'abhidhamma',
        ),
      ],
    );
  }

  Widget _buildPitakaInfoCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.parchmentBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark ? AppColors.darkText : AppColors.parchmentText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? path,
    String? collectionCode,
  }) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          if (path != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: path)),
            );
          } else if (collectionCode != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NikayaListScreen(
                  title: title,
                  subtitle: subtitle,
                  collectionCode: collectionCode,
                  nikayaAbbrev: '',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _NikayaCardData {
  final String abbrev;
  final String title;
  final String subtitle;
  final String description;
  final int count;
  final String collectionCode;
  final Color color;

  _NikayaCardData({
    required this.abbrev,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.count,
    required this.collectionCode,
    required this.color,
  });
}

class _KhuddakaBook {
  final String abbrev;
  final String title;
  final String subtitle;
  final String collection;
  final bool isDhp;

  _KhuddakaBook(this.abbrev, this.title, this.subtitle, {this.collection = '', this.isDhp = false});
}
