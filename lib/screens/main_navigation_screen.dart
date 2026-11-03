import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'community_screen.dart';
import 'shorts_news_screen.dart';
import 'bookmarks_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    CommunityScreen(),
    ShortsNewsScreen(),
    BookmarksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          elevation: 0,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          indicatorColor: isDark
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.primaryLight,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.newspaper_outlined,
                  color: isDark ? AppColors.darkTextSecondary : null),
              selectedIcon:
                  const Icon(Icons.newspaper_rounded, color: AppColors.primary),
              label: 'News',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined,
                  color: isDark ? AppColors.darkTextSecondary : null),
              selectedIcon:
                  const Icon(Icons.grid_view_rounded, color: AppColors.primary),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined,
                  color: isDark ? AppColors.darkTextSecondary : null),
              selectedIcon:
                  const Icon(Icons.forum_rounded, color: AppColors.primary),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_arrow_outlined,
                  color: isDark ? AppColors.darkTextSecondary : null),
              selectedIcon:
                  const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
              label: 'Shorts',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded,
                  color: isDark ? AppColors.darkTextSecondary : null),
              selectedIcon:
                  const Icon(Icons.bookmark_rounded, color: AppColors.primary),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  }
}
