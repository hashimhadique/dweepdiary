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

  void init(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  Future<void> handleRawRoute(String rawUrl) async {
    try {
      final uri = Uri.parse(rawUrl);
      await handleUri(uri);
    } catch (e) {
      debugPrint('Error parsing raw route for deep link: $e');
    }
  }

  Future<void> handleUri(Uri uri) async {
    debugPrint('Native Deep Link Received: $uri');

    // 1. WordPress Query Param: ?p=4297
    int? postId;
    if (uri.queryParameters.containsKey('p')) {
      postId = int.tryParse(uri.queryParameters['p'] ?? '');
    }

    // 2. Custom Scheme: dweepdiary://post/4297
    if (postId == null && uri.scheme == 'dweepdiary') {
      if (uri.host == 'post' && uri.pathSegments.isNotEmpty) {
        postId = int.tryParse(uri.pathSegments.first);
      }
    }

    if (postId != null && postId > 0) {
      await _openPostById(postId);
      return;
    }

    // 3. Slug or Search by Path
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      final slugOrKeyword = Uri.decodeComponent(segments.last);
      try {
        final posts = await _apiService.searchPosts(query: slugOrKeyword, page: 1);
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
}
