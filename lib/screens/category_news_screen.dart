import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/post_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../widgets/news_card.dart';
import '../widgets/ad_banner_widget.dart';

class CategoryNewsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryNewsScreen({super.key, required this.category});

  @override
  State<CategoryNewsScreen> createState() => _CategoryNewsScreenState();
}

class _CategoryNewsScreenState extends State<CategoryNewsScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchCategoryNews();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _fetchCategoryNews() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _apiService.fetchPostsByCategory(
        categoryId: widget.category.id,
        page: 1,
        perPage: 12,
      );
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
          _currentPage = 1;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final newPosts = await _apiService.fetchPostsByCategory(
        categoryId: widget.category.id,
        page: nextPage,
        perPage: 10,
      );
      if (mounted) {
        setState(() {
          _posts.addAll(newPosts);
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.8,
        title: Text(
          widget.category.malayalamName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _posts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox_rounded, size: 60, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.category.malayalamName} വിഭാഗത്തിൽ വാർത്തകൾ ലഭ്യമല്ല',
                          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _fetchCategoryNews,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _posts.length + (_posts.length ~/ 5) + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoadingMore && index == _posts.length + (_posts.length ~/ 5)) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                        );
                      }

                      // Insert an ad every 5 items
                      if (index > 0 && index % 5 == 0) {
                        return const AdBannerWidget();
                      }

                      final postIndex = index - (index ~/ 5);
                      if (postIndex >= _posts.length) return null;

                      return NewsCard(post: _posts[postIndex]);
                    },
                  ),
                ),
    );
  }
}
