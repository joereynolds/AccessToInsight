import 'package:flutter/material.dart';
import '../../models/ptf_section.dart';
import '../../theme/app_colors.dart';
import '../gradual_path/gradual_path_screen.dart';
import '../reader/sutta_reader_screen.dart';

class GradualPathPreview extends StatelessWidget {
  final List<PtfSection> sections;

  const GradualPathPreview({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Gradual Training',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.darkText : AppColors.parchmentText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Anupubbī-kathā: The Buddha’s step-by-step path',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GradualPathScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: sections.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final s = sections[i];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SuttaReaderScreen(textId: s.detailPath),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.parchmentCard,
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
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.5),
                            child: Text(
                              '${s.stepOrder}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.paliName,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
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
    );
  }
}
