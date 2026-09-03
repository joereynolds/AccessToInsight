import 'package:flutter/material.dart';
import '../models/glossary_item.dart';
import '../theme/app_colors.dart';
import '../screens/reader/sutta_reader_screen.dart';

class GlossaryTile extends StatefulWidget {
  final GlossaryItem item;

  const GlossaryTile({super.key, required this.item});

  @override
  State<GlossaryTile> createState() => _GlossaryTileState();
}

class _GlossaryTileState extends State<GlossaryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.paliTerm,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'serif',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (widget.item.term != widget.item.paliTerm.toLowerCase())
                          Text(
                            widget.item.term,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.definition,
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isDark ? AppColors.darkText : AppColors.parchmentText,
                ),
              ),
              if (_isExpanded && widget.item.morePath != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => SuttaReaderScreen(textId: widget.item.morePath!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book, size: 16),
                    label: const Text('Read Full Discourse / Study Guide'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
