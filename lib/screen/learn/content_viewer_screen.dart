import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/course_models.dart';
import '../../service/apiservice/learn_service.dart';
import '../../widget/common_app_bar.dart';

class ContentViewerScreen extends StatefulWidget {
  final int courseId;
  final CourseContent content;
  final bool isCompleted;

  const ContentViewerScreen({
    super.key,
    required this.courseId,
    required this.content,
    required this.isCompleted,
  });

  @override
  State<ContentViewerScreen> createState() => _ContentViewerScreenState();
}

class _ContentViewerScreenState extends State<ContentViewerScreen> {
  bool _isMarking = false;
  bool _isCompleted = false;
  YoutubePlayerController? _youtubeController;
  bool _hasValidVideo = false;
  String _videoId = '';

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    if (widget.content.isVideo) {
      _initVideoController();
    }
  }

  void _initVideoController() {
    final videoUrl = widget.content.videoUrl;
    print('Video URL from content: $videoUrl');

    // Extract video ID from URL
    _videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? '';

    print('Extracted video ID: $_videoId');

    if (_videoId.isNotEmpty) {
      _hasValidVideo = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: _videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          forceHD: false,
          hideControls: false,
          hideThumbnail: false,
          loop: false,
        ),
      );
    }
  }

  @override
  void deactivate() {
    // Pause video when navigating away
    _youtubeController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller:
            _youtubeController ?? YoutubePlayerController(initialVideoId: ''),
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFFD4AF37),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFFD4AF37),
          handleColor: Color(0xFFD4AF37),
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: CommonAppBar(title: widget.content.title),
          body: _buildBody(player),
          bottomNavigationBar: _buildBottomBar(),
        );
      },
    );
  }

  Widget _buildBody(Widget player) {
    if (widget.content.isVideo) {
      return _buildVideoContent(player);
    } else if (widget.content.isMcq) {
      return _buildMcqContent();
    } else {
      return _buildTextContent();
    }
  }

  Widget _buildTextContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentHeader(),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildFormattedText(widget.content.textContent),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    // Parse the text and apply formatting
    final lines = text.split('\n');
    List<Widget> widgets = [];

    for (var line in lines) {
      if (line.isEmpty) {
        widgets.add(SizedBox(height: 8.h));
        continue;
      }

      // Bold headers with **text**
      if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              line.replaceAll('**', ''),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A1F3A),
              ),
            ),
          ),
        );
      }
      // Headers with single **
      else if (line.contains('**')) {
        widgets.add(_buildMixedText(line));
      }
      // Bullet points with -
      else if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 4.h, bottom: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.trim().substring(1).trim(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF0A1F3A),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Numbered lists
      else if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        final match = RegExp(r'^(\d+)\.\s*(.*)').firstMatch(line.trim());
        if (match != null) {
          widgets.add(
            Padding(
              padding: EdgeInsets.only(left: 8.w, top: 4.h, bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1F3A),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: Text(
                        match.group(1)!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      match.group(2)!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF0A1F3A),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
      // Checkmarks ✓ or ☑
      else if (line.contains('✓') || line.contains('☑') || line.contains('✗')) {
        final isCheck = line.contains('✓') || line.contains('☑');
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: 8.w, top: 4.h, bottom: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCheck ? Icons.check_circle : Icons.cancel,
                  color: isCheck ? const Color(0xFF4CAF50) : Colors.red,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    line.replaceAll(RegExp(r'[✓☑✗]'), '').trim(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF0A1F3A),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Regular paragraph
      else {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF0A1F3A),
                height: 1.6,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildMixedText(String line) {
    final parts = line.split('**');
    List<TextSpan> spans = [];
    bool isBold = false;

    for (var part in parts) {
      if (part.isNotEmpty) {
        spans.add(TextSpan(
          text: part,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: const Color(0xFF0A1F3A),
            height: 1.5,
          ),
        ));
      }
      isBold = !isBold;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: RichText(
        text: TextSpan(children: spans),
      ),
    );
  }

  Widget _buildVideoContent(Widget player) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          _hasValidVideo
              ? player
              : Container(
                  height: 220.h,
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_off,
                          size: 48.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Video not available',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContentHeader(),
                if (widget.content.description.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      widget.content.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMcqContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentHeader(),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.quiz,
                  size: 64.sp,
                  color: const Color(0xFF9C27B0),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Quiz Available',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A1F3A),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Test your knowledge with this quiz',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to MCQ quiz screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quiz feature coming soon!'),
                        backgroundColor: Color(0xFF9C27B0),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 14.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F3A), Color(0xFF1A3A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(),
                      size: 14.sp,
                      color: const Color(0xFFD4AF37),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      widget.content.contentType,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Day ${widget.content.day}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (_isCompleted)
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            widget.content.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (widget.content.description.isNotEmpty &&
              !widget.content.isVideo) ...[
            SizedBox(height: 6.h),
            Text(
              widget.content.description,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (widget.content.contentType) {
      case 'VIDEO':
        return Icons.play_circle_outline;
      case 'MCQ':
        return Icons.quiz_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _isCompleted || _isMarking ? null : _markComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCompleted
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  _isCompleted ? const Color(0xFF4CAF50) : Colors.grey.shade300,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: _isMarking
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCompleted
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _isCompleted ? 'Completed' : 'Mark as Complete',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _markComplete() async {
    setState(() => _isMarking = true);

    try {
      final response = await LearnService.markContentComplete(
        widget.courseId,
        widget.content.id,
      );

      if (response.status) {
        setState(() {
          _isCompleted = true;
          _isMarking = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Content marked as complete!'),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
          Navigator.pop(context, true); // Return true to refresh
        }
      } else {
        setState(() => _isMarking = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isMarking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
