import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/service/apiservice/wallet_service.dart';
import 'package:classia_amc/service/apiservice/amc_review_service.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TradingDetailsScreen extends StatefulWidget {
  final int id;
  final String logo;
  final String name;
  final String fundName;
  final double value;
  final double projection;
  final bool isInvestMode;

  const TradingDetailsScreen({
    Key? key,
    required this.id,
    required this.logo,
    required this.name,
    required this.fundName,
    required this.value,
    required this.projection,
    this.isInvestMode = true,
  }) : super(key: key);

  @override
  _TradingDetailsScreenState createState() => _TradingDetailsScreenState();
}

class _TradingDetailsScreenState extends State<TradingDetailsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;
  bool _isReviewLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _reviewFormKey = GlobalKey<FormState>();
  String _defaultFolio = "FOLIO123456";

  late WalletService _walletService;
  late AmcReviewService _reviewService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic>? _reviewData;
  int _userRating = 0;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _walletService = WalletService(token: '${UserConstants.TOKEN}');
      _reviewService = AmcReviewService();
    });
    await _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isReviewLoading = true);
    try {
      final data = await _reviewService.getReviews(widget.id, page: 1, limit: 10);
      print('Fetched review data: $data'); // Debug print
      setState(() {
        _reviewData = data['data']; // Store only the 'data' part
        _isReviewLoading = false;
      });
    } catch (e) {
      setState(() => _isReviewLoading = false);
      print('Error fetching reviews: $e');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reviewController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildTabSection(),
                  _buildTabContent(),
                  SizedBox(height: 120.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80.h,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 30.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.fundName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.name,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Performance', 'Holdings', 'RIA Profile', 'Reviews']
              .asMap()
              .entries
              .map((entry) {
            int index = entry.key;
            String tab = entry.value;
            bool isSelected = _selectedTab == index;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = index);
                  _animationController.reset();
                  _animationController.forward();
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  constraints: BoxConstraints(minWidth: 80.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold!.withOpacity(0.9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    tab,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? AppColors.buttonText : AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(12.w),
          child: _getTabContent(),
        ),
      ),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildJockeyPointTab();
      case 1:
        return _buildHoldingsTab();
      case 2:
        return _buildRIAProfileTab();
      case 3:
        return _buildReviewsTab();
      default:
        return _buildJockeyPointTab();
    }
  }

  Widget _buildJockeyPointTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Past Performance'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Today\'s Growth',
                      widget.value,
                      FontAwesomeIcons.star,
                      AppColors.primaryGold!,
                      isMainStat: true,
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: _buildStatCard(
                      'Today\'s Projection',
                      widget.projection,
                      FontAwesomeIcons.arrowTrendUp,
                      widget.projection >= 0 ? AppColors.success : AppColors.error,
                      isMainStat: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildPerformanceTable([
                {'range': '1 Day', 'predicted': '3.4%', 'achieved': '3%'},
                {'range': '7 Days', 'predicted': '7%', 'achieved': '7.2%'},
                {'range': '15 Days', 'predicted': '6%', 'achieved': '6.7%'},
                {'range': '30 Days', 'predicted': '7.5%', 'achieved': '7.3%'},
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceTable(List<Map<String, String>> data) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text('Time Range',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                        fontSize: 12.sp))),
            Expanded(
                child: Text('Predicted',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                        fontSize: 12.sp))),
            Expanded(
                child: Text('Achieved',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                        fontSize: 12.sp))),
          ],
        ),
        SizedBox(height: 8.h),
        ...data.map((item) => Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(item['range']!,
                      style: TextStyle(color: AppColors.primaryText, fontSize: 11.sp))),
              Expanded(
                  child: Text(item['predicted']!,
                      style: TextStyle(color: AppColors.primaryText, fontSize: 11.sp))),
              Expanded(
                  child: Text(item['achieved']!,
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildHoldingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Top Holdings'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              ...[
                {'name': 'Reliance Industries', 'percentage': 8.5, 'sector': 'Energy'},
                {'name': 'TCS Limited', 'percentage': 7.2, 'sector': 'IT Services'},
                {'name': 'HDFC Bank', 'percentage': 6.8, 'sector': 'Banking'},
                {'name': 'Infosys Limited', 'percentage': 5.9, 'sector': 'IT Services'},
                {'name': 'ICICI Bank', 'percentage': 4.7, 'sector': 'Banking'},
              ].map((holding) => _buildHoldingItem(
                holding['name'] as String,
                holding['percentage'] as double,
                holding['sector'] as String,
              )),
              SizedBox(height: 12.h),
              _buildSectionTitle('Sector Allocation'),
              SizedBox(height: 8.h),
              ...[
                {'name': 'IT Services', 'percentage': 25, 'color': AppColors.primaryGold},
                {'name': 'Banking', 'percentage': 20, 'color': AppColors.accent},
                {'name': 'Energy', 'percentage': 15, 'color': AppColors.success},
                {'name': 'Healthcare', 'percentage': 12, 'color': Colors.purple},
                {'name': 'FMCG', 'percentage': 10, 'color': Colors.blue},
                {'name': 'Others', 'percentage': 18, 'color': AppColors.border},
              ].map((sector) => _buildAllocationBar(
                sector['name'] as String,
                sector['percentage'] as int,
                sector['color'] as Color,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRIAProfileTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('RIA Profile'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold!.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'RS',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rahul Sharma',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Text(
                          'Registered Investment Advisor',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            _buildManagerStatChip('12 Years Experience'),
                            SizedBox(width: 8.w),
                            _buildManagerStatChip('RIA Certified'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Certified RIA with specialization in equity investments and portfolio management. Track record of consistent alpha generation.',
                style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    if (_isReviewLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    // Safely access reviews with null checks
    final reviews = _reviewData != null && _reviewData!['reviews'] is List
        ? _reviewData!['reviews'] as List<dynamic>
        : [];
    final averageRating = (_reviewData != null && _reviewData!['average_rating'] is num
        ? _reviewData!['average_rating'] as num
        : 0.0).toDouble();
    final totalReviews = _reviewData != null && _reviewData!['pagination'] is Map
        ? _reviewData!['pagination']['total'] as int? ?? 0
        : 0;

    print('Reviews in UI: $reviews'); // Debug print
    print('Average Rating: $averageRating, Total Reviews: $totalReviews'); // Debug print

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Reviews & Ratings'),
            GestureDetector(
              onTap: _showWriteReviewDialog,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold!,
                      AppColors.primaryGold!.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, color: AppColors.buttonText, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Write Review',
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold!.withOpacity(0.2),
                          AppColors.primaryGold!.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < averageRating.floor()
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: AppColors.primaryGold,
                              size: 16.sp,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$totalReviews Reviews',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Based on user feedback',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Recent Reviews'),
        SizedBox(height: 8.h),
        reviews.isEmpty
            ? _buildSectionContainer(
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 48.sp,
                color: AppColors.secondaryText?.withOpacity(0.5),
              ),
              SizedBox(height: 12.h),
              Text(
                'No reviews yet',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Be the first to review this fund',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        )
            : Column(
          children: reviews.map((review) {
            return _buildReviewItemFromApi(
              review['id'].toString(), // Convert id to string
              review['rating'] as int? ?? 0,
              review['comment'] as String? ?? 'No comment',
              review['created_at'] as String? ?? DateTime.now().toIso8601String(),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewItemFromApi(String id, int rating, String comment, String createdAt) {
    final DateTime dateTime = DateTime.tryParse(createdAt) ?? DateTime.now();
    final Duration difference = DateTime.now().difference(dateTime);
    String timeAgo;

    if (difference.inDays > 30) {
      timeAgo = '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      timeAgo = '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      timeAgo = 'Just now';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground!.withOpacity(0.95),
            AppColors.cardBackground!.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold!.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold!.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryGold,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'User #$id',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold!.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.primaryGold, size: 12.sp),
                    SizedBox(width: 2.w),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.screenBackground?.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              comment,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryText,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: AppColors.secondaryText, size: 12.sp),
              SizedBox(width: 4.w),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog() {
    _userRating = 0;
    _reviewController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          contentPadding: EdgeInsets.all(24.w),
          content: Form(
            key: _reviewFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold!.withOpacity(0.2),
                          AppColors.primaryGold!.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rate_review_rounded,
                      color: AppColors.primaryGold,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Write a Review',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Share your experience with ${widget.fundName}',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Your Rating',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() => _userRating = index + 1);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            index < _userRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.primaryGold,
                            size: 36.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_userRating > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        _getRatingText(_userRating),
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: _reviewController,
                    maxLines: 4,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 13.sp,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Your Review',
                      hintText: 'Tell us about your experience...',
                      labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 13.sp),
                      hintStyle: TextStyle(
                          color: AppColors.secondaryText?.withOpacity(0.5), fontSize: 12.sp),
                      filled: true,
                      fillColor: AppColors.screenBackground,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primaryGold!, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.error, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.error, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your review';
                      }
                      if (value.trim().length < 10) {
                        return 'Review must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.secondaryText!, width: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _userRating == 0 ? null : () => _submitReview(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            _userRating == 0 ? AppColors.border : AppColors.primaryGold,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              color: AppColors.buttonText,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Future<void> _submitReview(BuildContext dialogContext) async {
    if (!_reviewFormKey.currentState!.validate()) return;
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
      return;
    }

    Navigator.pop(dialogContext);
    setState(() => _isReviewLoading = true);

    try {
      await _reviewService.createReview(
        amcId: widget.id,
        rating: _userRating,
        comment: _reviewController.text.trim(),
      );

      await _fetchReviews();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text('Review submitted successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(child: Text('Failed to submit review: ${e.toString()}')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() => _isReviewLoading = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildHoldingItem(String name, double percentage, String sector) {
    String displayInitial = name.isNotEmpty ? name.substring(0, 1) : 'N';
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: AppColors.primaryGold!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                displayInitial,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Unknown Holding',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sector.isNotEmpty ? sector : 'Unknown Sector',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                percentage.isNaN ? '0.0%' : '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                width: 60.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage.isNaN ? 0.0 : (percentage / 10).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationBar(String label, int percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: color,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Container(
            height: 6.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.r),
              color: AppColors.border.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerStatChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.95),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.secondaryText?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _amountController,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: widget.isInvestMode
                          ? 'Investment Amount'
                          : 'Withdrawal Amount',
                      hintText: '₹1,000',
                      labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 13.sp),
                      hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                      filled: true,
                      fillColor: AppColors.screenBackground,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primaryGold, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.error, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.error, width: 1.5),
                      ),
                      prefixIcon: Icon(Icons.currency_rupee_rounded,
                          color: AppColors.primaryGold, size: 22.sp),
                      suffixIcon: _amountController.text.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          _amountController.clear();
                          setState(() {});
                        },
                        icon: Icon(Icons.clear_rounded,
                            color: AppColors.secondaryText, size: 18.sp),
                      )
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter an amount';
                      final amount = int.tryParse(value);
                      if (amount == null || amount <= 0) return 'Enter a valid amount';
                      if (amount < 100) return 'Minimum amount is ₹100';
                      return null;
                    },
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildAmountChip('₹1,000', 1000),
                SizedBox(width: 8.w),
                _buildAmountChip('₹5,000', 5000),
                SizedBox(width: 8.w),
                _buildAmountChip('₹10,000', 10000),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: widget.isInvestMode
                  ? ElevatedButton(
                onPressed: _isLoading ? null : () => _handleInvestOrWithdraw('Invest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold!.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up,
                        color: AppColors.buttonText, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Invest Now',
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
                  : OutlinedButton(
                onPressed: _isLoading ? null : () => _handleInvestOrWithdraw('Withdraw'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_down,
                        color: AppColors.error, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Withdraw',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountChip(String amount, int value) {
    bool isSelected = _amountController.text == value.toString();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _amountController.text = value.toString();
          setState(() {});
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGold!.withOpacity(0.1)
                : AppColors.screenBackground,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryGold : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            amount,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: isSelected ? AppColors.primaryGold : AppColors.primaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleInvestOrWithdraw(String action) async {
    if (!_formKey.currentState!.validate()) return;
    final confirmed = await _showConfirmationDialog(action);
    if (confirmed != true) return;
    setState(() => _isLoading = true);
    try {
      final amount = int.parse(_amountController.text);
      if (action == 'Invest') {
        await _walletService.deposit(amount, widget.id);
      } else {
        await _walletService.withdraw(amount, widget.id);
      }
      setState(() => _isLoading = false);
      await _showSuccessDialog(action);
      _amountController.clear();
    } catch (e) {
      setState(() => _isLoading = false);
      await _showErrorDialog(e.toString());
    }
  }

  Future<bool?> _showConfirmationDialog(String action) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        contentPadding: EdgeInsets.all(20.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: action == 'Invest'
                    ? AppColors.primaryGold!.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action == 'Invest' ? Icons.trending_up : Icons.trending_down,
                color: action == 'Invest' ? AppColors.primaryGold : AppColors.error,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Confirm $action',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                    color: AppColors.secondaryText, fontSize: 14.sp, height: 1.4),
                children: [
                  TextSpan(text: 'You are about to $action '),
                  TextSpan(
                    text: '₹${_amountController.text}',
                    style: TextStyle(
                        color: AppColors.primaryText, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: ' in\n${widget.fundName} using folio $_defaultFolio'),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      action == 'Invest' ? AppColors.primaryGold : AppColors.error,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(String action) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        contentPadding: EdgeInsets.all(20.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(FontAwesomeIcons.checkCircle,
                  color: AppColors.success, size: 28.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              '$action Successful!',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your $action of ₹${_amountController.text} has been processed.',
              style: TextStyle(
                  color: AppColors.secondaryText, fontSize: 14.sp, height: 1.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        contentPadding: EdgeInsets.all(20.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(FontAwesomeIcons.exclamationCircle,
                  color: AppColors.error, size: 28.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              'Transaction Failed',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                  color: AppColors.secondaryText, fontSize: 14.sp, height: 1.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, double value, IconData icon, Color color,
      {bool isMainStat = false}) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: FaIcon(icon, color: color, size: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${value.toStringAsFixed(3)}',
                  style: TextStyle(
                    color: color,
                    fontSize: isMainStat ? 20.sp : 18.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: '%',
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: isMainStat ? 16.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}