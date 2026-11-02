import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import 'news_detail_screen.dart';

class ShortsNewsScreen extends StatefulWidget {
  const ShortsNewsScreen({super.key});

  @override
  State<ShortsNewsScreen> createState() => _ShortsNewsScreenState();
}

class _ShortsNewsScreenState extends State<ShortsNewsScreen> {
  final ApiService _apiService = ApiService();
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShortsNews();
  }

  Future<void> _loadShortsNews() async {
    try {
      final posts = await _apiService.fetchLatestPosts(page: 1, perPage: 20);
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_posts.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.article_outlined, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('No stories available'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadShortsNews,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              if (post.featuredImageUrl != null && post.featuredImageUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: post.featuredImageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: AppColors.darkBackground),
                )
              else
                Container(color: AppColors.darkBackground),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content Area
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar with Category & Share
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              post.categoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_rounded, color: Colors.white),
                            onPressed: () {
                              Share.share('${post.cleanTitle}\n${post.link}');
                            },
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Title
                      Text(
                        post.cleanTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Short Summary (Clean Excerpt)
                      Text(
                        post.cleanExcerpt,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Read Full Article Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.white30),
                          ),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailScreen(post: post),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Read Full Story',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Swipe hint
                      const Center(
                        child: Text(
                          'Swipe up for next ▲',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
