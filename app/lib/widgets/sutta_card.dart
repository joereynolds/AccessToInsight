import 'package:flutter/material.dart';
import '../models/text_item.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../screens/library/authors_screen.dart';
import '../screens/reader/sutta_reader_screen.dart';

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
              // Title + reading time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
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
                  ),
                ],
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
                    child: GestureDetector(
                      onTap: item.author.isNotEmpty
                          ? () async {
                              final texts = await DatabaseService.instance.getTextsByAuthor(item.author);
                              if (context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AuthorWorksScreen(authorName: item.author, texts: texts),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: Text(
                        item.author.isNotEmpty ? item.author : 'Traditional',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          decoration: item.author.isNotEmpty ? TextDecoration.underline : null,
                          decorationColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Read',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 11,
                    color: Theme.of(context).colorScheme.primary,
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
