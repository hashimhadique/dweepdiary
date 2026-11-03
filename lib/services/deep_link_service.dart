import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../screens/news_detail_screen.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  final ApiService _apiService = ApiService();
  StreamSubscription<Uri>? _linkSubscription;
  GlobalKey<NavigatorState>? navigatorKey;

  void init(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // 1. Initial link if cold-started from URL
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        // Small delay to ensure splash/UI is initialized
        Future.delayed(const Duration(milliseconds: 1200), () {
          _handleUri(initialUri);
        });
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }

    // 2. Stream for links when app is running/backgrounded
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri),
      onError: (err) => debugPrint('Deep link stream error: $err'),
    );
  }

  Future<void> _handleUri(Uri uri) async {
    debugPrint('Received Deep Link: $uri');

    // Case 1: WordPress query format: https://dweepdiary.in/?p=4297
    int? postId;
    if (uri.queryParameters.containsKey('p')) {
      postId = int.tryParse(uri.queryParameters['p'] ?? '');
    }

    // Case 2: Custom scheme: dweepdiary://post/4297
    if (postId == null && uri.scheme == 'dweepdiary') {
      if (uri.host == 'post' && uri.pathSegments.isNotEmpty) {
        postId = int.tryParse(uri.pathSegments.first);
      }
    }

    if (postId != null && postId > 0) {
      await _openPostById(postId);
      return;
    }

    // Case 3: Slug URL, e.g. https://dweepdiary.in/headline-slug/
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      final slugOrSearch = Uri.decodeComponent(segments.last);
      try {
        final posts = await _apiService.searchPosts(query: slugOrSearch, page: 1);
        if (posts.isNotEmpty) {
          _navigateToDetail(posts.first);
        }
      } catch (_) {}
    }
  }

  Future<void> _openPostById(int postId) async {
    try {
      final post = await _apiService.fetchPostById(postId);
      if (post != null) {
        _navigateToDetail(post);
      }
    } catch (e) {
      debugPrint('Error fetching post for deep link: $e');
    }
  }

  void _navigateToDetail(PostModel post) {
    if (navigatorKey?.currentState != null) {
      navigatorKey!.currentState!.push(
        MaterialPageRoute(
          builder: (context) => NewsDetailScreen(post: post),
        ),
      );
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
