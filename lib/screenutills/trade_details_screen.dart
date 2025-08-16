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
  final bool isInvestMode; // New flag to toggle Invest/Withdraw

  const TradingDetailsScreen({
    Key? key,
    required this.logo,
    required this.name,
    required this.fundName,
    required this.value,
    this.isInvestMode = true, // Default to Invest mode
  }) : super(key: key);

  @override
  _TradingDetailsScreenState createState() => _TradingDetailsScreenState();
}

class _TradingDetailsScreenState extends State<TradingDetailsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _isFavorite = false;
  String _defaultFolio = "FOLIO123456"; // Default folio number
  bool _isFolioLoading = false;

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
                  _buildDisclaimer(),
                  _buildFundOverviewCard(),
                  _buildTabSection(),
                  _buildTabContent(),
                  SizedBox(height: 100.h),
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
      expandedHeight: 100.h,
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
                            fontSize: 18.sp,
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'Large Cap • Equity',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
      actions: [
        // IconButton(
        //   icon: Icon(Icons.share_rounded, color: Colors.white, size: 22.sp),
        //   onPressed: () {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text('Share feature coming soon!'),
        //         backgroundColor: AppColors.success,
        //         behavior: SnackBarBehavior.floating,
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        //       ),
        //     );
        //   },
        // ),
        // IconButton(
        //   icon: Icon(
        //     _isFavorite ? Icons.favorite : Icons.favorite_border,
        //     color: _isFavorite ? Colors.red : Colors.white,
        //     size: 22.sp,
        //   ),
        //   onPressed: () {
        //     setState(() {
        //       _isFavorite = !_isFavorite;
        //     });
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        //         backgroundColor: AppColors.success,
        //         behavior: SnackBarBehavior.floating,
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        //       ),
        //     );
        //   },
        // ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'This fund details page contains dummy data. Real data integration with AMC is coming soon!',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundOverviewCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground?.withOpacity(0.8),
              border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current NAV',
                          style: TextStyle(color: AppColors.secondaryText, fontSize: 13.sp),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '₹25.50',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, color: AppColors.success, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '+2.5% Today',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('AUM', '₹5,000 Cr', Icons.account_balance_wallet)),
                    SizedBox(width: 8.w),
                    Expanded(child: _buildMetricCard('1Y Return', '12.5%', Icons.trending_up)),
                    SizedBox(width: 8.w),
                    Expanded(child: _buildMetricCard('Jockey Point', '${widget.value}%', FontAwesomeIcons.star)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGold!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 16.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Overview', 'Holdings', 'Manager', 'Portfolio', 'Documents'].asMap().entries.map((entry) {
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
                  constraints: BoxConstraints(minWidth: 100.w),
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
                      fontSize: 12.sp,
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
        return _buildOverviewTab();
      case 1:
        return _buildHoldingsTab();
      case 2:
        return _buildManagerTab();
      case 3:
        return _buildPortfolioTab();
      case 4:
        return _buildDocumentsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About the Fund'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Text(
            'This fund seeks long-term capital growth by investing in large-cap equity securities with strong fundamentals.',
            style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp, height: 1.5),
          ),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Performance'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              _buildPerformanceChart(),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _buildPerformanceCard('1Y', '12.5%', true)),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildPerformanceCard('3Y', '35.0%', true)),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildPerformanceCard('5Y', '60.0%', true)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Key Metrics'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              _buildMetricRow('Expense Ratio', '1.5%'),
              _buildMetricRow('Sharpe Ratio', '1.8'),
              _buildMetricRow('Alpha', '3.2'),
              _buildMetricRow('Beta', '1.1'),
              _buildMetricRow('Standard Deviation', '15.2%'),
            ],
          ),
        ),
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
                {'name': 'IT Services', 'percentage': 25.0, 'color': AppColors.primaryGold},
                {'name': 'Banking', 'percentage': 20.0, 'color': AppColors.accent},
                {'name': 'Energy', 'percentage': 15.0, 'color': AppColors.success},
                {'name': 'Healthcare', 'percentage': 12.0, 'color': Colors.purple},
                {'name': 'FMCG', 'percentage': 10.0, 'color': Colors.blue},
                {'name': 'Others', 'percentage': 18.0, 'color': AppColors.border},
              ].map((sector) => _buildAllocationBar(
                sector['name'] as String,
                (sector['percentage'] as double).toInt(),
                sector['color'] as Color,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManagerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fund Manager'),
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
                          'MBA Finance, CFA',
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
                            _buildManagerStatChip('8 Funds'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Rahul has managed equity funds for over 12 years with a proven track record. He specializes in large-cap investments.',
                style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Asset Allocation'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              Container(
                height: 180.h,
                decoration: BoxDecoration(
                  color: AppColors.screenBackground,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    'Asset Allocation Chart\n(Pie chart)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 13.sp),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ...[
                {'name': 'Equity', 'percentage': 70, 'color': AppColors.primaryGold},
                {'name': 'Debt', 'percentage': 20, 'color': AppColors.accent},
                {'name': 'Cash', 'percentage': 10, 'color': AppColors.success},
              ].map((alloc) => _buildAllocationBar(
                alloc['name'] as String,
                alloc['percentage'] as int,
                alloc['color'] as Color,
              )),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Portfolio Statistics'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              _buildMetricRow('Number of Holdings', '45'),
              _buildMetricRow('Portfolio Turnover', '35%'),
              _buildMetricRow('Cash Position', '5.2%'),
              _buildMetricRow('Average Market Cap', '₹85,000 Cr'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fund Documents'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              ...[
                {'title': 'Scheme Information Document', 'type': 'PDF', 'size': '2.5 MB'},
                {'title': 'Key Information Memorandum', 'type': 'PDF', 'size': '1.8 MB'},
                {'title': 'Annual Report 2024', 'type': 'PDF', 'size': '4.2 MB'},
              ].map((doc) => _buildDocumentItem(doc['title']!, doc['type']!, doc['size']!)),
              SizedBox(height: 12.h),
              _buildSectionTitle('FAQs'),
              SizedBox(height: 8.h),
              ...[
                {
                  'question': 'What is the investment objective?',
                  'answer': 'The fund aims for long-term capital appreciation via large-cap equity securities.'
                },
                {
                  'question': 'What is the minimum investment?',
                  'answer': '₹1,000 for lump sum and ₹500 for SIP.'
                },
                {
                  'question': 'How can I redeem my investment?',
                  'answer': 'Redeem via the app’s portfolio section.'
                },
              ].map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)),
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

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(String name, double percentage, String sector) {
    // Validate name to prevent RangeError
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

  Widget _buildDocumentItem(String title, String type, String size) {
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
              color: AppColors.accent?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              type == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart,
              color: AppColors.accent,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$type • $size',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading $title...'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.primaryGold!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.download,
                color: AppColors.primaryGold,
                size: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Text(
              answer,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13.sp, height: 1.5),
            ),
          ),
        ],
        iconColor: AppColors.primaryGold,
        collapsedIconColor: AppColors.secondaryText,
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
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
            SizedBox(height: 12.h),
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
            SizedBox(height: 12.h),
            // Show only one button based on isInvestMode
            SizedBox(
              width: double.infinity,
              child: widget.isInvestMode
                  ? ElevatedButton(
                onPressed: _isLoading ? null : () => _handleInvestOrWithdraw('Invest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold!.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, color: AppColors.buttonText, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Invest',
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 12.sp,
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
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_down, color: AppColors.error, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Withdraw',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12.sp,
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
    return GestureDetector(
      onTap: () {
        _amountController.text = value.toString();
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
          style: TextStyle(
            fontSize: 11.sp,
            color: isSelected ? AppColors.primaryGold : AppColors.primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
}