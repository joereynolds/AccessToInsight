import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaliBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const PaliBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? AppColors.saffronDark.withValues(alpha: 0.3) : AppColors.saffronLight.withValues(alpha: 0.6));
    final fg = textColor ?? (isDark ? AppColors.saffronMuted : AppColors.terracotta);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: fg.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
