import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/post_model.dart';
import '../models/category_model.dart';
import '../models/comment_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _cachedPostsKey = 'cached_news_posts_v1';
  static const String _commentsEndpoint = '${AppConstants.apiBaseUrl}/comments';
  static const String _customAdConfigUrl =
      'https://raw.githubusercontent.com/hashimhadique/dweepdiary/main/config/custom_ads.json';

  // Valid mobile User-Agent to pass Mod_Security
  static const Map<String, String> _headers = {
    'Accept': 'application/json, text/plain, */*',
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  };

  String _buildUrl(String endpoint, Map<String, String> params) {
    final separator = endpoint.contains('?') ? '&' : '?';
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$endpoint$separator$queryString';
  }

  /// Save posts to local SharedPreferences cache for offline reading
  Future<void> cachePosts(List<PostModel> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = posts.take(30).map((p) => p.toLocalMap()).toList();
      await prefs.setString(_cachedPostsKey, jsonEncode(list));
    } catch (_) {}
  }

  /// Get cached posts for offline fallback
  Future<List<PostModel>> getCachedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_cachedPostsKey);
      if (str != null && str.isNotEmpty) {
        final List<dynamic> list = jsonDecode(str);
        return list.map((item) => PostModel.fromLocalMap(item)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetch latest news posts with automatic offline caching and fallback
  Future<List<PostModel>> fetchLatestPosts({int page = 1, int perPage = 10}) async {
    final url = _buildUrl(AppConstants.postsEndpoint, {
      '_embed': '',
      'page': page.toString(),
      'per_page': perPage.toString(),
    });

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final posts = jsonList
            .map((item) => PostModel.fromJson(item))
            .where((p) =>
                !p.categoryName.toLowerCase().contains('sponsor') &&
                !p.categoryName.toLowerCase().contains('പരസ്യം'))
            .toList();
        if (page == 1 && posts.isNotEmpty) {
          cachePosts(posts);
        }
        return posts;
      } else {
        // Fallback to cache if first page
        if (page == 1) {
          final cached = await getCachedPosts();
          if (cached.isNotEmpty) return cached;
        }
        throw Exception('Failed to load posts (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (page == 1) {
        final cached = await getCachedPosts();
        if (cached.isNotEmpty) return cached;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Fetch posts for a specific category
  Future<List<PostModel>> fetchPostsByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 10,
  }) async {
    final url = _buildUrl(AppConstants.postsEndpoint, {
      '_embed': '',
      'categories': categoryId.toString(),
      'page': page.toString(),
      'per_page': perPage.toString(),
    });

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => PostModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load category posts (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch related posts for an article (from same category, excluding current post)
  Future<List<PostModel>> fetchRelatedPosts({
    required int categoryId,
    required int excludePostId,
    int limit = 4,
  }) async {
    try {
      final posts = await fetchPostsByCategory(
        categoryId: categoryId,
        page: 1,
        perPage: limit + 2,
      );
      return posts.where((p) => p.id != excludePostId).take(limit).toList();
    } catch (_) {
      try {
        final latest = await fetchLatestPosts(page: 1, perPage: limit + 2);
        return latest.where((p) => p.id != excludePostId).take(limit).toList();
      } catch (_) {
        return [];
      }
    }
  }

  /// Fetch single post by ID (for opening from comments or push notifications)
  Future<PostModel?> fetchPostById(int postId) async {
    final url = _buildUrl('${AppConstants.postsEndpoint}/$postId', {
      '_embed': '',
    });

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PostModel.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  /// Fetch single post by slug (for opening from URL / OneSignal push notification clicks)
  Future<PostModel?> fetchPostBySlug(String slug) async {
    final cleanSlug = slug.trim().replaceAll('/', '');
    final url = _buildUrl(AppConstants.postsEndpoint, {
      'slug': cleanSlug,
      '_embed': '',
    });

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return PostModel.fromJson(data.first);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch categories with active post counts
  Future<List<CategoryModel>> fetchCategories() async {
    final url = _buildUrl(AppConstants.categoriesEndpoint, {
      'per_page': '30',
      'hide_empty': 'true',
    });

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final categories = jsonList
            .map((item) => CategoryModel.fromJson(item))
            .where((cat) {
              final s = cat.slug.toLowerCase().trim();
              final n = cat.name.toLowerCase().trim();
              return !s.contains('sponsor') &&
                  !s.contains('ad') &&
                  !n.contains('sponsor') &&
                  !n.contains('സ്പോൺസർ') &&
                  !n.contains('പരസ്യം');
            })
            .toList();
        
        // Custom Priority: News (1) -> Politics (2) -> Jobs (3) -> Others by post count
        int getCategoryPriority(CategoryModel cat) {
          final s = cat.slug.toLowerCase().trim();
          final n = cat.name.toLowerCase().trim();
          if (s == 'news' || n == 'news' || n.contains('വാർത്ത')) return 1;
          if (s == 'politics' || n == 'politics' || n.contains('പൊളിറ്റിക്സ്') || n.contains('രാഷ്ട്രീയം')) return 2;
          if (s == 'jobs' || s == 'job' || n == 'jobs' || n == 'job' || n.contains('തൊഴിൽ') || n.contains('കരിയർ')) return 3;
          return 100;
        }

        categories.sort((a, b) {
          final pA = getCategoryPriority(a);
          final pB = getCategoryPriority(b);
          if (pA != pB) return pA.compareTo(pB);
          return b.count.compareTo(a.count);
        });

        return categories;
      } else {
        throw Exception('Failed to load categories (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Category network error: $e');
    }
  }

  /// Search news posts by keyword
  Future<List<PostModel>> searchPosts({required String query, int page = 1}) async {
    final url = _buildUrl(AppConstants.postsEndpoint, {
      '_embed': '',
      'search': query,
      'page': page.toString(),
      'per_page': '15',
    });

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => PostModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search posts (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Search network error: $e');
    }
  }

  /// Fetch comments for a specific post
  Future<List<CommentModel>> fetchCommentsForPost(int postId) async {
    final url = _buildUrl(_commentsEndpoint, {
      'post': postId.toString(),
      'per_page': '25',
      'order': 'desc',
    });

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((c) => CommentModel.fromJson(c)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetch recent comments across all articles (for Community Screen)
  Future<List<CommentModel>> fetchRecentComments({int perPage = 20}) async {
    final url = _buildUrl(_commentsEndpoint, {
      'per_page': perPage.toString(),
      'order': 'desc',
    });

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((c) => CommentModel.fromJson(c)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Post a new comment to WordPress using the official web form endpoint
  Future<bool> postComment({
    required int postId,
    required String authorName,
    required String authorEmail,
    required String content,
  }) async {
    const url = 'https://dweepdiary.in/wp-comments-post.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          ..._headers,
          'Content-Type': 'application/x-www-form-urlencoded',
          'Referer': 'https://dweepdiary.in',
        },
        body: {
          'comment_post_ID': postId.toString(),
          'author': authorName.trim(),
          'email': authorEmail.trim().isEmpty ? 'reader@dweepdiary.in' : authorEmail.trim(),
          'comment': content.trim(),
        },
      );

      // WordPress redirects to comment anchor upon success (302 Found) or 200 OK
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (_) {
      return false;
    }
  }

  /// Fetch multiple custom sponsor ads from WordPress category 'sponsors' / 'ads'
  /// and fallback to remote GitHub config
  Future<List<Map<String, dynamic>>> fetchAllSponsorAds() async {
    final List<Map<String, dynamic>> adsList = [];

    // 1. Fetch from WordPress category 'sponsors' or 'ads'
    try {
      final catUrl = _buildUrl(AppConstants.categoriesEndpoint, {'slug': 'sponsors,ads'});
      final catRes = await http.get(Uri.parse(catUrl), headers: _headers);
      if (catRes.statusCode == 200) {
        final List<dynamic> cats = jsonDecode(catRes.body);
        for (final cat in cats) {
          final catId = cat['id'] as int;
          final posts = await fetchPostsByCategory(categoryId: catId, perPage: 10);
          for (final p in posts) {
            if (p.featuredImageUrl != null && p.featuredImageUrl!.isNotEmpty) {
              String redirect = AppConstants.websiteUrl;
              final match = RegExp(r'https?://[^\s<>"]+').firstMatch(p.content);
              if (match != null) {
                redirect = match.group(0)!;
              }
              adsList.add({
                'title': p.cleanTitle,
                'imageUrl': p.featuredImageUrl!,
                'redirectUrl': redirect,
                'sponsoredText': 'Ad',
                'active': true,
              });
            }
          }
        }
      }
    } catch (_) {}

    // 2. Also merge with remote custom_ads.json config
    try {
      final response = await http.get(Uri.parse(_customAdConfigUrl), headers: _headers);
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data['ads'] is List) {
            for (final item in data['ads']) {
              if (item is Map<String, dynamic> && item['active'] != false) {
                adsList.add(item);
              }
            }
          } else if (data['active'] != false && data['imageUrl'] != null) {
            adsList.add(data);
          }
        }
      }
    } catch (_) {}

    return adsList;
  }

  /// Fetch remotely configured custom sponsor ad (updated by admin)
  Future<Map<String, dynamic>?> fetchCustomSponsorAd() async {
    final ads = await fetchAllSponsorAds();
    if (ads.isNotEmpty) {
      return ads.first;
    }
    return null;
  }
}
