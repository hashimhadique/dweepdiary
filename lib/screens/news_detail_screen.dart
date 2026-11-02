import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/parser.dart' as html_parser;
import '../constants/app_colors.dart';
import '../models/post_model.dart';
import '../services/bookmark_service.dart';
import '../services/tts_service.dart';
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

  bool _isBookmarked = false;
  bool _isPlayingAudio = false;
  double _fontSize = 17.0;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _initTts();
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
  }

  Future<void> _checkBookmarkStatus() async {
    final status = await _bookmarkService.isBookmarked(widget.post.id);
    if (mounted) {
      setState(() {
        _isBookmarked = status;
      });
    }
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
      final textToRead = '${widget.post.cleanTitle}. ${widget.post.cleanExcerpt}';
      _ttsService.speak(textToRead);
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
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
    final formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(widget.post.date);
    final cleanContent = _cleanHtml(widget.post.content);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 1. Text-to-Speech Audio Play/Stop Button
          IconButton(
            tooltip: _isPlayingAudio ? 'Stop Audio' : 'Listen',
            icon: Icon(
              _isPlayingAudio ? Icons.volume_up_rounded : Icons.volume_up_outlined,
              color: _isPlayingAudio ? AppColors.primary : AppColors.textPrimary,
            ),
            onPressed: _toggleAudio,
          ),

          // 2. Adjust Font Size Dialog
          IconButton(
            tooltip: 'Font Size',
            icon: const Icon(Icons.format_size_rounded, color: AppColors.textPrimary),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Adjust Reading Font Size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
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
                                  if (_fontSize < 26) {
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
              color: _isBookmarked ? AppColors.primary : AppColors.textPrimary,
            ),
            onPressed: _toggleBookmark,
          ),

          // 4. WhatsApp / Social Share
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary),
            onPressed: () {
              Share.share(
                '${widget.post.cleanTitle}\n\nRead more: ${widget.post.link}\n\nDownload Dweep Diary Mobile App: https://dweepdiary.in',
              );
            },
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
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.post.categoryName,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Headline
            Text(
              widget.post.cleanTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
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
                    color: AppColors.primaryLight,
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 16),

            // Audio Player Bar Indicator (if active)
            if (_isPlayingAudio)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Playing audio news...',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop_circle, color: AppColors.primary),
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
                color: AppColors.textPrimary,
                height: 1.8,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 24),

            // Ad Banner Widget (Inside Article)
            const AdBannerWidget(),
            const SizedBox(height: 16),

            // Share Box (WhatsApp Priority)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Text(
                    'Share this story with friends',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
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
                    onPressed: () {
                      Share.share(
                        '${widget.post.cleanTitle}\n\nRead more: ${widget.post.link}\n\nDownload Dweep Diary Mobile App: https://dweepdiary.in',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
