import 'package:flutter/material.dart';
import '../models/text_item.dart';
import '../theme/app_colors.dart';
import '../screens/reader/sutta_reader_screen.dart';
import 'pali_badge.dart';

class SuttaCard extends StatelessWidget {
  final TextItem item;
  final VoidCallback? onBookmarkToggle;
  final bool isBookmarked;

  const SuttaCard({
    super.key,
    required this.item,
    this.onBookmarkToggle,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => SuttaReaderScreen(textId: item.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header badges & metadata
              Row(
                children: [
                  PaliBadge(label: item.displayReference),
                  const SizedBox(width: 8),
                  if (item.ptsId != null && item.ptsId!.isNotEmpty && item.ptsId != item.suttaRef)
                    Text(
                      item.ptsId!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.readingTimeMinutes} min',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),

              // Subtitle
              if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  item.subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Summary snippet if available
              if (item.summary.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? AppColors.darkText.withOpacity(0.85) : AppColors.parchmentText.withOpacity(0.85),
                  ),
                ),
              ],

              const SizedBox(height: 10),
              // Footer Author & Read link
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.author.isNotEmpty ? item.author : 'Traditional',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                      ),
                    ),
                  ),
                  Text(
                    'Read',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 11,
                    color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
