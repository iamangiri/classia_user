import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'dart:math' as math;

class SIPCalculatorScreen extends StatefulWidget {
  const SIPCalculatorScreen({Key? key}) : super(key: key);

  @override
  _SIPCalculatorScreenState createState() => _SIPCalculatorScreenState();
}

class _SIPCalculatorScreenState extends State<SIPCalculatorScreen> {
  // Input values with proper constraints
  double investmentAmount = 5000; // Default 5000
  double duration = 10; // Default 10 years
  double expectedReturns = 12; // Default 12%

  // Result values
  double totalInvested = 0;
  double maturityValue = 0;
  double totalGains = 0;

  // Controllers for input fields
  late TextEditingController _investmentController;
  late TextEditingController _durationController;
  late TextEditingController _returnsController;

  // Constraints
  static const double MIN_INVESTMENT = 500;
  static const double MAX_INVESTMENT = 100000;
  static const double MIN_DURATION = 1;
  static const double MAX_DURATION = 30;
  static const double MIN_RETURNS = 1;
  static const double MAX_RETURNS = 30;

  @override
  void initState() {
    super.initState();
    _investmentController = TextEditingController(
      text: investmentAmount.toStringAsFixed(0),
    );
    _durationController = TextEditingController(
      text: duration.toStringAsFixed(0),
    );
    _returnsController = TextEditingController(
      text: expectedReturns.toStringAsFixed(1),
    );
    calculateSIP();
  }

  @override
  void dispose() {
    _investmentController.dispose();
    _durationController.dispose();
    _returnsController.dispose();
    super.dispose();
  }

