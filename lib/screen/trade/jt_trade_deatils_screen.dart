import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

import '../../service/apiservice/mutual_fund_service.dart';
import '../../widget/common_app_bar.dart';

class JtTradeDeatilsScreen extends StatefulWidget {
  final String logo;
  final String name;
  final String fundName;
  final double value;
  final Map<String, dynamic> fundData;

  const JtTradeDeatilsScreen({
    Key? key,
    required this.logo,
    required this.name,
    required this.fundName,
    required this.value,
    required this.fundData,
  }) : super(key: key);

  @override
  _TradingDetailsScreenState createState() => _TradingDetailsScreenState();
}

class _TradingDetailsScreenState extends State<JtTradeDeatilsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _isFavorite = false;
  int _selectedTab = 0;

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
      appBar: CommonAppBar(
        title: widget.fundName,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildDisclaimer(),
            _buildFundOverviewCard(),
            _buildTabSection(),
            Expanded(child: _buildTabContent()),
            _buildActionButtons(),
          ],
        ),
      ),
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
              'Past performance is not indicative of future results. Investments are subject to market risks.',
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
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold!.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: AppColors.primaryGold,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fundName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold!.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '${widget.fundData['category'] ?? 'Equity'} • ${widget.fundData['planType'] ?? 'Regular'}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('Current NAV', '₹${widget.fundData['nav'] ?? '25.50'}', Icons.account_balance_wallet, AppColors.primaryGold),
                    _buildStatCard('1Y Return', widget.fundData['oneYearChange'] ?? '12.5%', Icons.trending_up, AppColors.success),
                    _buildStatCard('Jockey Point', '${widget.value}%', FontAwesomeIcons.star, AppColors.accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground?.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: iconColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: iconColor, size: 16.sp),
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
      ),
    );
  }

  Widget _buildTabSection() {
    final List<String> tabs = ['Overview', 'Holdings', 'Manager', 'Portfolio', 'Documents'];
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
          children: tabs.asMap().entries.map((entry) {
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
            'This ${widget.fundData['category'] ?? 'Equity'} fund seeks long-term capital growth by investing in ${widget.fundData['category'] == 'Equity' ? 'equity securities' : 'diverse assets'}.',
            style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp, height: 1.5),
          ),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Key Metrics'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              _buildMetricRow('Expense Ratio', widget.fundData['expenseRatio'] ?? '1.5%'),
              _buildMetricRow('Exit Load', widget.fundData['exitLoad'] ?? 'Not Available'),
              _buildMetricRow('Plan Type', widget.fundData['planType'] ?? 'Regular'),
              _buildMetricRow('1 Year Return', widget.fundData['oneYearChange'] ?? '12.5%'),
              _buildMetricRow('3 Year Return', widget.fundData['threeYearsChange'] ?? '35.67%'),
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
                  'answer': 'The fund aims for long-term capital appreciation via ${widget.fundData['category'] == 'Equity' ? 'equity securities' : 'diverse assets'}.'
                },
                {
                  'question': 'What is the minimum investment?',
                  'answer': '₹1,000 for lump sum.'
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

  Widget _buildActionButtons() {
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showInvestmentBottomSheet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold!.withOpacity(0.9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.buttonText,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Lumpsum',
                    style: TextStyle(
                      color: AppColors.buttonText,
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
    );
  }

  void _showInvestmentBottomSheet() {
    String? errorMessage = '';
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: AppColors.cardBackground?.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
                border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText?.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lumpsum Investment',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppColors.secondaryText, size: 20.sp),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.screenBackground,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: AppColors.primaryGold!.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold!.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      Icons.account_balance,
                                      color: AppColors.primaryGold,
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.fundName,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        Text(
                                          'Category: ${widget.fundData['category'] ?? 'Equity'}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Investment Amount',
                                labelStyle: TextStyle(color: AppColors.secondaryText),
                                hintText: '₹1,000',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: AppColors.primaryGold!.withOpacity(0.3)),
                                ),
                                prefixIcon: Icon(
                                  Icons.currency_rupee,
                                  color: AppColors.primaryGold,
                                ),
                                suffixIcon: _amountController.text.isNotEmpty
                                    ? IconButton(
                                  onPressed: () {
                                    _amountController.clear();
                                    setModalState(() {});
                                  },
                                  icon: Icon(Icons.clear_rounded, color: AppColors.secondaryText, size: 18.sp),
                                )
                                    : null,
                              ),
                              style: TextStyle(color: AppColors.primaryText),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Enter an amount';
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) return 'Enter a valid amount';

                                return null;
                              },
                              onChanged: (value) => setModalState(() => errorMessage = ''),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                _buildAmountChip('₹1,000', 1000, setModalState),
                                SizedBox(width: 8.w),
                                _buildAmountChip('₹5,000', 5000, setModalState),
                                SizedBox(width: 8.w),
                                _buildAmountChip('₹10,000', 10000, setModalState),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            isLoading
                                ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold!),
                            )
                                : ElevatedButton(
                              onPressed: () => _handleInvest(setModalState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold!.withOpacity(0.9),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                              ),
                              child: Text(
                                'Confirm Lumpsum',
                                style: TextStyle(
                                  color: AppColors.buttonText,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAmountChip(String amount, int value, StateSetter setModalState) {
    bool isSelected = _amountController.text == value.toString();
    return GestureDetector(
      onTap: () {
        _amountController.text = value.toString();
        setModalState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold!.withOpacity(0.1) : AppColors.screenBackground,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold! : AppColors.border,
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

  Future<void> _handleInvest(StateSetter setModalState) async {
    if (!_formKey.currentState!.validate()) return;
    final confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    setModalState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final response = await MutualFundService.purchaseLumpsum(
        totAmt: amount,
        // rtaAmcCode: widget.fundData['rtaAmcCode'] ?? 'AXF',
        // rtaSchCode: widget.fundData['rtaSchCode'] ?? 'SCGPG',
          rtaAmcCode: "FTI",
           rtaSchCode: "010",
        folio: 'new',
      );

      if (response['status'] == true) {
        final approvalLink = response['data']?['approvalLink']?.toString() ?? '';
        if (await canLaunchUrl(Uri.parse(approvalLink))) {
          await launchUrl(Uri.parse(approvalLink), mode: LaunchMode.externalApplication);
          setModalState(() => _isLoading = false);
          Navigator.pop(context); // Close bottom sheet
          await _showSuccessDialog();
          _amountController.clear();
        } else {
          throw Exception('Unable to open approval link');
        }
      } else {
        throw Exception(response['message']?.toString() ?? 'Transaction failed');
      }
    } catch (e) {
      setModalState(() => _isLoading = false);
      await _showErrorDialog(e.toString());
    }
  }

  Future<bool?> _showConfirmationDialog() {
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
                color: AppColors.primaryGold!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up,
                color: AppColors.primaryGold,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Confirm Investment',
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
                  TextSpan(text: 'You are about to invest '),
                  TextSpan(
                    text: '₹${_amountController.text}',
                    style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' in ${widget.fundName}.'),
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
                      backgroundColor: AppColors.primaryGold,
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

  Future<void> _showSuccessDialog() async {
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
              'Investment Successful!',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your investment of ₹${_amountController.text} has been initiated.',
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