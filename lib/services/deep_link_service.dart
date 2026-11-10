import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../screens/news_detail_screen.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  static const MethodChannel _channel = MethodChannel('in.dweepdiary.app/deeplink');

  final ApiService _apiService = ApiService();
  GlobalKey<NavigatorState>? navigatorKey;

  bool isAppReady = false;
  PostModel? _pendingPost;
  int? _pendingPostId;
  String? _pendingRawUrl;
  bool _isFetching = false;

  void init(GlobalKey<NavigatorState> key) {
    navigatorKey = key;

    // Listen for deep links sent while the app is running in background / foreground
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final dynamic arg = call.arguments;
        if (arg is String && arg.isNotEmpty) {
          debugPrint('Native MethodChannel received deep link: $arg');
          handleRawRoute(arg);
        }
      }
    });

    // Check if app was cold-started from an Android App Link / VIEW Intent
    _checkInitialNativeUrl();
  }

  Future<void> _checkInitialNativeUrl() async {
    try {
      final String? initial = await _channel.invokeMethod<String>('getInitialUrl');
      if (initial != null && initial.isNotEmpty) {
        debugPrint('Native MethodChannel got cold-start initial URL: $initial');
        handleRawRoute(initial);
      }
    } catch (e) {
      debugPrint('Native channel getInitialUrl error: $e');
    }
  }

  /// Called once MainNavigationScreen is fully mounted
  void markAppReady() {
    isAppReady = true;
    debugPrint('DeepLinkService: App is marked ready. Checking pending routes...');

    // Allow page transition animation to finish before pushing detail screen
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_pendingPost != null) {
        final post = _pendingPost!;
        _pendingPost = null;
        _pendingPostId = null;
        _pendingRawUrl = null;
        _navigateToDetail(post);
      } else if (_pendingPostId != null) {
        final id = _pendingPostId!;
        openPostById(id);
      } else if (_pendingRawUrl != null) {
        final raw = _pendingRawUrl!;
        handleRawRoute(raw);
      }
    });
  }

  Future<void> handleRawRoute(String rawUrl) async {
    String cleanUrl = rawUrl.trim();
    while (cleanUrl.startsWith('/http')) {
      cleanUrl = cleanUrl.substring(1);
    }

    if (cleanUrl.isEmpty || cleanUrl == '/') return;

    debugPrint('DeepLinkService: Processing route: $cleanUrl');

    try {
      // 1. Direct regex match for ?p=123, &p=123, ?id=123 or &id=123
      final pMatch = RegExp(r'[?&](?:p|id)=(\d+)').firstMatch(cleanUrl);
      if (pMatch != null) {
        final id = int.tryParse(pMatch.group(1)!);
        if (id != null && id > 0) {
          openPostById(id);
          return;
        }
      }

      // 2. Custom Scheme: dweepdiary://post/4343 or dweepdiary://4343
      final customMatch = RegExp(r'dweepdiary://(?:post/)?(\d+)').firstMatch(cleanUrl);
      if (customMatch != null) {
        final id = int.tryParse(customMatch.group(1)!);
        if (id != null && id > 0) {
          openPostById(id);
          return;
        }
      }

      // 3. Fallback: Parse URI components
      final uri = Uri.tryParse(cleanUrl);
      if (uri != null) {
        await handleUri(uri);
      }
    } catch (e) {
      debugPrint('Error parsing raw route for deep link: $e');
    }
  }

  Future<void> openPostById(int postId) async {
    debugPrint('DeepLinkService: openPostById($postId), isAppReady=$isAppReady');
    _pendingPostId = postId;

    if (_isFetching) return;
    _isFetching = true;

    try {
      final post = await _apiService.fetchPostById(postId);
      _isFetching = false;
      if (post != null) {
        debugPrint('DeepLinkService: Post loaded successfully: ${post.cleanTitle}');
        _pendingPost = post;
        if (isAppReady) {
          _pendingPost = null;
          _pendingPostId = null;
          _pendingRawUrl = null;
          _navigateToDetail(post);
        }
      } else {
        debugPrint('DeepLinkService: Post with ID $postId was not found on server.');
      }
    } catch (e) {
      _isFetching = false;
      debugPrint('Error fetching post for deep link: $e');
    }
  }

  Future<void> openPostBySlug(String slugOrKeyword) async {
    final cleanSlug = Uri.decodeComponent(slugOrKeyword).trim().replaceAll('/', '');
    if (cleanSlug.isEmpty) return;

    if (!isAppReady) {
      _pendingRawUrl = cleanSlug;
      return;
    }

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
    debugPrint('Native Deep Link Uri: $uri');

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

    // 3. Numeric path segment (e.g. /archives/4343 or /4343)
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
      openPostById(postId);
      return;
    }

    // 4. Slug or Keyword search
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      final lastSegment = segments.last;
      openPostBySlug(lastSegment);
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
        debugPrint('DeepLinkService: Pushing NewsDetailScreen for ${post.id}');
        nav.push(
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(post: post),
          ),
        );
      } else {
        debugPrint('DeepLinkService: navigatorKey.currentState is null, retrying...');
        Future.delayed(const Duration(milliseconds: 300), () {
          navigatorKey?.currentState?.push(
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(post: post),
            ),
          );
        });
      }
    }

    doPush();
  }
}
