import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'glossary_screen.dart';
import 'similes_screen.dart';
import 'subjects_screen.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reference & Tools', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text(
              'Pāli Glossary, Similes & General Subject Index',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? AppColors.saffronMuted : AppColors.terracotta,
          labelColor: isDark ? AppColors.saffronMuted : AppColors.terracotta,
          tabs: const [
            Tab(text: 'Pāli Glossary'),
            Tab(text: 'Similes & Parables'),
            Tab(text: 'Subject Index'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GlossaryScreen(),
          SimilesScreen(),
          SubjectsScreen(),
        ],
      ),
    );
  }
}
