import 'package:flutter/material.dart';
import 'dart:ui';
import '../../themes/app_colors.dart';
import '../../widget/common_app_bar.dart';

class FundDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> fund;

  const FundDetailsScreen({Key? key, required this.fund}) : super(key: key);

  @override
  _FundDetailsScreenState createState() => _FundDetailsScreenState();
}

class _FundDetailsScreenState extends State<FundDetailsScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Performance', 'Fund Manager', 'Holdings', 'Documents'];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _disclaimerAnimationController;
  late Animation<double> _disclaimerFadeAnimation;

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
    _disclaimerAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _disclaimerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _disclaimerAnimationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _disclaimerAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _disclaimerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.fund['name']?.toString() ?? 'Fund Details',
      ),
      backgroundColor: AppColors.screenBackground ?? Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildDisclaimer(),
            _buildModernFundHeader(),
            _buildModernTabBar(),
            Expanded(child: _buildTabContent()),
            _buildModernActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return FadeTransition(
      opacity: _disclaimerFadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.warning ?? Colors.amber,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'This fund details page contains dummy data. Real data integration with AMC is coming soon!',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.warning ?? Colors.amber,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFundHeader() {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
              border: Border.all(
                color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold?.withOpacity(0.2) ?? Color(0xFFDAA520).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: AppColors.primaryGold ?? Color(0xFFDAA520),
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fund['name']?.toString() ?? 'Demo Fund',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText ?? Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold?.withOpacity(0.1) ?? Color(0xFFDAA520).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.fund['category']?.toString() ?? 'Equity',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGold ?? Color(0xFFDAA520),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildModernStatCard(
                      'NAV',
                      '₹${widget.fund['nav']?.toString() ?? '125.45'}',
                      Icons.trending_up,
                      AppColors.success ?? Colors.green,
                    ),
                    SizedBox(width: 8,),
                    _buildModernStatCard(
                      'Returns',
                      widget.fund['returns']?.toString() ?? '+18.45%',
                      Icons.show_chart,
                      AppColors.success ?? Colors.green,
                    ),
                    SizedBox(width: 8,),
                    _buildModernStatCard(
                      'AUM',
                      '₹${widget.fund['aum']?.toString() ?? '2450'}Cr',
                      Icons.account_balance,
                      AppColors.accent ?? Colors.amber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatCard(String title, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: iconColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText ?? Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            int index = entry.key;
            String tab = entry.value;
            bool isSelected = _selectedTab == index;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = index);
                  _animationController.reset();
                  _animationController.forward();
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  constraints: BoxConstraints(minWidth: 100),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold?.withOpacity(0.9) ?? Color(0xFFDAA520).withOpacity(0.9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tab,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.buttonText ?? Colors.white
                          : AppColors.primaryText ?? Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: SingleChildScrollView(
        key: ValueKey(_selectedTab),
        child: Container(
          margin: EdgeInsets.all(12),
          child: _getTabContent(),
        ),
      ),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildModernOverviewTab();
      case 1:
        return _buildModernPerformanceTab();
      case 2:
        return _buildModernFundManagerTab();
      case 3:
        return _buildModernHoldingsTab();
      case 4:
        return _buildModernDocumentsTab();
      default:
        return _buildModernOverviewTab();
    }
  }

  Widget _buildModernOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKeyHighlights(),
        SizedBox(height: 16),
        _buildAboutFundCard(),
      ],
    );
  }

  Widget _buildKeyHighlights() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Highlights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          _buildHighlightItem(
            'Minimum SIP',
            widget.fund['minSip']?.toString() ?? '₹1,000',
            Icons.account_balance_wallet,
          ),
          _buildHighlightItem(
            'Risk Level',
            _getRiskText(int.tryParse(widget.fund['risk']?.toString() ?? '3') ?? 3),
            Icons.assessment,
          ),
          _buildHighlightItem(
            'AUM',
            '₹${widget.fund['aum']?.toString() ?? '2,450'} Cr',
            Icons.pie_chart,
          ),
          _buildHighlightItem(
            'Expense Ratio',
            '${widget.fund['expense_ratio']?.toString() ?? '1.25'}%',
            Icons.percent,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(String title, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accent?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accent ?? Colors.amber, size: 14),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText ?? Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutFundCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Fund',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.fund['description']?.toString() ??
                'This ${widget.fund['category']?.toString() ?? 'Equity'} fund focuses on delivering long-term capital appreciation through a diversified portfolio of high-growth companies with strong fundamentals.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryText ?? Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPerformanceTab() {
    final performanceData = widget.fund['performance'] as Map<String, dynamic>? ??
        {
          '1Y': {'return': 18.45, 'benchmark': 15.23},
          '3Y': {'return': 14.67, 'benchmark': 12.34},
          '5Y': {'return': 12.89, 'benchmark': 10.67},
        };

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance vs Benchmark',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText ?? Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              ...performanceData.entries.map((entry) {
                return _buildPerformanceRow(
                  entry.key,
                  entry.value['return']?.toDouble() ?? 0.0,
                  entry.value['benchmark']?.toDouble() ?? 0.0,
                );
              }).toList(),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 200,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 48, color: AppColors.accent ?? Colors.amber),
                SizedBox(height: 8),
                Text(
                  'Performance Chart',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText ?? Colors.black87,
                  ),
                ),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(String period, double fundReturn, double benchmarkReturn) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.screenBackground ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.2) ?? Color(0xFFDAA520).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            child: Text(
              period,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fund', style: TextStyle(fontSize: 11, color: AppColors.secondaryText ?? Colors.grey)),
                    Text(
                      '${fundReturn.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: fundReturn >= 0 ? AppColors.success ?? Colors.green : AppColors.error ?? Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: (AppColors.success ?? Colors.green).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (fundReturn.abs() / 50).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: fundReturn >= 0 ? AppColors.success ?? Colors.green : AppColors.error ?? Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Benchmark', style: TextStyle(fontSize: 11, color: AppColors.secondaryText ?? Colors.grey)),
                    Text(
                      '${benchmarkReturn.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: benchmarkReturn >= 0 ? AppColors.success ?? Colors.green : AppColors.error ?? Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFundManagerTab() {
    final fundManager = widget.fund['fund_manager'] as Map<String, dynamic>? ??
        {
          'name': 'Rajesh Kumar',
          'experience': '12 Years',
          'qualification': 'MBA Finance, CFA',
          'funds_managed': 8,
        };

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund Manager',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold?.withOpacity(0.2) ?? Color(0xFFDAA520).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.primaryGold ?? Color(0xFFDAA520),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fundManager['name']?.toString() ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText ?? Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      fundManager['qualification']?.toString() ?? 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText ?? Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildManagerStatChip('${fundManager['experience']?.toString() ?? 'N/A'} Experience'),
                        SizedBox(width: 8),
                        _buildManagerStatChip('${fundManager['funds_managed']?.toString() ?? '0'} Funds'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagerStatChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.2) ?? Color(0xFFDAA520).withOpacity(0.2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText ?? Colors.black87,
        ),
      ),
    );
  }

  Widget _buildModernHoldingsTab() {
    final holdings = widget.fund['holdings'] as List<dynamic>? ??
        [
          {'name': 'Reliance Industries Ltd', 'allocation': 8.45, 'sector': 'Energy'},
          {'name': 'HDFC Bank Ltd', 'allocation': 7.23, 'sector': 'Banking'},
          {'name': 'Infosys Ltd', 'allocation': 6.89, 'sector': 'IT Services'},
          {'name': 'ICICI Bank Ltd', 'allocation': 5.67, 'sector': 'Banking'},
          {'name': 'TCS Ltd', 'allocation': 5.34, 'sector': 'IT Services'},
        ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Holdings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText ?? Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold?.withOpacity(0.1) ?? Color(0xFFDAA520).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${holdings.length} Stocks',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGold ?? Color(0xFFDAA520),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...holdings.map((holding) => _buildHoldingItem(holding)).toList(),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(Map<String, dynamic> holding) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.screenBackground ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.2) ?? Color(0xFFDAA520).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryGold?.withOpacity(0.1) ?? Color(0xFFDAA520).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                holding['name']?.toString().substring(0, 1) ?? 'N',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold ?? Color(0xFFDAA520),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding['name']?.toString() ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText ?? Colors.black87,
                  ),
                ),
                Text(
                  holding['sector']?.toString() ?? 'N/A',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(holding['allocation']?.toDouble() ?? 0.0).toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText ?? Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ((holding['allocation']?.toDouble() ?? 0.0) / 10).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold ?? Color(0xFFDAA520),
                      borderRadius: BorderRadius.circular(2),
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

  Widget _buildModernDocumentsTab() {
    final documents = widget.fund['documents'] as List<dynamic>? ??
        [
          {'name': 'Scheme Information Document', 'type': 'PDF', 'icon': Icons.picture_as_pdf},
          {'name': 'Statement of Additional Information', 'type': 'PDF', 'icon': Icons.description},
          {'name': 'Key Information Memorandum', 'type': 'PDF', 'icon': Icons.article},
        ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          ...documents.map((doc) => _buildDocumentItem(doc)).toList(),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> document) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.screenBackground ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.2) ?? Color(0xFFDAA520).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              document['icon'] ?? Icons.description,
              color: AppColors.accent ?? Colors.amber,
              size: 16,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document['name']?.toString() ?? 'Document',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText ?? Colors.black87,
                  ),
                ),
                Text(
                  document['type']?.toString() ?? 'N/A',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {}, // Add download logic here
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryGold?.withOpacity(0.1) ?? Color(0xFFDAA520).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.download,
                color: AppColors.primaryGold ?? Color(0xFFDAA520),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButtons() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(
          color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.screenBackground ?? Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildAmountChip('₹1,000'),
                SizedBox(width: 8),
                _buildAmountChip('₹5,000'),
                SizedBox(width: 8),
                _buildAmountChip('₹10,000'),
                Spacer(),
                GestureDetector(
                  onTap: () => _showInvestmentBottomSheet('Custom'),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Custom',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryGold ?? Color(0xFFDAA520),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showInvestmentBottomSheet('Lumpsum'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold?.withOpacity(0.9) ?? Color(0xFFDAA520).withOpacity(0.9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.buttonText ?? Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Lumpsum',
                        style: TextStyle(
                          color: AppColors.buttonText ?? Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showInvestmentBottomSheet('SIP'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primaryGold ?? Color(0xFFDAA520),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.repeat,
                        color: AppColors.primaryGold ?? Color(0xFFDAA520),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Start SIP',
                        style: TextStyle(
                          color: AppColors.primaryGold ?? Color(0xFFDAA520),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(String amount) {
    return GestureDetector(
      onTap: () => _showInvestmentBottomSheet('Custom'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryGold?.withOpacity(0.1) ?? Color(0xFFDAA520).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          amount,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primaryGold ?? Color(0xFFDAA520),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getRiskText(int risk) {
    switch (risk) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Moderate';
    }
  }

  void _showInvestmentBottomSheet(String investmentType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppColors.cardBackground?.withOpacity(0.8) ?? Colors.grey[100]!.withOpacity(0.8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border.all(
              color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondaryText?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$investmentType Investment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText ?? Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.secondaryText ?? Colors.grey, size: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.screenBackground ?? Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryGold?.withOpacity(0.2) ?? Color(0xFFDAA520).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold?.withOpacity(0.2) ?? Color(0xFFDAA520).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: AppColors.primaryGold ?? Color(0xFFDAA520),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.fund['name']?.toString() ?? 'Demo Fund',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryText ?? Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'NAV: ₹${widget.fund['nav']?.toString() ?? '125.45'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText ?? Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold?.withOpacity(0.1) ?? Color(0xFFDAA520).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Icon(
                                  investmentType == 'SIP' ? Icons.repeat : Icons.account_balance_wallet,
                                  color: AppColors.primaryGold ?? Color(0xFFDAA520),
                                  size: 32,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '$investmentType Investment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText ?? Colors.black87,
                                ),
                              ),
                              Text(
                                'This feature is coming soon!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText ?? Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}