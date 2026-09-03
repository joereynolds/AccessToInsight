import 'package:flutter/material.dart';
import '../../models/daily_contemplation.dart';
import '../../theme/app_colors.dart';

class DailyContemplationCard extends StatelessWidget {
  final DailyContemplation? contemplation;
  final VoidCallback? onRefresh;

  const DailyContemplationCard({
    super.key,
    required this.contemplation,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (contemplation == null) return const SizedBox.shrink();

    final c = contemplation!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${c.verseEnglish}"',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkText : AppColors.parchmentText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— ${c.sourceRef}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
