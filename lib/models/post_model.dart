import 'package:html/parser.dart' as html_parser;

class PostModel {
  final int id;
  final String title;
  final String cleanTitle;
  final String content;
  final String excerpt;
  final String cleanExcerpt;
  String get cleanContent => _stripHtml(content);
  final String link;
  final DateTime date;
  final String? featuredImageUrl;
  final String categoryName;
  final int categoryId;
  final String authorName;

  PostModel({
    required this.id,
    required this.title,
    required this.cleanTitle,
    required this.content,
    required this.excerpt,
    required this.cleanExcerpt,
    required this.link,
    required this.date,
    this.featuredImageUrl,
    required this.categoryName,
    required this.categoryId,
    required this.authorName,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // 1. Raw & Clean Title
    final rawTitle = json['title']?['rendered'] ?? '';
    final cleanTitle = _stripHtml(rawTitle);

    // 2. Raw & Clean Content and Excerpt
    final rawContent = json['content']?['rendered'] ?? '';
    final rawExcerpt = json['excerpt']?['rendered'] ?? '';
    final cleanExcerpt = _stripHtml(rawExcerpt);

    // 3. Date
    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      parsedDate = DateTime.tryParse(json['date']) ?? DateTime.now();
    }

    // 4. Featured Image: direct jetpack / featured_image_src, fallback to _embedded
    String? imageUrl = json['featured_image_src'] ?? json['jetpack_featured_media_url'];
    if (imageUrl == null || imageUrl.isEmpty) {
      try {
        final embedded = json['_embedded'];
        if (embedded != null && embedded['wp:featuredmedia'] != null) {
          final mediaList = embedded['wp:featuredmedia'] as List;
          if (mediaList.isNotEmpty) {
            imageUrl = mediaList[0]['source_url'];
          }
        }
      } catch (_) {}
    }

    // Fallback: search <img> tag in content
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = _extractImageFromContent(rawContent);
    }

    // 5. Category from _embedded
    String categoryName = 'News';
    int categoryId = 5;
    try {
      final embedded = json['_embedded'];
      if (embedded != null && embedded['wp:term'] != null) {
        final termList = embedded['wp:term'] as List;
        if (termList.isNotEmpty && termList[0] is List && (termList[0] as List).isNotEmpty) {
          final firstCategory = termList[0][0];
          categoryName = firstCategory['name'] ?? 'News';
          categoryId = firstCategory['id'] ?? 5;
        }
      }
    } catch (_) {}

    // 6. Author name
    String authorName = 'Dweep Diary Desk';
    try {
      final embedded = json['_embedded'];
      if (embedded != null && embedded['author'] != null) {
        final authors = embedded['author'] as List;
        if (authors.isNotEmpty) {
          authorName = authors[0]['name'] ?? 'Dweep Diary Desk';
        }
      }
    } catch (_) {}

    return PostModel(
      id: json['id'] ?? 0,
      title: rawTitle,
      cleanTitle: cleanTitle.isEmpty ? 'വാർത്ത' : cleanTitle,
      content: rawContent,
      excerpt: rawExcerpt,
      cleanExcerpt: cleanExcerpt,
      link: json['link'] ?? 'https://dweepdiary.in',
      date: parsedDate,
      featuredImageUrl: imageUrl,
      categoryName: categoryName,
      categoryId: categoryId,
      authorName: authorName,
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'title': title,
      'cleanTitle': cleanTitle,
      'content': content,
      'excerpt': excerpt,
      'cleanExcerpt': cleanExcerpt,
      'link': link,
      'date': date.toIso8601String(),
      'featuredImageUrl': featuredImageUrl,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'authorName': authorName,
    };
  }

  factory PostModel.fromLocalMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      cleanTitle: map['cleanTitle'] ?? '',
      content: map['content'] ?? '',
      excerpt: map['excerpt'] ?? '',
      cleanExcerpt: map['cleanExcerpt'] ?? '',
      link: map['link'] ?? 'https://dweepdiary.in',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      featuredImageUrl: map['featuredImageUrl'],
      categoryName: map['categoryName'] ?? 'വാർത്തകൾ',
      categoryId: map['categoryId'] ?? 5,
      authorName: map['authorName'] ?? 'Dweep Diary Desk',
    );
  }

  static String _stripHtml(String htmlString) {
    try {
      final document = html_parser.parse(htmlString);
      final String parsedString = html_parser.parse(document.body?.text).documentElement?.text ?? '';
      return parsedString.replaceAll('&nbsp;', ' ').trim();
    } catch (_) {
      return htmlString;
    }
  }

  static String? _extractImageFromContent(String htmlContent) {
    try {
      final match = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(htmlContent);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }
}
