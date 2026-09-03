import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final settings = appState.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).viewPadding.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Reading Display',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Theme Mode Selector
          const Text(
            'Theme',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildThemeChoice(
                context,
                title: 'Parchment',
                style: AppThemeStyle.warmParchment,
                isSelected: settings.themeStyle == AppThemeStyle.warmParchment,
                color: AppColors.parchmentBg,
                textColor: AppColors.parchmentText,
                onTap: () => appState.updateThemeStyle(AppThemeStyle.warmParchment),
              ),
              const SizedBox(width: 10),
              _buildThemeChoice(
                context,
                title: 'Insight',
                style: AppThemeStyle.insight,
                isSelected: settings.themeStyle == AppThemeStyle.insight,
                color: AppColors.insightBg,
                textColor: AppColors.insightText,
                onTap: () => appState.updateThemeStyle(AppThemeStyle.insight),
              ),
              const SizedBox(width: 10),
              _buildThemeChoice(
                context,
                title: 'Mono',
                style: AppThemeStyle.monochrome,
                isSelected: settings.themeStyle == AppThemeStyle.monochrome,
                color: AppColors.monoBg,
                textColor: AppColors.monoText,
                onTap: () => appState.updateThemeStyle(AppThemeStyle.monochrome),
              ),
              const SizedBox(width: 10),
              _buildThemeChoice(
                context,
                title: 'Night',
                style: AppThemeStyle.darkTemple,
                isSelected: settings.themeStyle == AppThemeStyle.darkTemple,
                color: AppColors.darkBg,
                textColor: AppColors.darkText,
                onTap: () => appState.updateThemeStyle(AppThemeStyle.darkTemple),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Font Size Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Text Size',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                '${settings.fontSize.toInt()} pt',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: settings.fontSize,
                  min: 13.0,
                  max: 26.0,
                  divisions: 13,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (val) => appState.updateFontSize(val),
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),

          // Font Family
          const Text(
            'Typography Style',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Serif (Classic Dhamma)', style: TextStyle(fontFamily: 'serif'))),
                  selected: settings.fontFamily == 'serif' || settings.fontFamily == 'Georgia',
                  onSelected: (selected) {
                    if (selected) appState.updateFontFamily('serif');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Sans-Serif (Modern)')),
                  selected: settings.fontFamily == 'sans-serif',
                  onSelected: (selected) {
                    if (selected) appState.updateFontFamily('sans-serif');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Line Spacing
          const Text(
            'Line Height',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSpacingChip('Compact', 1.4, settings.lineHeight, appState),
              const SizedBox(width: 8),
              _buildSpacingChip('Normal', 1.65, settings.lineHeight, appState),
              const SizedBox(width: 8),
              _buildSpacingChip('Relaxed', 1.9, settings.lineHeight, appState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChoice(
    BuildContext context, {
    required String title,
    required AppThemeStyle style,
    required bool isSelected,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.saffron : Colors.black12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpacingChip(String label, double val, double currentVal, AppStateProvider appState) {
    final isSelected = (val - currentVal).abs() < 0.1;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label, style: const TextStyle(fontSize: 12))),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) appState.updateLineHeight(val);
        },
      ),
    );
  }
}
