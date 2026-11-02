import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/post_model.dart';
import '../models/category_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Custom HTTP headers to ensure requests pass through security filters
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'User-Agent': 'DweepDiaryApp/1.0.0 (Flutter; Android/iOS)',
  };

  /// Fetch latest news posts with pagination and embedded images/terms
  Future<List<PostModel>> fetchLatestPosts({int page = 1, int perPage = 10}) async {
    final uri = Uri.parse(
      '${AppConstants.postsEndpoint}?_embed&page=$page&per_page=$perPage',
    );

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => PostModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load posts. Status: ${response.statusCode}');
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
    final uri = Uri.parse(
      '${AppConstants.postsEndpoint}?_embed&categories=$categoryId&page=$page&per_page=$perPage',
    );

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => PostModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load category posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch categories with active post counts
  Future<List<CategoryModel>> fetchCategories() async {
    final uri = Uri.parse(
      '${AppConstants.categoriesEndpoint}?per_page=30&hide_empty=true',
    );

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final categories = jsonList.map((item) => CategoryModel.fromJson(item)).toList();
        // Sort with popular categories first
        categories.sort((a, b) => b.count.compareTo(a.count));
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Category network error: $e');
    }
  }

  /// Search news posts by keyword
  Future<List<PostModel>> searchPosts({required String query, int page = 1}) async {
    final uri = Uri.parse(
      '${AppConstants.postsEndpoint}?_embed&search=${Uri.encodeComponent(query)}&page=$page&per_page=15',
    );

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => PostModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search network error: $e');
    }
  }
}