  // Validate and update investment amount
  void _updateInvestment(String text) {
    final newValue = double.tryParse(text);
    if (newValue != null) {
      final clampedValue = newValue.clamp(MIN_INVESTMENT, MAX_INVESTMENT);
      setState(() {
        investmentAmount = clampedValue;
        calculateSIP();
      });
      // Update controller only if value was clamped
      if (clampedValue != newValue) {
        _investmentController.text = clampedValue.toStringAsFixed(0);
        _investmentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _investmentController.text.length),
        );
      }
    }
  }

  // Validate and update duration
  void _updateDuration(String text) {
    final newValue = double.tryParse(text);
    if (newValue != null) {
      final clampedValue = newValue.clamp(MIN_DURATION, MAX_DURATION);
      setState(() {
        duration = clampedValue;
        calculateSIP();
      });
      // Update controller only if value was clamped
      if (clampedValue != newValue) {
        _durationController.text = clampedValue.toStringAsFixed(0);
        _durationController.selection = TextSelection.fromPosition(
          TextPosition(offset: _durationController.text.length),
        );
      }
    }
  }

  // Validate and update expected returns
  void _updateReturns(String text) {
    final newValue = double.tryParse(text);
    if (newValue != null) {
      final clampedValue = newValue.clamp(MIN_RETURNS, MAX_RETURNS);
      setState(() {
        expectedReturns = clampedValue;
        calculateSIP();
      });
      // Update controller only if value was clamped
      if (clampedValue != newValue) {
        _returnsController.text = clampedValue.toStringAsFixed(1);
        _returnsController.selection = TextSelection.fromPosition(
          TextPosition(offset: _returnsController.text.length),
        );
      }
    }
  }

  void calculateSIP() {
    // Ensure values are within bounds
    investmentAmount = investmentAmount.clamp(MIN_INVESTMENT, MAX_INVESTMENT);
    duration = duration.clamp(MIN_DURATION, MAX_DURATION);
    expectedReturns = expectedReturns.clamp(MIN_RETURNS, MAX_RETURNS);

    double monthlyRate = expectedReturns / 100 / 12;
    int totalMonths = (duration * 12).toInt();

    // Calculate total invested
    totalInvested = investmentAmount * totalMonths;

    // Calculate maturity value using proper SIP formula
    // FV = P × ((1 + r)^n - 1) / r) × (1 + r)
    if (monthlyRate > 0) {
      maturityValue = investmentAmount *
          ((math.pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate) *
          (1 + monthlyRate);
    } else {
      maturityValue = totalInvested;
    }

    // Calculate total gains
    totalGains = maturityValue - totalInvested;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'SIP Calculator',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Controls Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Investment Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1F3A),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildSlider(
                    'Monthly Investment',
                    '₹${_formatNumber(investmentAmount)}',
                    investmentAmount,
                    MIN_INVESTMENT,
                    MAX_INVESTMENT,
                        (value) {
                      setState(() {
                        investmentAmount = value;
                        calculateSIP();
                      });
                    },
                    step: 500,
                  ),
                  SizedBox(height: 24.h),
                  _buildSlider(
                    'Investment Period',
                    '${duration.toInt()} years',
                    duration,
                    MIN_DURATION,
                    MAX_DURATION,
                        (value) {
                      setState(() {
                        duration = value;
                        calculateSIP();
                      });
                    },
                    step: 1,
                  ),
                  SizedBox(height: 24.h),
                  _buildSlider(
                    'Expected Return (p.a.)',
                    '${expectedReturns.toStringAsFixed(1)}%',
                    expectedReturns,
                    MIN_RETURNS,
                    MAX_RETURNS,
                        (value) {
                      setState(() {
                        expectedReturns = value;
                        calculateSIP();
                      });
                    },
                    step: 0.5,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Results Section - Stacked Cards
            Text(
              'Investment Summary',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1F3A),
              ),
            ),
            SizedBox(height: 12.h),

            // Total Invested Card
            _buildResultCard(
              icon: Icons.wallet_outlined,
              title: 'Total Invested',
              value: '₹${_formatAmount(totalInvested)}',
              color: Color(0xFF2196F3),
              backgroundColor: Color(0xFF2196F3).withOpacity(0.1),
            ),

            SizedBox(height: 12.h),

            // Maturity Value Card
            _buildResultCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Maturity Value',
              value: '₹${_formatAmount(maturityValue)}',
              color: Color(0xFFDAA520),
              backgroundColor: Color(0xFFDAA520).withOpacity(0.1),
            ),

            SizedBox(height: 12.h),

            // Total Gains Card
            _buildResultCard(
              icon: Icons.trending_up,
              title: 'Total Gains',
              value: '₹${_formatAmount(totalGains)}',
              color: Color(0xFF4CAF50),
              backgroundColor: Color(0xFF4CAF50).withOpacity(0.1),
              subtitle: totalInvested > 0
                  ? '+${((totalGains / totalInvested) * 100).toStringAsFixed(1)}% returns'
                  : null,
            ),

            SizedBox(height: 24.h),

            // Detailed Information Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFDAA520).withOpacity(0.1),
                    Color(0xFFDAA520).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Color(0xFFDAA520).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFDAA520),
                        size: 22.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Investment Breakdown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A1F3A),
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoRow(
                    'Monthly SIP',
                    '₹${_formatNumber(investmentAmount)}',
                  ),
                  _buildInfoRow(
                    'Investment Period',
                    '${duration.toInt()} years (${(duration * 12).toInt()} months)',
                  ),
                  _buildInfoRow(
                    'Expected Annual Return',
                    '${expectedReturns.toStringAsFixed(1)}%',
                  ),
                  _buildInfoRow(
                    'Total Amount Invested',
                    '₹${_formatAmount(totalInvested)}',
                  ),
                  Divider(
                    height: 24.h,
                    color: Color(0xFFDAA520).withOpacity(0.3),
                    thickness: 1,
                  ),
                  _buildInfoRow(
                    'Wealth Created',
                    '₹${_formatAmount(totalGains)}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Disclaimer
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange[700],
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'This calculator provides an estimate based on assumed returns. Actual returns may vary depending on market conditions.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
      String title,
      String value,
      double currentValue,
      double min,
      double max,
      Function(double) onChanged, {
        required double step,
      }) {
    int divisions = ((max - min) / step).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Color(0xFFDAA520).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Color(0xFFDAA520).withOpacity(0.3),
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1F3A),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFFDAA520),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Color(0xFFDAA520),
            overlayColor: Color(0xFFDAA520).withOpacity(0.2),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
            trackHeight: 4.h,
            valueIndicatorColor: Color(0xFFDAA520),
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Slider(
            value: currentValue.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions > 0 ? divisions : null,
            label: value,
            onChanged: onChanged,
          ),
        ),
        // Min-Max labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.contains('Investment')
                  ? '${_formatNumber(min)}'
                  : title.contains('Period')
                  ? '${min.toInt()}Y'
                  : '${min.toInt()}%',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[500],
              ),
            ),
            Text(
              title.contains('Investment')
                  ? '${_formatNumber(max)}'
                  : title.contains('Period')
                  ? '${max.toInt()}Y'
                  : '${max.toInt()}%',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color backgroundColor,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: color,
                      fontWeight: FontWeight.w600,
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

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: isHighlight ? Color(0xFF0A1F3A) : Colors.grey[700],
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isHighlight ? Color(0xFF4CAF50) : Color(0xFF0A1F3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      // 1 crore
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      // 1 lakh
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      // 1 thousand
      return '${(amount / 1000).toStringAsFixed(2)} K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}