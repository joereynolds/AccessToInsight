import 'package:flutter/material.dart';
import '../../models/ptf_section.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../reader/sutta_reader_screen.dart';

class GradualPathScreen extends StatefulWidget {
  const GradualPathScreen({super.key});

  @override
  State<GradualPathScreen> createState() => _GradualPathScreenState();
}

class _GradualPathScreenState extends State<GradualPathScreen> {
  List<PtfSection> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    final list = await DatabaseService.instance.getPtfSections();
    if (mounted) {
      setState(() {
        _sections = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A Path to Freedom', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(
              'The Gradual Training (Anupubbī-kathā)',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Explanatory Intro
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How the Buddha Taught',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The Buddha frequently guided newcomers through a progressive framework called "gradual instruction" (anupubbī-kathā). Starting from generosity, through ethical integrity and heaven, he then demonstrated the drawbacks of clinging, the freedom of renunciation, and finally revealed the Four Noble Truths.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: isDark ? AppColors.darkText : AppColors.parchmentText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Stepped Timeline
                ..._sections.map((s) => _buildStepCard(context, s)),
              ],
            ),
    );
  }

  Widget _buildStepCard(BuildContext context, PtfSection s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SuttaReaderScreen(textId: s.detailPath)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${s.stepOrder}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pāli: ${s.paliName}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.summary,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? AppColors.darkText : AppColors.parchmentText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Explore Stage Readings',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
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
            ],
          ),
        ),
      ),
    );
  }
}
