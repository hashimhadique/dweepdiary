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
    if (_pendingPost != null) {
      final post = _pendingPost!;
      _pendingPost = null;
      Future.delayed(const Duration(milliseconds: 350), () {
        _navigateToDetail(post);
      });
    } else if (_pendingPostId != null) {
      final id = _pendingPostId!;
      _pendingPostId = null;
      Future.delayed(const Duration(milliseconds: 350), () {
        openPostById(id);
      });
    } else if (_pendingRawUrl != null) {
      final raw = _pendingRawUrl!;
      _pendingRawUrl = null;
      Future.delayed(const Duration(milliseconds: 350), () {
        handleRawRoute(raw);
      });
    }
  }

  Future<void> handleRawRoute(String rawUrl) async {
    if (!isAppReady) {
      _pendingRawUrl = rawUrl;
      return;
    }

    try {
      final uri = Uri.parse(rawUrl);
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
      final post = await _apiService.fetchPostById(postId);
      if (post != null) {
        _navigateToDetail(post);
      }
    } catch (e) {
      debugPrint('Error fetching post for deep link: $e');
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
      final slugOrKeyword = Uri.decodeComponent(segments.last);
      try {
        // 4a. Try exact slug fetch first
        final postBySlug = await _apiService.fetchPostBySlug(slugOrKeyword);
        if (postBySlug != null) {
          _navigateToDetail(postBySlug);
          return;
        }

        // 4b. Fallback to keyword search
        final posts = await _apiService.searchPosts(query: slugOrKeyword, page: 1);
        if (posts.isNotEmpty) {
          _navigateToDetail(posts.first);
        }
      } catch (_) {}
    }
  }

  void _navigateToDetail(PostModel post) {
    if (!isAppReady) {
      _pendingPost = post;
      return;
    }

    if (navigatorKey?.currentState != null) {
      navigatorKey!.currentState!.push(
        MaterialPageRoute(
          builder: (context) => NewsDetailScreen(post: post),
        ),
      );
    }
  }
}
