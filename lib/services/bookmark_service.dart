import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

class BookmarkService {
  static const String _bookmarkKey = 'dweep_diary_saved_bookmarks';
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  /// Retrieve all bookmarked posts from local storage
  Future<List<PostModel>> getBookmarkedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bookmarkKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => PostModel.fromLocalMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Check whether an article is already bookmarked
  Future<bool> isBookmarked(int postId) async {
    final list = await getBookmarkedPosts();
    return list.any((p) => p.id == postId);
  }

  /// Toggle bookmark status for an article
  Future<bool> toggleBookmark(PostModel post) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBookmarkedPosts();

    final existingIndex = list.indexWhere((p) => p.id == post.id);
    bool isNowSaved;

    if (existingIndex >= 0) {
      list.removeAt(existingIndex);
      isNowSaved = false;
    } else {
      list.insert(0, post);
      isNowSaved = true;
    }

    final encoded = jsonEncode(list.map((p) => p.toLocalMap()).toList());
    await prefs.setString(_bookmarkKey, encoded);
    return isNowSaved;
  }
}
