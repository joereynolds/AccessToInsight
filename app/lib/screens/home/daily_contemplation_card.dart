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
    final borderColor = (isDark ? AppColors.saffronDark : AppColors.saffron).withOpacity(0.5);
    final quoteColor = isDark ? AppColors.darkText : AppColors.parchmentText;
    final sourceColor = isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${c.verseEnglish}"',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                      color: quoteColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '— ${c.sourceRef}',
                    style: TextStyle(
                      fontSize: 11,
                      color: sourceColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
