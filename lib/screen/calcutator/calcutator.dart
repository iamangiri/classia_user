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

  // Focus nodes
  late FocusNode _investmentFocus;
  late FocusNode _durationFocus;
  late FocusNode _returnsFocus;

  // Constraints
  static const double MIN_INVESTMENT = 500;
  static const double MAX_INVESTMENT = 200000;
  static const double MIN_DURATION = 1;
  static const double MAX_DURATION = 50;
  static const double MIN_RETURNS = 1;
  static const double MAX_RETURNS = 50;

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

    _investmentFocus = FocusNode();
    _durationFocus = FocusNode();
    _returnsFocus = FocusNode();

    calculateSIP();
  }

  @override
  void dispose() {
    _investmentController.dispose();
    _durationController.dispose();
    _returnsController.dispose();
    _investmentFocus.dispose();
    _durationFocus.dispose();
    _returnsFocus.dispose();
    super.dispose();
  }

  // Validate and update investment amount
  void _updateInvestment(String text) {
    if (text.isEmpty) return;
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
    if (text.isEmpty) return;
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
    if (text.isEmpty) return;
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
                  _buildSliderWithInput(
                    'Monthly Investment',
                    investmentAmount,
                    MIN_INVESTMENT,
                    MAX_INVESTMENT,
                    _investmentController,
                    _investmentFocus,
                        (value) {
                      setState(() {
                        investmentAmount = value;
                        _investmentController.text = value.toStringAsFixed(0);
                        calculateSIP();
                      });
                    },
                    _updateInvestment,
                    step: 500,
                    prefix: '₹',
                    isDecimal: false,
                  ),
                  SizedBox(height: 24.h),
                  _buildSliderWithInput(
                    'Investment Period',
                    duration,
                    MIN_DURATION,
                    MAX_DURATION,
                    _durationController,
                    _durationFocus,
                        (value) {
                      setState(() {
                        duration = value;
                        _durationController.text = value.toStringAsFixed(0);
                        calculateSIP();
                      });
                    },
                    _updateDuration,
                    step: 1,
                    suffix: 'years',
                    isDecimal: false,
                  ),
                  SizedBox(height: 24.h),
                  _buildSliderWithInput(
                    'Expected Return (p.a.)',
                    expectedReturns,
                    MIN_RETURNS,
                    MAX_RETURNS,
                    _returnsController,
                    _returnsFocus,
                        (value) {
                      setState(() {
                        expectedReturns = value;
                        _returnsController.text = value.toStringAsFixed(1);
                        calculateSIP();
                      });
                    },
                    _updateReturns,
                    step: 0.5,
                    suffix: '%',
                    isDecimal: true,
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

            // Formula Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Color(0xFFDAA520).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        color: Color(0xFFDAA520),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'SIP Formula',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A1F3A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFDAA520).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FV = P × [((1 + r)ⁿ - 1) / r] × (1 + r)',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A1F3A),
                            fontFamily: 'monospace',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Where:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        _buildFormulaRow('FV', 'Future Value (Maturity Amount)'),
                        _buildFormulaRow('P', 'Monthly Investment Amount'),
                        _buildFormulaRow('r', 'Monthly Rate of Return (Annual Rate / 12)'),
                        _buildFormulaRow('n', 'Total Number of Months (Years × 12)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

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

  Widget _buildSliderWithInput(
      String title,
      double currentValue,
      double min,
      double max,
      TextEditingController controller,
      FocusNode focusNode,
      Function(double) onSliderChanged,
      Function(String) onTextChanged, {
        required double step,
        String? prefix,
        String? suffix,
        required bool isDecimal,
      }) {
    int divisions = ((max - min) / step).round();

    String displayValue = '';
    if (prefix != null) displayValue += prefix;
    displayValue += isDecimal
        ? currentValue.toStringAsFixed(1)
        : currentValue.toStringAsFixed(0);
    if (suffix != null) displayValue += ' $suffix';

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
            // Editable Input Box
            Container(
              width: 140.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Color(0xFFDAA520).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  if (prefix != null)
                    Padding(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Text(
                        prefix,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A1F3A),
                        ),
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: isDecimal,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          isDecimal
                              ? RegExp(r'^\d+\.?\d{0,1}')
                              : RegExp(r'^\d+'),
                        ),
                      ],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A1F3A),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                        hintText: isDecimal ? '0.0' : '0',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15.sp,
                        ),
                      ),
                      onChanged: onTextChanged,
                      onSubmitted: (value) {
                        onTextChanged(value);
                        focusNode.unfocus();
                      },
                    ),
                  ),
                  if (suffix != null)
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Text(
                        suffix,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // Range hint
        Text(
          'Range: ${_formatRangeValue(min, prefix, suffix, isDecimal)} - ${_formatRangeValue(max, prefix, suffix, isDecimal)}',
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
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
            label: displayValue,
            onChanged: onSliderChanged,
          ),
        ),
      ],
    );
  }

  String _formatRangeValue(double value, String? prefix, String? suffix, bool isDecimal) {
    String result = '';
    if (prefix != null) result += prefix;
    result += isDecimal ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
    if (suffix != null) result += ' $suffix';
    return result;
  }

  Widget _buildFormulaRow(String symbol, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h, left: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            child: Text(
              '$symbol =',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDAA520),
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
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