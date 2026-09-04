import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/bookmarks/bookmarks_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/reader/reader_settings_sheet.dart';
import 'screens/reference/reference_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class AccessToInsightApp extends StatelessWidget {
  const AccessToInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Access to Insight',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(appState.settings.themeStyle),
            home: appState.isDbReady
                ? const MainNavigationScaffold()
                : DbLoadingScreen(
                    statusMessage: appState.dbStatusMessage,
                    progress: appState.dbProgress,
                  ),
          );
        },
      ),
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;
  int _bookmarksVersion = 0;

  void _onDestinationSelected(int idx) {
    if (idx == 4) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const ReaderSettingsSheet(),
      );
      return;
    }
    if (idx == 3) _bookmarksVersion++;
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onTabChange: (index) => setState(() => _currentIndex = index)),
      const LibraryScreen(),
      const ReferenceScreen(),
      BookmarksScreen(key: ValueKey(_bookmarksVersion)),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_library_outlined),
            selectedIcon: Icon(Icons.local_library),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Reference',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DbLoadingScreen extends StatelessWidget {
  final String statusMessage;
  final double progress;

  const DbLoadingScreen({
    super.key,
    required this.statusMessage,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchmentBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.saffronDark : AppColors.saffronLight).withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.spa,
                    size: 44,
                    color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Access to Insight',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Readings in Theravada Buddhism',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                ),
              ),
              const SizedBox(height: 36),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 6,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  color: isDark ? AppColors.saffronMuted : AppColors.terracotta,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.parchmentTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
