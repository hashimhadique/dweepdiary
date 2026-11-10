import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/post_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/news_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkService _bookmarkService = BookmarkService();

  @override
  void initState() {
    super.initState();
    _bookmarkService.getBookmarkedPosts();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Saved Articles',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: ValueListenableBuilder<List<PostModel>>(
        valueListenable: _bookmarkService.bookmarksNotifier,
        builder: (context, savedPosts, _) {
          if (savedPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 72,
                    color: AppColors.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Saved Articles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bookmark articles to read them offline later',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _bookmarkService.getBookmarkedPosts(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                final post = savedPosts[index];
                return Dismissible(
                  key: Key('bookmark_${post.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    _bookmarkService.toggleBookmark(post);
                  },
                  child: NewsCard(post: post),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
