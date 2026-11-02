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
  List<PostModel> _savedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final list = await _bookmarkService.getBookmarkedPosts();
    if (mounted) {
      setState(() {
        _savedPosts = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'സേവ് ചെയ്ത വാർത്തകൾ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _savedPosts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 72,
                        color: AppColors.primary.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'വാർത്തകളൊന്നും സേവ് ചെയ്തിട്ടില്ല',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'പിന്നീട് വായിക്കാൻ വാർത്തകൾ ബുക്ക്മാർക്ക് ചെയ്യാം',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: _savedPosts.length,
                  itemBuilder: (context, index) {
                    final post = _savedPosts[index];
                    return Dismissible(
                      key: Key('bookmark_${post.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await _bookmarkService.toggleBookmark(post);
                        _loadBookmarks();
                      },
                      child: NewsCard(post: post),
                    );
                  },
                ),
    );
  }
}
