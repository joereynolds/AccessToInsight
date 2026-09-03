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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: (isDark ? AppColors.saffronDark : AppColors.saffron).withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2A231C), const Color(0xFF1E1A16)]
                : [const Color(0xFFFFFBF4), const Color(0xFFF9F3E8)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    size: 16,
                    color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'DAILY CONTEMPLATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    c.sourceRef,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Pali Verse
            Text(
              c.versePali,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontFamily: 'serif',
                color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
              ),
            ),
            const SizedBox(height: 8),

            // English Translation
            Text(
              '“${c.verseEnglish}”',
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.parchmentText,
              ),
            ),
            const SizedBox(height: 14),

            // Reflection Prompt Callout
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.self_improvement,
                    size: 18,
                    color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Practice Reflection: ${c.theme}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.reflectionPrompt,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: isDark ? AppColors.darkText : AppColors.parchmentText,
                          ),
                        ),
                      ],
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
