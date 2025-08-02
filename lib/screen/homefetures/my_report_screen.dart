import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../themes/app_colors.dart';

class DownloadReportsScreen extends StatefulWidget {
  const DownloadReportsScreen({super.key});

  @override
  _DownloadReportsScreenState createState() => _DownloadReportsScreenState();
}

class _DownloadReportsScreenState extends State<DownloadReportsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDownloading = false;
  List<Map<String, dynamic>> _downloadHistory = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadDownloadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDownloadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('report_downloads') ?? [];
    setState(() {
      _downloadHistory = history.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _saveDownload(String reportType) async {
    final prefs = await SharedPreferences.getInstance();
    final download = {
      'reportType': reportType,
      'timestamp': DateTime.now().toIso8601String(),
    };
    final history = prefs.getStringList('report_downloads') ?? [];
    history.add(jsonEncode(download));
    await prefs.setStringList('report_downloads', history);
    setState(() {
      _downloadHistory.add(download);
    });
  }

  Future<void> _confirmDownload(String reportType) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: AppColors.surfaceColor?.withOpacity(0.95) ?? Colors.grey[50]!.withOpacity(0.95),
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.file_download_outlined,
                  size: 48.sp,
                  color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Download Report',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Would you like to download the $reportType?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText ?? Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        side: BorderSide(color: AppColors.error ?? Colors.red),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error ?? Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 2,
                      ),
                      child: Text(
                        'Download',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await _simulateDownload(reportType);
    }
  }

  Future<void> _simulateDownload(String reportType) async {
    setState(() => _isDownloading = true);
    // Simulate download process
    await Future.delayed(const Duration(seconds: 2));
    await _saveDownload(reportType);
    setState(() => _isDownloading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text('$reportType downloaded successfully!'),
            ],
          ),
          backgroundColor: AppColors.success ?? Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
    }
  }

  List<Map<String, dynamic>> get reportTypes => [
    {
      'title': 'Portfolio Report',
      'description': 'Complete overview of your investment portfolio with current valuation and performance metrics',
      'icon': Icons.pie_chart_outline,
      'color': const Color(0xFF6366F1),
    },
    {
      'title': 'Family Report',
      'description': 'Consolidated view of all family members\' investments and financial planning details',
      'icon': Icons.family_restroom,
      'color': const Color(0xFF10B981),
    },
    {
      'title': 'Capital Gains Report',
      'description': 'Detailed breakdown of realized and unrealized capital gains for tax planning',
      'icon': Icons.trending_up,
      'color': const Color(0xFFF59E0B),
    },
    {
      'title': 'Consolidated Account Statement (CAS)',
      'description': 'Official monthly statement showing all mutual fund transactions and holdings',
      'icon': Icons.account_balance_wallet_outlined,
      'color': const Color(0xFFEF4444),
    },
    {
      'title': 'ELSS Statement',
      'description': 'Tax-saving mutual fund investments with lock-in period and maturity details',
      'icon': Icons.savings_outlined,
      'color': const Color(0xFF8B5CF6),
    },
  ];

  Widget _buildReportCard(Map<String, dynamic> report, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isDownloading ? null : () => _confirmDownload(report['title']),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      children: [
                        // Icon Container
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: (report['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            report['icon'] as IconData,
                            size: 28.sp,
                            color: report['color'] as Color,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report['title'],
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor ?? Colors.blue[900],
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                report['description'],
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.secondaryText ?? Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Download Button
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _isDownloading
                                ? Colors.grey[200]
                                : (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            _isDownloading ? Icons.hourglass_empty : Icons.download_outlined,
                            size: 20.sp,
                            color: _isDownloading
                                ? Colors.grey[400]
                                : AppColors.primaryGold ?? const Color(0xFFDAA520),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(title: 'Download Reports'),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor?.withOpacity(0.05) ?? Colors.blue.withOpacity(0.05),
                      AppColors.primaryGold?.withOpacity(0.05) ?? Colors.amber.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: AppColors.primaryColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assessment_outlined,
                        size: 32.sp,
                        color: AppColors.primaryColor ?? Colors.blue,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Financial Reports',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor ?? Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Access and download your comprehensive investment reports',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Available Reports Section
              Text(
                'Available Reports',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue[900],
                ),
              ),
              SizedBox(height: 16.h),

              // Report Cards
              ...reportTypes.asMap().entries.map((entry) {
                return _buildReportCard(entry.value, entry.key);
              }),

              // Loading Indicator
              if (_isDownloading)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.h),
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/anim/sip_anim_success.json',
                        height: 80.h,
                        width: 80.w,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Preparing your report...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor ?? Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 32.h),

              // Download History Section
              Text(
                'Recent Downloads',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue[900],
                ),
              ),
              SizedBox(height: 16.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: _downloadHistory.isEmpty
                    ? Column(
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 48.sp,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No downloads yet',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Your downloaded reports will appear here',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _downloadHistory.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1.h,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final download = _downloadHistory[index];
                    final timestamp = DateTime.parse(download['timestamp']);
                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.success?.withOpacity(0.1) ?? Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    size: 20.sp,
                                    color: AppColors.success ?? Colors.green,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        download['reportType'],
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor ?? Colors.blue[900],
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Downloaded on ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.secondaryText ?? Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}