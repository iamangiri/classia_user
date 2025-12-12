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

class _TradingDetailsScreenState extends State<JtTradeDeatilsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
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

  String _getString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  String _getPercentage(dynamic value) {
    if (value == null || value == 'null') return 'N/A';
    String strValue = value.toString().replaceAll('%', '').trim();
    if (strValue.isEmpty) return 'N/A';
    return '$strValue%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: widget.fundName),
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
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Past performance is not indicative of future results. Investments are subject to market risks.',
              style: TextStyle(fontSize: 11.sp, color: AppColors.warning, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundOverviewCard() {
    String category = 'Equity';
    if (widget.fundData['category'] != null) {
      if (widget.fundData['category'] is Map && widget.fundData['category']['category'] != null) {
        if (widget.fundData['category']['category'] is Map) {
          category = widget.fundData['category']['category']['name']?.toString() ?? 'Equity';
        } else {
          category = widget.fundData['category']['category'].toString();
        }
      } else if (widget.fundData['category'] is String) {
        category = widget.fundData['category'];
      }
    }

    String planType = 'Regular';
    if (widget.fundData['prodMfData'] != null && widget.fundData['prodMfData']['planType'] != null) {
      planType = widget.fundData['prodMfData']['planType'].toString();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: Offset(0, 4))],
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: widget.logo.isNotEmpty
                            ? Image.network(widget.logo, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.account_balance, color: AppColors.primaryGold, size: 32.sp))
                            : Icon(Icons.account_balance, color: AppColors.primaryGold, size: 32.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.fundName,
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4.h),
                          Text(widget.name, style: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText)),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold!.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text('$category • $planType',
                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.primaryGold)),
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
                    _buildStatCard('AMC', _getString(widget.fundData['amc'], 'N/A'), Icons.business, AppColors.primaryGold),
                    _buildStatCard('1Y Return', _getPercentage(widget.fundData['oneYearChange']), Icons.trending_up, AppColors.success),
                    _buildStatCard('3Y Return', _getPercentage(widget.fundData['threeYearsChange']), FontAwesomeIcons.chartLine, AppColors.accent),
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
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
              child: Icon(icon, color: iconColor, size: 16.sp),
            ),
            SizedBox(height: 4.h),
            Text(value, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText), textAlign: TextAlign.center),
            Text(title, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w500, color: AppColors.secondaryText), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    final List<String> tabs = ['Overview', 'Holdings', 'Manager', 'Performance'];
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
                  child: Text(tab, textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isSelected ? AppColors.buttonText : AppColors.primaryText,
                          fontWeight: FontWeight.w600, fontSize: 12.sp)),
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
        child: Container(margin: EdgeInsets.all(12.w), child: _getTabContent()),
      ),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTab) {
      case 0: return _buildOverviewTab();
      case 1: return _buildHoldingsTab();
      case 2: return _buildManagerTab();
      case 3: return _buildPerformanceTab();
      default: return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    Map<String, dynamic>? analysis = widget.fundData['analysis'];
    String expenseRatio = 'N/A';
    String exitLoad = 'N/A';

    if (analysis != null && analysis['expense_ratio'] != null) {
      expenseRatio = analysis['expense_ratio'].toString() + '%';
    }
    if (widget.fundData['prodMfData'] != null && widget.fundData['prodMfData']['exitLoad'] != null) {
      exitLoad = widget.fundData['prodMfData']['exitLoad'].toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About the Fund'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Text(widget.fundData['scheamName']?.toString() ?? widget.fundName,
              style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp, height: 1.5)),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Performance Metrics'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              _buildMetricRow('1 Day Change', _getPercentage(widget.fundData['dayChange'])),
              _buildMetricRow('1 Week Change', _getPercentage(widget.fundData['weekChange'])),
              _buildMetricRow('1 Month Change', _getPercentage(widget.fundData['monthChange'])),
              _buildMetricRow('6 Month Change', _getPercentage(widget.fundData['sixMonthChange'])),
              _buildMetricRow('1 Year Return', _getPercentage(widget.fundData['oneYearChange'])),
              _buildMetricRow('3 Year Return', _getPercentage(widget.fundData['threeYearsChange'])),
              _buildMetricRow('5 Year Return', _getPercentage(widget.fundData['fiveYearsChange'])),
              _buildMetricRow('All Time', _getPercentage(widget.fundData['allTime'])),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Fund Details'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              _buildMetricRow('Expense Ratio', expenseRatio),
              _buildMetricRow('Exit Load', exitLoad),
              _buildMetricRow('Scheme Code', _getString(widget.fundData['scheamCode'], 'N/A')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingsTab() {
    var holdingsData = widget.fundData['holdings'];
    List<dynamic> holdings = [];

    if (holdingsData != null) {
      if (holdingsData is Map && holdingsData['portfolio'] != null) {
        holdings = holdingsData['portfolio'];
      } else if (holdingsData is List) {
        holdings = holdingsData;
      }
    }

    if (holdings.isEmpty) {
      return _buildSectionContainer(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Text('Holdings data not available', style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp)),
          ),
        ),
      );
    }

    List<dynamic> topHoldings = holdings.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Top Holdings'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: topHoldings.map<Widget>((holding) {
              String name = holding['name']?.toString() ?? 'Unknown';
              double weight = 0.0;

              if (holding['weight_%'] != null) {
                weight = double.tryParse(holding['weight_%'].toString()) ?? 0.0;
              } else if (holding['weight'] != null) {
                weight = double.tryParse(holding['weight'].toString()) ?? 0.0;
              } else if (holding['assets'] != null) {
                String assets = holding['assets'].toString().replaceAll('%', '');
                weight = double.tryParse(assets) ?? 0.0;
              }

              String sector = holding['sector']?.toString() ?? 'Unknown';
              return _buildHoldingItem(name, weight, sector);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildManagerTab() {
    var managersData = widget.fundData['fundManagers'];
    List<dynamic> managers = [];

    if (managersData != null) {
      if (managersData is List) {
        managers = managersData;
      } else if (managersData is Map && managersData['fund_management'] != null) {
        managers = managersData['fund_management'];
      }
    }

    if (managers.isEmpty) {
      return _buildSectionContainer(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Text('Fund manager data not available', style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fund Managers'),
        SizedBox(height: 8.h),
        ...managers.map<Widget>((manager) {
          String name = manager['name']?.toString() ?? 'Unknown Manager';
          String tenure = '';

          if (manager['tenure'] != null) {
            tenure = manager['tenure'].toString();
          } else if (manager['since'] != null) {
            tenure = manager['since'].toString();
          } else if (manager['from'] != null && manager['to'] != null) {
            tenure = '${manager['from']} - ${manager['to']}';
          } else if (manager['start_date'] != null && manager['end_date'] != null) {
            tenure = '${manager['start_date']} - ${manager['end_date']}';
          }

          return _buildManagerCard(name, tenure);
        }).toList(),
      ],
    );
  }

  Widget _buildManagerCard(String name, String tenure) {
    String initials = name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').take(2).join('').toUpperCase();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: _buildSectionContainer(
        child: Row(
          children: [
            Container(
              width: 48.r, height: 48.r,
              decoration: BoxDecoration(color: AppColors.primaryGold!.withOpacity(0.2), borderRadius: BorderRadius.circular(12.r)),
              child: Center(child: Text(initials, style: TextStyle(color: AppColors.primaryGold, fontSize: 16.sp, fontWeight: FontWeight.bold))),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                  if (tenure.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(tenure, style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Returns Analysis'),
        SizedBox(height: 8.h),
        _buildSectionContainer(
          child: Column(
            children: [
              _buildMetricRow('1 Day', _getPercentage(widget.fundData['dayChange'])),
              _buildMetricRow('1 Week', _getPercentage(widget.fundData['weekChange'])),
              _buildMetricRow('1 Month', _getPercentage(widget.fundData['monthChange'])),
              _buildMetricRow('6 Months', _getPercentage(widget.fundData['sixMonthChange'])),
              _buildMetricRow('1 Year', _getPercentage(widget.fundData['oneYearChange'])),
              _buildMetricRow('3 Years', _getPercentage(widget.fundData['threeYearsChange'])),
              _buildMetricRow('5 Years', _getPercentage(widget.fundData['fiveYearsChange'])),
              _buildMetricRow('Since Inception', _getPercentage(widget.fundData['allTime'])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText));
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
          Text(label, style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp)),
          Text(value, style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp, fontWeight: FontWeight.w600)),
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
            width: 32.r, height: 32.r,
            decoration: BoxDecoration(color: AppColors.primaryGold!.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Center(child: Text(displayInitial, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryGold))),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: AppColors.primaryText, fontSize: 13.sp, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(sector, style: TextStyle(color: AppColors.secondaryText, fontSize: 11.sp)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${percentage.toStringAsFixed(2)}%',
                  style: TextStyle(color: AppColors.primaryText, fontSize: 12.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 4.h),
              Container(
                width: 60.w, height: 4.h,
                decoration: BoxDecoration(color: AppColors.primaryGold!.withOpacity(0.2), borderRadius: BorderRadius.circular(2.r)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (percentage / 10).clamp(0.0, 1.0),
                  child: Container(decoration: BoxDecoration(color: AppColors.primaryGold, borderRadius: BorderRadius.circular(2.r))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
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
                  Icon(Icons.account_balance_wallet, color: AppColors.buttonText, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text('Invest Now', style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInvestmentBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground?.withOpacity(0.95),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
                    border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
                  ),
                  child: Column(
                      children: [
                  Container(
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  width: 40.w, height: 4.h,
                  decoration: BoxDecoration(color: AppColors.secondaryText?.withOpacity(0.3), borderRadius: BorderRadius.circular(2.r)),
                ),
                Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text('Investment Details',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
                IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.secondaryText, size: 24.sp),
                ),
                ],
                ),
                ),
                Expanded(
                child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Form(
                key: _formKey,
                child: Column(
                children: [
                Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                gradient: LinearGradient(
                colors: [AppColors.primaryGold!.withOpacity(0.1), AppColors.primaryGold!.withOpacity(0.05)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primaryGold!.withOpacity(0.3)),
                ),
                child: Row(
                children: [
                Container(
                width: 48.w, height: 48.w,
                decoration: BoxDecoration(color: AppColors.primaryGold!.withOpacity(0.2), borderRadius: BorderRadius.circular(10.r)),
                child: Icon(Icons.account_balance, color: AppColors.primaryGold, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(widget.fundName,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(widget.name, style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText)),
                ],
                ),
                ),
                ],
                ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                labelText: 'Investment Amount',
                labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                hintText: 'Enter amount (Min ₹1,000)',
                hintStyle: TextStyle(color: AppColors.secondaryText?.withOpacity(0.6)),
                prefixIcon: Padding(
                padding: EdgeInsets.all(12.w),
                child: Icon(Icons.currency_rupee, color: AppColors.primaryGold, size: 20.sp),
                ),
                suffixIcon: _amountController.text.isNotEmpty
                ? IconButton(
                  // Add this to the end of _TradingDetailsScreenState class

// Continue the suffixIcon from previous part:
                  onPressed: () {
                    _amountController.clear();
                    setModalState(() {});
                  },
                  icon: Icon(Icons.clear_rounded, color: AppColors.secondaryText, size: 20.sp),
                )
                    : null,
                  filled: true,
                  fillColor: AppColors.screenBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primaryGold!.withOpacity(0.3), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primaryGold!, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.error, width: 1.5),
                  ),
                ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an amount';
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) return 'Enter a valid amount';
                    if (amount < 1000) return 'Minimum investment is ₹1,000';
                    return null;
                  },
                  onChanged: (value) => setModalState(() {}),
                ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      _buildAmountChip('₹1,000', 1000, setModalState),
                      SizedBox(width: 8.w),
                      _buildAmountChip('₹5,000', 5000, setModalState),
                      SizedBox(width: 8.w),
                      _buildAmountChip('₹10,000', 10000, setModalState),
                    ],
                  ),
                  Spacer(),
                  _isLoading
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold!),
                        ),
                        SizedBox(height: 12.h),
                        Text('Processing your investment...',
                            style: TextStyle(color: AppColors.secondaryText, fontSize: 13.sp)),
                      ],
                    ),
                  )
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleInvest(setModalState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold!,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: AppColors.buttonText, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('Proceed to Invest',
                              style: TextStyle(
                                  color: AppColors.buttonText, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _amountController.text = value.toString();
          setModalState(() {});
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [AppColors.primaryGold!.withOpacity(0.2), AppColors.primaryGold!.withOpacity(0.1)])
                : null,
            color: isSelected ? null : AppColors.screenBackground,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryGold! : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            amount,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: isSelected ? AppColors.primaryGold : AppColors.primaryText,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
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

      // Extract scheme and fund codes from fundData
      String rtaSchCode = '';
      String rtaAmcCode = '';

      // Try to get scheme code
      if (widget.fundData['scheamCode'] != null) {
        rtaSchCode = widget.fundData['scheamCode'].toString();
      } else if (widget.fundData['prodMfData'] != null && widget.fundData['prodMfData']['schemeCode'] != null) {
        rtaSchCode = widget.fundData['prodMfData']['schemeCode'].toString();
      }

      // Try to get AMC/fund code
      if (widget.fundData['prodMfData'] != null && widget.fundData['prodMfData']['fundCode'] != null) {
        rtaAmcCode = widget.fundData['prodMfData']['fundCode'].toString();
      } else if (widget.fundData['amc'] != null) {
        rtaAmcCode = widget.fundData['amc'].toString();
      }

      print('Investment Details:');
      print('Amount: $amount');
      print('Scheme Code: $rtaSchCode');
      print('AMC Code: $rtaAmcCode');

      // Call the API to purchase lumpsum
      final response = await MutualFundService.purchaseLumpsum(
        totAmt: amount,
        rtaAmcCode: rtaAmcCode,
        rtaSchCode: rtaSchCode,
        folio: 'new',
      );

      setModalState(() => _isLoading = false);

      print('API Response: $response');

      if (response['status'] == true) {
        final approvalLink = response['data']?['approvalLink']?.toString() ?? '';

        if (approvalLink.isNotEmpty) {
          Navigator.pop(context); // Close bottom sheet
          await _showSuccessDialog();

          // Launch the approval URL
          final Uri url = Uri.parse(approvalLink);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Unable to open approval link');
          }

          _amountController.clear();
        } else {
          throw Exception('Approval link not received');
        }
      } else {
        throw Exception(response['message']?.toString() ?? 'Transaction failed');
      }
    } catch (e) {
      print('Error during investment: $e');
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
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGold!.withOpacity(0.2), AppColors.primaryGold!.withOpacity(0.1)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.trending_up, color: AppColors.primaryGold, size: 32.sp),
            ),
            SizedBox(height: 16.h),
            Text('Confirm Investment',
                style: TextStyle(color: AppColors.primaryText, fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp, height: 1.5),
                children: [
                  TextSpan(text: 'You are about to invest '),
                  TextSpan(
                    text: '₹${_amountController.text}',
                    style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  TextSpan(text: ' in\n'),
                  TextSpan(
                    text: widget.fundName,
                    style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      backgroundColor: AppColors.screenBackground,
                    ),
                    child: Text('Cancel',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text('Confirm', style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp, fontWeight: FontWeight.bold)),
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
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.success.withOpacity(0.2), AppColors.success.withOpacity(0.1)],
                ),
                shape: BoxShape.circle,
              ),
              child: FaIcon(FontAwesomeIcons.checkCircle, color: AppColors.success, size: 32.sp),
            ),
            SizedBox(height: 16.h),
            Text('Investment Initiated!',
                style: TextStyle(color: AppColors.primaryText, fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Text(
              'Your investment of ₹${_amountController.text} has been initiated successfully. Please complete the approval process in your browser.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  elevation: 2,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Done', style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp, fontWeight: FontWeight.bold)),
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
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.error.withOpacity(0.2), AppColors.error.withOpacity(0.1)],
                ),
                shape: BoxShape.circle,
              ),
              child: FaIcon(FontAwesomeIcons.exclamationCircle, color: AppColors.error, size: 32.sp),
            ),
            SizedBox(height: 16.h),
            Text('Transaction Failed',
                style: TextStyle(color: AppColors.primaryText, fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Text(
              message.contains('Exception:') ? message.replaceAll('Exception:', '').trim() : message,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  elevation: 2,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Try Again', style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}