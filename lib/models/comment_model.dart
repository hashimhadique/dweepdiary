import 'package:html/parser.dart' as html_parser;

class CommentModel {
  final int id;
  final int postId;
  final String authorName;
  final DateTime date;
  final String content;
  final String cleanContent;
  final String? postTitle;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.date,
    required this.content,
    required this.cleanContent,
    this.postTitle,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, {String? postTitle}) {
    final rawContent = json['content']?['rendered'] ?? '';
    final clean = _stripHtml(rawContent);

    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      parsedDate = DateTime.tryParse(json['date']) ?? DateTime.now();
    }

    return CommentModel(
      id: json['id'] ?? 0,
      postId: json['post'] ?? 0,
      authorName: (json['author_name'] != null && json['author_name'].toString().trim().isNotEmpty)
          ? json['author_name']
          : 'Anonymous Reader',
      date: parsedDate,
      content: rawContent,
      cleanContent: clean.isEmpty ? '...' : clean,
      postTitle: postTitle,
    );
  }

  static String _stripHtml(String htmlString) {
    try {
      final document = html_parser.parse(htmlString);
      final text = document.body?.text ?? '';
      return text.replaceAll('&nbsp;', ' ').trim();
    } catch (_) {
      return htmlString;
    }
  }
}
