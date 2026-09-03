import 'package:flutter/material.dart';
import '../models/simile_item.dart';
import '../theme/app_colors.dart';
import '../screens/reader/sutta_reader_screen.dart';

class SimileCard extends StatelessWidget {
  final SimileItem item;

  const SimileCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (item.linkPath.isNotEmpty && !item.linkPath.startsWith('#')) {
            // Strip any # anchor from path
            final cleanPath = item.linkPath.split('#')[0];
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => SuttaReaderScreen(textId: cleanPath),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Simile source: ${item.suttaRef}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.simile,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : AppColors.parchmentSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Represents: ${item.meaning}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Canonical references: ${item.suttaRef}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
