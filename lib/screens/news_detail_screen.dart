import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/parser.dart' as html_parser;
import '../constants/app_colors.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/bookmark_service.dart';
import '../services/tts_service.dart';
import '../services/api_service.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner_widget.dart';

class NewsDetailScreen extends StatefulWidget {
  final PostModel post;

  const NewsDetailScreen({super.key, required this.post});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  final TtsService _ttsService = TtsService();
  final ApiService _apiService = ApiService();

  bool _isBookmarked = false;
  bool _isPlayingAudio = false;
  int _currentAudioChunk = 0;
  int _totalAudioChunks = 0;
  double _fontSize = 17.0;

  // Related posts
  List<PostModel> _relatedPosts = [];
  bool _isLoadingRelated = true;

  // Comments
  List<CommentModel> _comments = [];
  bool _isLoadingComments = true;
  bool _isSubmittingComment = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _initTts();
    _loadRelatedArticles();
    _loadComments();

    // Trigger interstitial ad counter
    AdService().onArticleOpened();
  }

  void _initTts() {
    _ttsService.init();
    _ttsService.onStateChanged = (isPlaying) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = isPlaying;
        });
      }
    };
    _ttsService.onProgressChanged = (current, total) {
      if (mounted) {
        setState(() {
          _currentAudioChunk = current;
          _totalAudioChunks = total;
        });
      }
    };
  }

  Future<void> _checkBookmarkStatus() async {
    final status = await _bookmarkService.isBookmarked(widget.post.id);
    if (mounted) {
      setState(() {
        _isBookmarked = status;
      });
    }
  }

  Future<void> _shareArticle() async {
    final shareText = '''${widget.post.cleanTitle}

Read more: ${widget.post.link}

📲 Download Dweep Diary Mobile App:
https://play.google.com/store/apps/details?id=in.dweepdiary.app''';

    try {
      final imgUrl = widget.post.featuredImageUrl;
      if (imgUrl != null && imgUrl.isNotEmpty) {
        final uri = Uri.parse(imgUrl);
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final tempDir = Directory.systemTemp;
          final file = File('${tempDir.path}/dweepdiary_share_${widget.post.id}.jpg');
          await file.writeAsBytes(response.bodyBytes);
          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'image/jpeg')],
            text: shareText,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Share image error: $e');
    }

    // Fallback if image download fails or device is offline
    await Share.share(shareText);
  }

  Future<void> _toggleBookmark() async {
    final newStatus = await _bookmarkService.toggleBookmark(widget.post);
    if (mounted) {
      setState(() {
        _isBookmarked = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Article saved to bookmarks' : 'Bookmark removed',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _toggleAudio() {
    if (_isPlayingAudio) {
      _ttsService.stop();
    } else {
      final cleanContent = _cleanHtml(widget.post.content);
      final bodyText = cleanContent.isNotEmpty ? cleanContent : widget.post.cleanExcerpt;
      final fullTextToRead = '${widget.post.cleanTitle}. $bodyText';
      _ttsService.speakFullArticle(fullTextToRead);
    }
  }

  Future<void> _loadRelatedArticles() async {
    try {
      final related = await _apiService.fetchRelatedPosts(
        categoryId: widget.post.categoryId,
        excludePostId: widget.post.id,
        limit: 4,
      );
      if (mounted) {
        setState(() {
          _relatedPosts = related;
          _isLoadingRelated = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRelated = false);
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _apiService.fetchCommentsForPost(widget.post.id);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _submitComment() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final text = _commentController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment')),
      );
      return;
    }

    setState(() => _isSubmittingComment = true);

    final success = await _apiService.postComment(
      postId: widget.post.id,
      authorName: name.isEmpty ? 'Reader' : name,
      authorEmail: email.isEmpty ? 'reader@dweepdiary.in' : email,
      content: text,
    );

    if (!mounted) return;
    setState(() => _isSubmittingComment = false);

    if (success) {
      final newComment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch,
        postId: widget.post.id,
        authorName: name.isEmpty ? 'Reader' : name,
        date: DateTime.now(),
        content: text,
        cleanContent: text,
      );
      setState(() {
        _comments.insert(0, newComment);
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('കമന്റ് വിജയകരമായി പോസ്റ്റ് ചെയ്തു!'),
          backgroundColor: AppColors.tagGreen,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Even if WordPress holds it for moderation or returns hold
      final pendingComment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch,
        postId: widget.post.id,
        authorName: name.isEmpty ? 'Reader' : name,
        date: DateTime.now(),
        content: text,
        cleanContent: text,
      );
      setState(() {
        _comments.insert(0, pendingComment);
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('കമന്റ് ലഭിച്ചു. പരിശോധിച്ച് പ്രസിദ്ധീകരിക്കുന്നതാണ്.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _nameController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _cleanHtml(String htmlContent) {
    try {
      final doc = html_parser.parse(htmlContent);
      return doc.body?.text.replaceAll('&nbsp;', ' ').trim() ?? '';
    } catch (_) {
      return htmlContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(widget.post.date);
    final cleanContent = _cleanHtml(widget.post.content);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 1. Text-to-Speech Audio Play/Stop Button
          IconButton(
            tooltip: _isPlayingAudio ? 'Stop Audio' : 'Listen',
            icon: Icon(
              _isPlayingAudio ? Icons.volume_up_rounded : Icons.volume_up_outlined,
              color: _isPlayingAudio ? AppColors.primary : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
            onPressed: _toggleAudio,
          ),

          // 2. Adjust Font Size Dialog
          IconButton(
            tooltip: 'Font Size',
            icon: Icon(
              Icons.format_size_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => StatefulBuilder(
                  builder: (context, setModalState) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Adjust Reading Font Size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 28),
                                onPressed: () {
                                  if (_fontSize > 14) {
                                    setState(() => _fontSize -= 1);
                                    setModalState(() {});
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '${_fontSize.toInt()} px',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 28),
                                onPressed: () {
                                  if (_fontSize < 28) {
                                    setState(() => _fontSize += 1);
                                    setModalState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // 3. Bookmark Article
          IconButton(
            tooltip: 'Bookmark',
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? AppColors.primary : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
            onPressed: _toggleBookmark,
          ),

          // 4. WhatsApp / Social Share
          IconButton(
            tooltip: 'Share',
            icon: Icon(
              Icons.share_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            onPressed: _shareArticle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge & Published Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primary.withOpacity(0.25)
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.post.categoryName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Headline
            Text(
              widget.post.cleanTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Author Byline
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const Icon(Icons.person, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.post.authorName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Featured Image
            if (widget.post.featuredImageUrl != null && widget.post.featuredImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: widget.post.featuredImageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 220,
                    color: isDark ? const Color(0xFF1E293B) : AppColors.primaryLight,
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 16),

            // Sequential TTS Audio Player Bar Indicator (with real progress)
            if (_isPlayingAudio)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reading full news aloud...',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (_totalAudioChunks > 0)
                            Text(
                              'Section $_currentAudioChunk of $_totalAudioChunks',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop_circle_rounded, color: AppColors.primary, size: 28),
                      onPressed: _toggleAudio,
                    ),
                  ],
                ),
              ),

            // Full Clean Article Content
            Text(
              cleanContent.isNotEmpty ? cleanContent : widget.post.cleanExcerpt,
              style: TextStyle(
                fontSize: _fontSize,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                height: 1.85,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 24),

            // WhatsApp Share Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppColors.divider,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Share this story with friends',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_rounded),
                    label: const Text(
                      'Share on WhatsApp',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _shareArticle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // In-article Ad Banner
            const AdBannerWidget(),
            const SizedBox(height: 24),

            // Related Articles Section
            if (_relatedPosts.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Related News',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _relatedPosts.length,
                itemBuilder: (context, index) {
                  final related = _relatedPosts[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailScreen(post: related),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : AppColors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (related.featuredImageUrl != null &&
                              related.featuredImageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: related.featuredImageUrl!,
                                width: 75,
                                height: 60,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            )
                          else
                            Container(
                              width: 75,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.newspaper_rounded, color: AppColors.primary),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              related.cleanTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Bottom In-Article Ad Banner (Before Reader Comments)
            const AdBannerWidget(),
            const SizedBox(height: 24),

            // Comments Section Header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Reader Comments (${_comments.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Write a comment input box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppColors.divider,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave a Comment',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Your Name (optional)',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts here...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmittingComment ? null : _submitComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: _isSubmittingComment
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Post Comment'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Comments List
            if (_isLoadingComments)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No comments yet. Be the first to comment!',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final c = _comments[index];
                  final cDate = DateFormat('dd MMM yyyy, hh:mm a').format(c.date);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : AppColors.divider,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.authorName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              cDate,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.cleanContent,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
