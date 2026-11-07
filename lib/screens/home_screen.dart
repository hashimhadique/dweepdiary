import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../models/post_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';
import '../widgets/featured_slider.dart';
import '../widgets/category_tabs.dart';
import '../widgets/breaking_news_ticker.dart';
import '../widgets/news_card.dart';
import '../widgets/ad_banner_widget.dart';
import 'search_screen.dart';
import 'community_screen.dart';
import 'ship_updates_screen.dart';
import 'submit_news_screen.dart';
import 'contact_us_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ThemeService _themeService = ThemeService();

  List<PostModel> _allPosts = [];
  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isOfflineData = false;
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
    setState(() {
      _isLoading = true;
      _isOfflineData = false;
    });

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
    } catch (_) {
      // Try offline cached posts
      final cached = await _apiService.getCachedPosts();
      if (mounted) {
        setState(() {
          _allPosts = cached;
          _isLoading = false;
          _isOfflineData = cached.isNotEmpty;
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || _isOfflineData) return;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      drawer: _buildDrawer(context, isDark),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0.8,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: isDark
                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
                  : EdgeInsets.zero,
              decoration: isDark
                  ? BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Image.asset(
                'assets/images/logo.png',
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Row(
                  children: [
                    const Icon(Icons.newspaper_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Dweep Diary',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Community Discussions Shortcut
          IconButton(
            tooltip: 'Community Discussions',
            icon: Icon(
              Icons.forum_outlined,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CommunityScreen()),
              );
            },
          ),

          // Search News
          IconButton(
            tooltip: 'Search',
            icon: Icon(
              Icons.search_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              size: 23,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),

          // Dark/Light Mode Toggle
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
              color: isDark ? Colors.amber : AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              _themeService.toggleTheme();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _allPosts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 64,
                          color: isDark ? Colors.white38 : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to load news',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check your internet connection',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _loadInitialData,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadInitialData,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Offline banner if showing cached data
                      if (_isOfflineData)
                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.amber.shade800,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: const Row(
                              children: [
                                Icon(Icons.cloud_off_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Offline Mode — Showing saved articles',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // 1. Breaking News Ticker
                      if (_allPosts.isNotEmpty)
                        SliverToBoxAdapter(
                          child: BreakingNewsTicker(posts: _allPosts),
                        ),

                      // 2. Featured News Carousel Slider
                      if (_selectedCategoryId == null && _allPosts.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 4),
                            child: FeaturedSlider(posts: _allPosts),
                          ),
                        ),

                      // Quick Lakshadweep Services (Ship Updates & Submit News)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Row(
                            children: [
                              // 1. Ship Updates Button Card
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ShipUpdatesScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFF0077B6).withOpacity(0.25),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0077B6)
                                              .withOpacity(isDark ? 0.15 : 0.06),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0077B6).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.directions_boat_rounded,
                                              color: Color(0xFF0077B6), size: 18),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ship Updates',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? AppColors.darkTextPrimary
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                              const Text(
                                                'IRCTC Live',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0077B6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // 2. Submit News Button Card
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SubmitNewsScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFF25D366).withOpacity(0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF25D366)
                                              .withOpacity(isDark ? 0.15 : 0.06),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF25D366).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.send_rounded,
                                              color: Color(0xFF1EBE5D), size: 18),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Submit News',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? AppColors.darkTextPrimary
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                              const Text(
                                                'WhatsApp Desk',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1EBE5D),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. Category Horizontal Filter Tabs
                      if (_categories.isNotEmpty)
                        SliverToBoxAdapter(
                          child: CategoryTabs(
                            categories: _categories,
                            selectedCategoryId: _selectedCategoryId,
                            onSelectCategory: _onCategorySelected,
                          ),
                        ),

                      // 4. Top Ad Slot: Google AdMob Banner
                      const SliverToBoxAdapter(
                        child: AdBannerWidget.adMob(),
                      ),

                      // 5. News List Items with Alternating Hybrid Ads
                      // Slot A: AdMob Banner | Slot B: Custom Uploaded Sponsor Ad
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // After every 5 news articles, inject an ad
                            if (index > 0 && index % 5 == 0) {
                              final adPosition = index ~/ 5;
                              // Even ad slots: Google AdMob | Odd ad slots: Custom Uploaded Sponsor Ad
                              final isCustomAd = adPosition % 2 != 0;

                              return isCustomAd
                                  ? const AdBannerWidget.customSponsor()
                                  : const AdBannerWidget.adMob();
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

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.newspaper_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dweep Diary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lakshadweep News Portal (dweepdiary.in)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading: const Icon(Icons.home_rounded, color: AppColors.primary),
                  title: const Text('Latest News', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.grid_view_rounded, color: Colors.orangeAccent),
                  title: const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.send_rounded, color: Color(0xFF25D366)),
                  title: const Text('Submit News & Photos', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Send directly to WhatsApp Desk', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SubmitNewsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_boat_rounded, color: Colors.blueAccent),
                  title: const Text('Ship Updates & Alerts', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShipUpdatesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.forum_outlined, color: Colors.purpleAccent),
                  title: const Text('Community Discussions', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CommunityScreen()),
                    );
                  },
                ),

                const Divider(height: 24),

                // REQUIRED BY GOOGLE PLAY NEWS POLICY
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.contact_support_rounded, color: AppColors.primary),
                    title: const Text(
                      'Contact Us & Editorial',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    subtitle: const Text(
                      'thedweepdiary@gmail.com\n+91 8289883750',
                      style: TextStyle(fontSize: 11.5, height: 1.3),
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.textSecondary),
                  title: const Text('Visit Website (dweepdiary.in)'),
                  onTap: () async {
                    Navigator.pop(context);
                    final uri = Uri.parse('https://dweepdiary.in');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
                  title: const Text('Privacy Policy'),
                  onTap: () async {
                    Navigator.pop(context);
                    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),

          // Drawer Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Dweep Diary News App\nVersion 1.0.6 (Build 7)\nKiltan Island, Lakshadweep - 682558',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
