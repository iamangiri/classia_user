import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/course_models.dart';
import '../../service/apiservice/learn_service.dart';
import '../../widget/common_app_bar.dart';
import 'content_viewer_screen.dart';

class CourseContentScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const CourseContentScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  bool _isLoading = true;
  String _error = '';
  List<CourseContent> _contents = [];
  List<int> _completedIds = [];
  int _completedCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Load content and progress in parallel
      final contentFuture =
          LearnService.getCourseContent(widget.courseId, limit: 50);
      final progressFuture = LearnService.getCourseProgress(widget.courseId);

      final results = await Future.wait([contentFuture, progressFuture]);
      final contentResponse = results[0] as CourseContentResponse;
      final progressResponse = results[1] as CourseProgressResponse;

      if (contentResponse.status) {
        // Sort contents by day and order index
        final sortedContents = contentResponse.data.contents
          ..sort((a, b) {
            if (a.day != b.day) return a.day.compareTo(b.day);
            return a.orderIndex.compareTo(b.orderIndex);
          });

        setState(() {
          _contents = sortedContents;
          _completedIds = progressResponse.data.completedIds;
          _completedCount = progressResponse.data.enrollment.completedContents;
          _totalCount = progressResponse.data.enrollment.totalContents;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = contentResponse.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isContentCompleted(int contentId) {
    return _completedIds.contains(contentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CommonAppBar(title: widget.courseName),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.red.shade300),
            SizedBox(height: 16.h),
            Text(
              'Failed to load content',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A1F3A),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: _loadContent,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              'No Content Available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A1F3A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Content will be added soon',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildProgressHeader(),
        if (_completedCount == _totalCount && _totalCount > 0)
          _buildCertificateRequestSection(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadContent,
            color: const Color(0xFFD4AF37),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _contents.length,
              itemBuilder: (context, index) =>
                  _buildContentCard(_contents[index], index + 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateRequestSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.workspace_premium,
              color: const Color(0xFFD4AF37),
              size: 28.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎉 Course Completed!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'You are eligible for a certificate',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: _requestCertificate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Get Certificate',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestCertificate() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      ),
    );

    try {
      final response = await LearnService.requestCertificate(widget.courseId);
      Navigator.pop(context); // Close loading

      if (response.status) {
        _showCertificateSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCertificateSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Certificate Requested!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A1F3A),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: const Color(0xFFD4AF37),
                      size: 32.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Check Your Email',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A1F3A),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'You will receive your certificate on your registered email within 24 hours.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'You can also view your certificate in the Certificates section of your profile.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Great!',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final progress = _totalCount > 0 ? _completedCount / _totalCount : 0.0;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F3A), Color(0xFF1A3A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1F3A).withOpacity(0.3),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60.w,
                height: 60.w,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD4AF37),
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Progress',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$_completedCount of $_totalCount lessons completed',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(CourseContent content, int index) {
    final isCompleted = _isContentCompleted(content.id);
    final iconData = _getContentIcon(content.contentType);
    final typeColor = _getContentTypeColor(content.contentType);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: isCompleted
            ? Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: () => _openContent(content),
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check_circle,
                            color: const Color(0xFF4CAF50),
                            size: 22.sp,
                          )
                        : Icon(
                            iconData,
                            color: typeColor,
                            size: 22.sp,
                          ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              content.contentType,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: typeColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Day ${content.day}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        content.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A1F3A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (content.description.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          content.description,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getContentIcon(String type) {
    switch (type) {
      case 'VIDEO':
        return Icons.play_circle_outline;
      case 'MCQ':
        return Icons.quiz_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  Color _getContentTypeColor(String type) {
    switch (type) {
      case 'VIDEO':
        return const Color(0xFFE91E63);
      case 'MCQ':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF2196F3);
    }
  }

  void _openContent(CourseContent content) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ContentViewerScreen(
          courseId: widget.courseId,
          content: content,
          isCompleted: _isContentCompleted(content.id),
        ),
      ),
    );

    // Refresh if content was marked as completed
    if (result == true) {
      _loadContent();
    }
  }
}
