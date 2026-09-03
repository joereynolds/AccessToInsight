import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../reader/sutta_reader_screen.dart';

class StarterTracks extends StatelessWidget {
  final Color headingColor;
  const StarterTracks({super.key, required this.headingColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tracks = [
      _Track(
        title: 'New to the Teachings',
        items: [
          _TrackItem('What is Theravada Buddhism?', 'theravada.html'),
          _TrackItem('Befriending the Suttas', 'befriending.html'),
          _TrackItem('The Buddha\'s First Sermon', 'tipitaka/sn/sn56/sn56.011.than.html'),
          _TrackItem('The Fire Sermon', 'tipitaka/sn/sn35/sn35.028.than.html'),
        ],
      ),
      _Track(
        title: 'Meditation & Mindfulness',
        items: [
          _TrackItem('Mindfulness of Breathing', 'tipitaka/mn/mn.118.than.html'),
          _TrackItem('Four Frames of Reference', 'tipitaka/mn/mn.010.than.html'),
          _TrackItem('A Guided Meditation', 'lib/authors/thanissaro/guided.html'),
          _TrackItem('Starting Out Small', 'lib/thai/lee/startsmall.html'),
        ],
      ),
      _Track(
        title: 'Wisdom & Liberation',
        items: [
          _TrackItem('The Non-Self Characteristic', 'tipitaka/sn/sn22/sn22.059.than.html'),
          _TrackItem('The Arrow of Grief & Pain', 'tipitaka/sn/sn36/sn36.006.than.html'),
          _TrackItem('To Kevatta (On Miracles)', 'tipitaka/dn/dn.11.0.than.html'),
          _TrackItem('The Simile of the Raft', 'tipitaka/mn/mn.022.than.html'),
        ],
      ),
      _Track(
        title: 'Dhamma for Everyday Life',
        items: [
          _TrackItem('The Layperson\'s Code of Discipline', 'tipitaka/dn/dn.31.0.kimb.html'),
          _TrackItem('To the Kalamas: Free Inquiry', 'tipitaka/an/an03/an03.065.than.html'),
          _TrackItem('Loving-Kindness (Metta)', 'tipitaka/kn/snp/snp.1.08.than.html'),
          _TrackItem('Supreme Blessings', 'tipitaka/kn/khp/khp.5.piya.html'),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Suggested Reading',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: headingColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...tracks.map((t) => _buildTrack(context, t, isDark)),
      ],
    );
  }

  Widget _buildTrack(BuildContext context, _Track t, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            t.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
            ),
          ),
        ),
        ...t.items.map(
          (item) => InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SuttaReaderScreen(textId: item.path),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Track {
  final String title;
  final List<_TrackItem> items;
  _Track({required this.title, required this.items});
}

class _TrackItem {
  final String title;
  final String path;
  _TrackItem(this.title, this.path);
}
