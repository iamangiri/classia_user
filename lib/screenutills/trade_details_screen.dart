import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/service/apiservice/wallet_service.dart';
import 'package:classia_amc/service/apiservice/user_service.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';

class TradingDetailsScreen extends StatefulWidget {
  final String logo;
  final String name;
  final String fundName;
  final double value;
  final double projection;
  final bool isInvestMode;

  const TradingDetailsScreen({
    Key? key,
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
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String _defaultFolio = "FOLIO123456";

  late WalletService _walletService;
  late UserService _userService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      _userService = UserService(token: '${UserConstants.TOKEN}');
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
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
                  SizedBox(height: 120.h), // Extra space for bottom sheet
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
        onPressed: () {
          Navigator.pop(context);
        },
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
          children: ['Performance', 'Holdings', 'RIA Profile', 'Reviews'].asMap().entries.map((entry) {
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
                    color: isSelected ? AppColors.primaryGold!.withOpacity(0.9) : Colors.transparent,
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

  int _selectedTab = 0;

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

              // New performance table
              _buildPerformanceTable([
              //  {'range': 'Today', 'predicted': '${widget.value}', 'achieved': '${widget.projection}'},
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
          children: const [
            Expanded(child: Text('Time Range', style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('Predicted', style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('Achieved', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        SizedBox(height: 8.h),
        ...data.map((item) => Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item['range']!)),
              Expanded(child: Text(item['predicted']!)),
              Expanded(child: Text(item['achieved']!)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Reviews & Ratings'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '4.2',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            color: AppColors.primaryGold,
                            size: 16.sp,
                          );
                        }),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Based on 284 reviews',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ...[
                {'rating': 5, 'count': 120, 'percentage': 42},
                {'rating': 4, 'count': 85, 'percentage': 30},
                {'rating': 3, 'count': 45, 'percentage': 16},
                {'rating': 2, 'count': 20, 'percentage': 7},
                {'rating': 1, 'count': 14, 'percentage': 5},
              ].map((review) => _buildRatingBar(
                review['rating'] as int,
                review['count'] as int,
                review['percentage'] as int,
              )),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Recent Reviews'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              _buildReviewItem('Amit S.', 5, 'Great performance and consistent returns.', '2 days ago'),
              _buildReviewItem('Priya M.', 4, 'Good fund with solid management.', '1 week ago'),
              _buildReviewItem('Rohit R.', 4, 'Satisfied with the returns so far.', '2 weeks ago'),
            ],

          ),
        ),
      ],
    );
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

  Widget _buildPerformanceChart() {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Text(
          'Performance Chart\n(Interactive chart)',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryText, fontSize: 13.sp),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(String period, String returns, bool isPositive) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            period,
            style: TextStyle(color: AppColors.secondaryText, fontSize: 11.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            returns,
            style: TextStyle(
              color: isPositive ? AppColors.success : AppColors.error,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

  Widget _buildRatingBar(int rating, int count, int percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '$rating',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.star, color: AppColors.primaryGold, size: 12.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.r),
                color: AppColors.border.withOpacity(0.2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, int rating, String review, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: AppColors.primaryGold,
                    size: 12.sp,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            review,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primaryText,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.secondaryText,
            ),
          ),
        ],
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
                      labelText: widget.isInvestMode ? 'Investment Amount' : 'Withdrawal Amount',
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
                      prefixIcon: Icon(Icons.currency_rupee_rounded, color: AppColors.primaryGold, size: 22.sp),
                      suffixIcon: _amountController.text.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          _amountController.clear();
                          setState(() {});
                        },
                        icon: Icon(Icons.clear_rounded, color: AppColors.secondaryText, size: 18.sp),
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
            // Single button based on isInvestMode
            SizedBox(
              width: double.infinity,
              child: widget.isInvestMode
                  ? ElevatedButton(
                onPressed: _isLoading ? null : () => _handleInvestOrWithdraw('Invest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold!.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                    Icon(Icons.trending_up, color: AppColors.buttonText, size: 18.sp),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_down, color: AppColors.error, size: 18.sp),
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
            color: isSelected ? AppColors.primaryGold!.withOpacity(0.1) : AppColors.screenBackground,
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
        await _walletService.deposit(amount);
      } else {
        await _walletService.withdraw(amount);
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
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp, height: 1.4),
                children: [
                  TextSpan(text: 'You are about to $action '),
                  TextSpan(
                    text: '₹${_amountController.text}',
                    style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' in\n${widget.fundName} using folio $_defaultFolio'),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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
                      backgroundColor: action == 'Invest' ? AppColors.primaryGold : AppColors.error,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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
              child: FaIcon(FontAwesomeIcons.checkCircle, color: AppColors.success, size: 28.sp),
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
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp, height: 1.4),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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
              child: FaIcon(FontAwesomeIcons.exclamationCircle, color: AppColors.error, size: 28.sp),
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
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp, height: 1.4),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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


  Widget _buildStatCard(String label, double value, IconData icon, Color color, {bool isMainStat = false}) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
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
                child: FaIcon(
                  icon,
                  color: color,
                  size: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${value.toStringAsFixed(3)}', // Show 3 digits after decimal
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


