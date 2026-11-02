import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/post_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../widgets/featured_slider.dart';
import '../widgets/category_tabs.dart';
import '../widgets/breaking_news_ticker.dart';
import '../widgets/news_card.dart';
import '../widgets/ad_banner_widget.dart';
import 'shorts_news_screen.dart';
import 'bookmarks_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  List<PostModel> _allPosts = [];
  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMorePosts();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _apiService.fetchLatestPosts(page: 1, perPage: 12),
        _apiService.fetchCategories(),
      ]);

      if (mounted) {
        setState(() {
          _allPosts = futures[0] as List<PostModel>;
          _categories = futures[1] as List<CategoryModel>;
          _isLoading = false;
          _currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      List<PostModel> newPosts;

      if (_selectedCategoryId == null) {
        newPosts = await _apiService.fetchLatestPosts(page: nextPage, perPage: 10);
      } else {
        newPosts = await _apiService.fetchPostsByCategory(
          categoryId: _selectedCategoryId!,
          page: nextPage,
          perPage: 10,
        );
      }

      if (mounted) {
        setState(() {
          _allPosts.addAll(newPosts);
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onCategorySelected(int? categoryId) async {
    setState(() {
      _selectedCategoryId = categoryId;
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      List<PostModel> posts;
      if (categoryId == null) {
        posts = await _apiService.fetchLatestPosts(page: 1, perPage: 12);
      } else {
        posts = await _apiService.fetchPostsByCategory(categoryId: categoryId, page: 1, perPage: 12);
      }

      if (mounted) {
        setState(() {
          _allPosts = posts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Row(
                children: [
                  Icon(Icons.newspaper_rounded, color: AppColors.primary, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Dweep Diary',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'തിരയുക',
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'സേവ് ചെയ്ത വാർത്തകൾ',
            icon: const Icon(Icons.bookmark_outline_rounded, color: AppColors.textPrimary, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarksScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadInitialData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Breaking News Ticker
                  SliverToBoxAdapter(
                    child: BreakingNewsTicker(posts: _allPosts),
                  ),

                  // 2. Featured News Carousel Slider (Top Stories)
                  if (_selectedCategoryId == null && _allPosts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: FeaturedSlider(posts: _allPosts),
                      ),
                    ),

                  // 3. Category Horizontal Filter Tabs
                  SliverToBoxAdapter(
                    child: CategoryTabs(
                      categories: _categories,
                      selectedCategoryId: _selectedCategoryId,
                      onSelectCategory: _onCategorySelected,
                    ),
                  ),

                  // 4. Sponsored Top Banner Ad
                  const SliverToBoxAdapter(
                    child: AdBannerWidget(),
                  ),

                  // 5. News List Items with Periodic Ads
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Insert an Ad every 5 items
                        if (index > 0 && index % 5 == 0) {
                          return const Column(
                            children: [
                              AdBannerWidget(),
                            ],
                          );
                        }

                        final postIndex = index - (index ~/ 5);
                        if (postIndex >= _allPosts.length) return null;

                        return NewsCard(post: _allPosts[postIndex]);
                      },
                      childCount: _allPosts.length + (_allPosts.length ~/ 5),
                    ),
                  ),

                  // 6. Pagination Loader Indicator
                  if (_isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
    );
  }
}
