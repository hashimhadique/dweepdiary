import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/post_model.dart';
import '../screens/news_detail_screen.dart';

class BreakingNewsTicker extends StatefulWidget {
  final List<PostModel> posts;

  const BreakingNewsTicker({super.key, required this.posts});

  @override
  State<BreakingNewsTicker> createState() => _BreakingNewsTickerState();
}

class _BreakingNewsTickerState extends State<BreakingNewsTicker> {
  Timer? _timer;
  int _currentIndex = 0;
  List<PostModel> _latestPosts = [];

  @override
  void initState() {
    super.initState();
    _filterPosts();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant BreakingNewsTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.posts != oldWidget.posts) {
      _filterPosts();
    }
  }

  void _filterPosts() {
    // 1. Try to get posts from 'News' category first
    final newsCategoryPosts = widget.posts.where((p) {
      final cat = p.categoryName.toLowerCase();
      return cat.contains('news') || cat.contains('വാർത്ത');
    }).toList();

    if (newsCategoryPosts.isNotEmpty) {
      _latestPosts = newsCategoryPosts.take(5).toList();
    } else {
      _latestPosts = widget.posts.take(5).toList();
    }

    if (_currentIndex >= _latestPosts.length) {
      _currentIndex = 0;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
      if (_latestPosts.length > 1 && mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _latestPosts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_latestPosts.isEmpty) return const SizedBox.shrink();
    final currentPost = _latestPosts[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(post: currentPost),
            ),
          );
        },
        child: Row(
          children: [
            // LATEST Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'LATEST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Animated News Headline Text (Scrolling through top 5)
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  currentPost.cleanTitle,
                  key: ValueKey<int>(currentPost.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Index Indicator (e.g. 1/5)
            Text(
              '${_currentIndex + 1}/${_latestPosts.length}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white38 : AppColors.primaryDark.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 2),

            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? AppColors.primary : AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
