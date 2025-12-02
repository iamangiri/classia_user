
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../themes/app_colors.dart';
import '../../widget/common_app_bar.dart';
import '../../service/apiservice/mutual_fund_service.dart';
import '../main/home_disclamer.dart';

class FundDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> fund;

  const FundDetailsScreen({Key? key, required this.fund}) : super(key: key);

  @override
  _FundDetailsScreenState createState() => _FundDetailsScreenState();
}

class _FundDetailsScreenState extends State<FundDetailsScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Performance'];
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
            HomeDisclaimer(
              message: "Past performance may or may not be sustained in the future. Returns are not guaranteed.",
            ),
            _buildModernFundHeader(),
            _buildModernTabBar(),
            Expanded(child: _buildTabContent()),
            _buildModernActionButtons(),
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
                            widget.fund['name']?.toString() ?? 'Unknown Fund',
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
                      '1Y Return',
                      '${(widget.fund['oneYearChange']?.toDouble() ?? 0.0).toStringAsFixed(2)}%',
                      Icons.trending_up,
                      AppColors.success ?? Colors.green,
                    ),
                    SizedBox(width: 8),
                    _buildModernStatCard(
                      'SIP Allowed',
                      widget.fund['sipAllowed'] == true ? 'Yes' : 'No',
                      Icons.repeat,
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
            'SIP Allowed',
            widget.fund['sipAllowed'] == true ? 'Yes' : 'No',
            Icons.repeat,
          ),
          _buildHighlightItem(
            'Exit Load',
            widget.fund['exitLoad']?.toString() ?? 'Not Available',
            Icons.exit_to_app,
          ),
          _buildHighlightItem(
            'Plan Type',
            widget.fund['planType']?.toString() ?? 'Regular',
            Icons.category,
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
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText ?? Colors.black87,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
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
            'This ${widget.fund['category']?.toString() ?? 'Equity'} fund aims to provide capital appreciation. Detailed information is not available in the current API response.',
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
            'Performance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          _buildPerformanceRow('1 Year', widget.fund['oneYearChange']?.toDouble() ?? 0.0),
          _buildPerformanceRow('3 Years', widget.fund['threeYearsChange']?.toDouble() ?? 0.0),
          _buildPerformanceRow('5 Years', widget.fund['fiveYearsChange']?.toDouble() ?? 0.0),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String period, double fundReturn) {
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
              ],
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
      child: Row(
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
              onPressed: widget.fund['sipAllowed'] == true ? () => _showInvestmentBottomSheet('SIP') : null,
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
                    color: widget.fund['sipAllowed'] == true
                        ? AppColors.primaryGold ?? Color(0xFFDAA520)
                        : Colors.grey,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Start SIP',
                    style: TextStyle(
                      color: widget.fund['sipAllowed'] == true
                          ? AppColors.primaryGold ?? Color(0xFFDAA520)
                          : Colors.grey,
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
    );
  }

  void _showInvestmentBottomSheet(String investmentType) {
    final TextEditingController amountController = TextEditingController();
    String? frequency = investmentType == 'SIP' ? 'M' : null; // Default to Monthly for SIP
    String errorMessage = '';
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
                            fontSize: 16.sp,
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
                                        widget.fund['name']?.toString() ?? 'Unknown Fund',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryText ?? Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Category: ${widget.fund['category']?.toString() ?? 'Equity'}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
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
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Investment Amount',
                              labelStyle: TextStyle(color: AppColors.secondaryText ?? Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.currency_rupee,
                                color: AppColors.primaryGold ?? Color(0xFFDAA520),
                              ),
                              errorText: errorMessage.isNotEmpty ? errorMessage : null,
                            ),
                            style: TextStyle(color: AppColors.primaryText ?? Colors.black87),
                          ),
                          if (investmentType == 'SIP') ...[
                            SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: frequency,
                              decoration: InputDecoration(
                                labelText: 'SIP Frequency',
                                labelStyle: TextStyle(color: AppColors.secondaryText ?? Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryGold?.withOpacity(0.3) ?? Color(0xFFDAA520).withOpacity(0.3),
                                  ),
                                ),
                              ),
                              items: [
                                DropdownMenuItem(value: 'M', child: Text('Monthly')),
                                DropdownMenuItem(value: 'D', child: Text('Daily')),
                              ],
                              onChanged: (value) {
                                setModalState(() {
                                  frequency = value;
                                });
                              },
                              style: TextStyle(color: AppColors.primaryText ?? Colors.black87),
                            ),
                          ],
                          SizedBox(height: 16),
                          isLoading
                              ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGold ?? Color(0xFFDAA520),
                            ),
                          )
                              : ElevatedButton(
                            onPressed: () async {
                              final amount = double.tryParse(amountController.text);
                              if (amount == null || amount <= 0) {
                                setModalState(() {
                                  errorMessage = 'Please enter a valid amount';
                                });
                                return;
                              }
                              setModalState(() {
                                isLoading = true;
                                errorMessage = '';
                              });

                              try {
                                Map<String, dynamic> response;
                                String approvalLink;

                                if (investmentType == 'Lumpsum') {
                                  response = await MutualFundService.purchaseLumpsum(
                                    totAmt: amount,
                                    rtaAmcCode: widget.fund['rtaAmcCode']?.toString() ?? 'FTI',
                                    rtaSchCode: widget.fund['rtaSchCode']?.toString() ?? '010',
                                    folio: widget.fund['folio']?.toString() ?? 'AKA031415712',
                                  );
                                } else {
                                  response = await MutualFundService.registerSip(
                                    totAmt: amount,
                                    rtaAmcCode: widget.fund['rtaAmcCode']?.toString() ?? 'FTI',
                                    rtaSchCode: widget.fund['rtaSchCode']?.toString() ?? '010',
                                    folio: widget.fund['folio']?.toString() ?? 'FT000001115',
                                    frequency: frequency!,
                                    day: 25, // Default day
                                    startMonth: 9, // Default start month (current month)
                                    startYear: 2025, // Default start year
                                    endMonth: 12, // Default end month
                                    endYear: 2026, // Default end year
                                  );
                                }

                                if (response['status'] == true) {
                                  approvalLink = response['data']?['approvalLink']?.toString() ?? '';
                                  if (await canLaunchUrl(Uri.parse(approvalLink))) {
                                    await launchUrl(Uri.parse(approvalLink), mode: LaunchMode.externalApplication);
                                  } else {
                                    setModalState(() {
                                      errorMessage = 'Unable to open approval link';
                                      isLoading = false;
                                    });
                                  }
                                } else {
                                  setModalState(() {
                                    errorMessage = response['message']?.toString() ?? 'Transaction failed';
                                    isLoading = false;
                                  });
                                }
                              } catch (e) {
                                setModalState(() {
                                  errorMessage = 'Error: $e';
                                  isLoading = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold?.withOpacity(0.9) ?? Color(0xFFDAA520).withOpacity(0.9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Confirm $investmentType',
                              style: TextStyle(
                                color: AppColors.buttonText ?? Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
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
      },
    );
  }
}