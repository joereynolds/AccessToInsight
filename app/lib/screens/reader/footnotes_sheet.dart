import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FootnotesSheet extends StatelessWidget {
  final String noteNumber;
  final String noteText;

  const FootnotesSheet({
    super.key,
    required this.noteNumber,
    required this.noteText,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Text(
                'Note $noteNumber',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            child: Text(
              noteText,
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: isDark ? AppColors.darkText : AppColors.parchmentText,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Return to Reading'),
            ),
          ),
        ],
      ),
    );
  }
}
