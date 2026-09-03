import 'package:flutter/material.dart';
import '../../models/ptf_section.dart';
import '../../theme/app_colors.dart';
import '../gradual_path/gradual_path_screen.dart';
import '../reader/sutta_reader_screen.dart';

class GradualPathPreview extends StatelessWidget {
  final List<PtfSection> sections;
  final Color headingColor;

  const GradualPathPreview({super.key, required this.sections, required this.headingColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preview = sections.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'The Gradual Training',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: headingColor,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GradualPathScreen()),
                ),
                child: const Text('View all', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...preview.map(
          (s) => InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SuttaReaderScreen(textId: s.detailPath),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '${s.stepOrder}.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.title, style: const TextStyle(fontSize: 14)),
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
