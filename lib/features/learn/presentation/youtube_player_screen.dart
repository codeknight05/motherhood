import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/knowledge_resource_model.dart';

/// Extracts a YouTube video ID from various YouTube URL formats.
String? extractYouTubeId(String url) {
  final patterns = [
    RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
    RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
    RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})'),
    RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]{11})'),
  ];
  for (final pattern in patterns) {
    final match = pattern.firstMatch(url);
    if (match != null) return match.group(1);
  }
  return null;
}

/// Returns true if the URL is a YouTube link.
bool isYouTubeUrl(String url) => extractYouTubeId(url) != null;

class YouTubePlayerScreen extends StatefulWidget {
  final KnowledgeResource resource;

  const YouTubePlayerScreen({super.key, required this.resource});

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    final videoId = extractYouTubeId(widget.resource.sourceUrl);
    final embedUrl = videoId != null
        ? 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1'
        : widget.resource.sourceUrl;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p),
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.resource.title,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.resource.sourceName,
              style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 2,
              color: AppColors.primary,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          // Video player (16:9)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: WebViewWidget(controller: _controller),
          ),
          // Info below
          Expanded(
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.resource.title,
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.resource.sourceName,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.play_circle_outline_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(widget.resource.readTime,
                          style: AppTextStyles.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.resource.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
