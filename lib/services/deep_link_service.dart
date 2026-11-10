import 'dart:async';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../screens/news_detail_screen.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final ApiService _apiService = ApiService();
  GlobalKey<NavigatorState>? navigatorKey;

  bool isAppReady = false;
  PostModel? _pendingPost;
  int? _pendingPostId;
  String? _pendingRawUrl;

  void init(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// Called once MainNavigationScreen is fully mounted
  void markAppReady() {
    isAppReady = true;
    debugPrint('DeepLinkService: App is marked ready. Checking pending routes...');

    if (_pendingPost != null) {
      final post = _pendingPost!;
      _pendingPost = null;
      Future.delayed(const Duration(milliseconds: 300), () {
        _navigateToDetail(post);
      });
    } else if (_pendingPostId != null) {
      final id = _pendingPostId!;
      _pendingPostId = null;
      Future.delayed(const Duration(milliseconds: 300), () {
        openPostById(id);
      });
    } else if (_pendingRawUrl != null) {
      final raw = _pendingRawUrl!;
      _pendingRawUrl = null;
      Future.delayed(const Duration(milliseconds: 300), () {
        handleRawRoute(raw);
      });
    }
  }

  Future<void> handleRawRoute(String rawUrl) async {
    String cleanUrl = rawUrl.trim();
    while (cleanUrl.startsWith('/http')) {
      cleanUrl = cleanUrl.substring(1);
    }

    if (cleanUrl.isEmpty || cleanUrl == '/') return;

    if (!isAppReady) {
      debugPrint('DeepLinkService: App not ready yet. Storing pending route: $cleanUrl');
      _pendingRawUrl = cleanUrl;
      return;
    }

    debugPrint('DeepLinkService: Processing route: $cleanUrl');

    try {
      // Direct regex match for ?p=123 or &p=123 or ?id=123
      final pMatch = RegExp(r'[?&](?:p|id)=(\d+)').firstMatch(cleanUrl);
      if (pMatch != null) {
        final id = int.tryParse(pMatch.group(1)!);
        if (id != null && id > 0) {
          await openPostById(id);
          return;
        }
      }

      final uri = Uri.parse(cleanUrl);
      await handleUri(uri);
    } catch (e) {
      debugPrint('Error parsing raw route for deep link: $e');
    }
  }

  Future<void> openPostById(int postId) async {
    if (!isAppReady) {
      _pendingPostId = postId;
      return;
    }

    try {
      debugPrint('DeepLinkService: Fetching post by ID $postId...');
      final post = await _apiService.fetchPostById(postId);
      if (post != null) {
        debugPrint('DeepLinkService: Post loaded successfully: ${post.title}');
        _navigateToDetail(post);
      } else {
        debugPrint('DeepLinkService: Post with ID $postId was not found on server.');
      }
    } catch (e) {
      debugPrint('Error fetching post for deep link: $e');
    }
  }

  Future<void> openPostBySlug(String slugOrKeyword) async {
    final cleanSlug = Uri.decodeComponent(slugOrKeyword).trim().replaceAll('/', '');
    if (cleanSlug.isEmpty) return;

    try {
      debugPrint('DeepLinkService: Fetching post by slug "$cleanSlug"...');
      final postBySlug = await _apiService.fetchPostBySlug(cleanSlug);
      if (postBySlug != null) {
        _navigateToDetail(postBySlug);
        return;
      }

      final posts = await _apiService.searchPosts(query: cleanSlug, page: 1);
      if (posts.isNotEmpty) {
        _navigateToDetail(posts.first);
      }
    } catch (e) {
      debugPrint('DeepLink slug error: $e');
    }
  }

  Future<void> handleUri(Uri uri) async {
    debugPrint('Native Deep Link Received: $uri');

    // 1. WordPress Query Param: ?p=4343 or ?id=4343
    int? postId;
    if (uri.queryParameters.containsKey('p')) {
      postId = int.tryParse(uri.queryParameters['p'] ?? '');
    } else if (uri.queryParameters.containsKey('id')) {
      postId = int.tryParse(uri.queryParameters['id'] ?? '');
    }

    // 2. Custom Scheme: dweepdiary://post/4343 or dweepdiary://4343
    if (postId == null && uri.scheme == 'dweepdiary') {
      if (uri.host == 'post' && uri.pathSegments.isNotEmpty) {
        postId = int.tryParse(uri.pathSegments.first);
      } else if (int.tryParse(uri.host) != null) {
        postId = int.tryParse(uri.host);
      }
    }

    // 3. Any numeric path segment (e.g. /archives/4343 or /4343)
    if (postId == null) {
      for (final seg in uri.pathSegments) {
        final parsed = int.tryParse(seg);
        if (parsed != null && parsed > 0) {
          postId = parsed;
          break;
        }
      }
    }

    if (postId != null && postId > 0) {
      await openPostById(postId);
      return;
    }

    // 4. Slug or Search by Path
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      final lastSegment = segments.last;
      await openPostBySlug(lastSegment);
    }
  }

  void _navigateToDetail(PostModel post) {
    if (!isAppReady) {
      _pendingPost = post;
      return;
    }

    void doPush() {
      final nav = navigatorKey?.currentState;
      if (nav != null) {
        nav.push(
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(post: post),
          ),
        );
      }
    }

    if (navigatorKey?.currentState != null) {
      doPush();
    } else {
      Future.delayed(const Duration(milliseconds: 350), doPush);
    }
  }
}
