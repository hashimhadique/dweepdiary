import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/post_model.dart';
import '../models/category_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Valid standard mobile User-Agent to seamlessly pass hosting Mod_Security filters
  static const Map<String, String> _headers = {
    'Accept': 'application/json, text/plain, */*',
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  };

  /// Helper to build query URL correctly handling '?' and '&'
  String _buildUrl(String endpoint, Map<String, String> params) {
    final separator = endpoint.contains('?') ? '&' : '?';
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$endpoint$separator$queryString';
  }

  /// Fetch latest news posts with pagination and embedded images/terms
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
        return jsonList.map((item) => PostModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load posts (Status: ${response.statusCode})');
      }
    } catch (e) {
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
        final categories = jsonList.map((item) => CategoryModel.fromJson(item)).toList();
        categories.sort((a, b) => b.count.compareTo(a.count));
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
}
