import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../reader/sutta_reader_screen.dart';

class StarterTracks extends StatelessWidget {
  const StarterTracks({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tracks = [
      _Track(
        title: 'New to the Teachings?',
        subtitle: 'Befriending the suttas & foundational principles',
        icon: Icons.explore_outlined,
        color: AppColors.saffron,
        items: [
          _TrackItem('What is Theravada Buddhism?', 'theravada.html', 'A clear introduction to the Theravada tradition'),
          _TrackItem('Befriending the Suttas', 'befriending.html', 'How to read and appreciate the Pali discourses'),
          _TrackItem("The Buddha's First Sermon", 'tipitaka/sn/sn56/sn56.011.than.html', 'Dhammacakkappavattana Sutta (SN 56.11)'),
          _TrackItem('The Fire Sermon', 'tipitaka/sn/sn35/sn35.028.than.html', 'Adittapariyaya Sutta (SN 35.28)'),
        ],
      ),
      _Track(
        title: 'Meditation & Mindfulness',
        subtitle: 'Calm and insight practices from the roots',
        icon: Icons.spa_outlined,
        color: AppColors.forestSage,
        items: [
          _TrackItem('Mindfulness of In-&-Out Breathing', 'tipitaka/mn/mn.118.than.html', 'Anapanasati Sutta (MN 118)'),
          _TrackItem('Four Frames of Reference', 'tipitaka/mn/mn.010.than.html', 'Satipatthana Sutta (MN 10)'),
          _TrackItem('A Guided Meditation', 'lib/authors/thanissaro/guided.html', 'Practical breath instruction by Thanissaro Bhikkhu'),
          _TrackItem('Starting Out Small', 'lib/thai/lee/startsmall.html', 'Foundational meditation talks by Ajaan Lee'),
        ],
      ),
      _Track(
        title: 'Wisdom & Liberation',
        subtitle: 'The 3 characteristics, non-self & dependent arising',
        icon: Icons.psychology_outlined,
        color: AppColors.terracotta,
        items: [
          _TrackItem('The Non-Self Characteristic', 'tipitaka/sn/sn22/sn22.059.than.html', 'Anattalakkhana Sutta (SN 22.59)'),
          _TrackItem('The Arrow of Grief & Pain', 'tipitaka/sn/sn36/sn36.006.than.html', 'Sallatha Sutta (SN 36.6)'),
          _TrackItem('To Kevatta (On Miracles)', 'tipitaka/dn/dn.11.0.than.html', 'The true miracle of instruction (DN 11)'),
          _TrackItem('The Simile of the Raft', 'tipitaka/mn/mn.022.than.html', 'Alagaddupama Sutta (MN 22)'),
        ],
      ),
      _Track(
        title: 'Dhamma for Everyday Life',
        subtitle: 'Virtue, friendship, speech, and practical ethics',
        icon: Icons.people_outline,
        color: Colors.indigo,
        items: [
          _TrackItem('The Layperson’s Code of Discipline', 'tipitaka/dn/dn.31.0.kimb.html', 'Sigalovada Sutta (DN 31)'),
          _TrackItem('To the Kalamas: Free Inquiry', 'tipitaka/an/an03/an03.065.than.html', 'Kalama Sutta (AN 3.65)'),
          _TrackItem('Loving-Kindness (Metta)', 'tipitaka/kn/snp/snp.1.08.than.html', 'Karaniya Metta Sutta (Sn 1.8)'),
          _TrackItem('Supreme Blessings', 'tipitaka/kn/khp/khp.5.piya.html', 'Mangala Sutta (Khp 5)'),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Digestible Reading Tracks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.darkText : AppColors.parchmentText,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'CURATED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: tracks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final t = tracks[i];
              return Container(
                width: 290,
                padding: const EdgeInsets.all(16),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: t.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(t.icon, size: 20, color: t.color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                t.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: t.items.length,
                        itemBuilder: (ctx, idx) {
                          final item = t.items[idx];
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SuttaReaderScreen(textId: item.path),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Track {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<_TrackItem> items;

  _Track({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _TrackItem {
  final String title;
  final String path;
  final String subtitle;

  _TrackItem(this.title, this.path, this.subtitle);
}
