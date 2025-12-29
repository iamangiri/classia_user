import 'dart:convert';
import 'package:classia_amc/screen/sip/sip_goal_amc_fund.dart';
import 'package:classia_amc/screen/sip/sip_model.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../service/apiservice/sip_service.dart' show SipService;
import '../../themes/app_colors.dart';

class SipGoalBasedFundScreen extends StatefulWidget {
  final ExploreGoal goal;

  const SipGoalBasedFundScreen({super.key, required this.goal});

  @override
  _SipGoalBasedFundScreenState createState() => _SipGoalBasedFundScreenState();
}

class _SipGoalBasedFundScreenState extends State<SipGoalBasedFundScreen>
    with TickerProviderStateMixin {
  String _frequency = 'monthly';
  double _period = 12;
  double _monthlyAmount = 5000;
  final List<Fund> _selectedAMCFunds = [];
  final List<Fund> _selectedTopFunds = [];
  final Map<Fund, double> _fundPercentages = {};
  bool _topUpEnabled = false;
  String _topUpType = 'value';
  double _topUpValue = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Text controllers for input boxes
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Validation constants
  static const double DAILY_MIN = 100;
  static const double DAILY_MAX = 10000;
  static const double MONTHLY_MIN = 1000;
  static const double MONTHLY_MAX = 200000;
  static const double PERIOD_MIN_MONTHS = 1;
  static const double PERIOD_MAX_MONTHS = 60;
  static const double PERIOD_MIN_YEARS = 1;
  static const double PERIOD_MAX_YEARS = 30;

  // Expected return rate (can be made dynamic based on fund selection)
  static const double EXPECTED_ANNUAL_RETURN = 12.0; // 12% annual return

  // Helper methods for dynamic text based on frequency
  String get _periodLabel => _frequency == 'daily' ? 'months' : 'years';

  String get _periodDisplayValue => _frequency == 'daily'
      ? '${(_period).toStringAsFixed(1)} months'
      : '${(_period / 12).toStringAsFixed(1)} years';

  String get _amountLabel =>
      _frequency == 'daily' ? 'Daily Investment Amount' : 'Monthly Investment Amount';

  String get _amountDisplayValue => _frequency == 'daily'
      ? '₹${_getDisplayAmount().toStringAsFixed(0)} / day'
      : '₹${_monthlyAmount.toStringAsFixed(0)} / month';

  double _getDisplayAmount() =>
      _frequency == 'daily' ? _monthlyAmount / 30 : _monthlyAmount;

  // ==================== NEW: Investment Summary Calculations ====================

  /// Calculate total investment amount
  double get _totalInvestment {
    if (_frequency == 'daily') {
      // Daily investment * 30 days * months
      return (_monthlyAmount / 30) * 30 * _period;
    } else {
      // Monthly investment * months
      return _monthlyAmount * _period;
    }
  }

  /// Calculate expected returns using compound interest formula for SIP
  /// FV = P × [(1 + r)^n - 1] / r × (1 + r)
  double get _expectedReturns {
    double monthlyRate = EXPECTED_ANNUAL_RETURN / 12 / 100;
    int totalMonths = _frequency == 'daily' ? _period.toInt() : _period.toInt();
    double monthlyInvestment = _frequency == 'daily' ? _monthlyAmount : _monthlyAmount;

    if (monthlyRate == 0) return _totalInvestment;

    // SIP Future Value formula
    double futureValue = monthlyInvestment *
        ((pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate) *
        (1 + monthlyRate);

    // Apply top-up if enabled
    if (_topUpEnabled && _topUpValue > 0) {
      futureValue = _calculateWithTopUp(monthlyInvestment, monthlyRate, totalMonths);
    }

    return futureValue;
  }

  /// Calculate with top-up
  double _calculateWithTopUp(double initialMonthly, double monthlyRate, int totalMonths) {
    double futureValue = 0;
    double currentMonthly = initialMonthly;

    for (int month = 1; month <= totalMonths; month++) {
      futureValue = (futureValue + currentMonthly) * (1 + monthlyRate);

      // Apply top-up annually (every 12 months)
      if (month % 12 == 0 && month < totalMonths) {
        if (_topUpType == 'percentage') {
          currentMonthly *= (1 + _topUpValue / 100);
        } else {
          currentMonthly += _topUpValue;
        }
      }
    }

    return futureValue;
  }

  /// Calculate total investment with top-up
  double get _totalInvestmentWithTopUp {
    if (!_topUpEnabled || _topUpValue <= 0) return _totalInvestment;

    double total = 0;
    double currentMonthly = _frequency == 'daily' ? _monthlyAmount : _monthlyAmount;
    int totalMonths = _frequency == 'daily' ? _period.toInt() : _period.toInt();

    for (int month = 1; month <= totalMonths; month++) {
      total += currentMonthly;

      // Apply top-up annually
      if (month % 12 == 0 && month < totalMonths) {
        if (_topUpType == 'percentage') {
          currentMonthly *= (1 + _topUpValue / 100);
        } else {
          currentMonthly += _topUpValue;
        }
      }
    }

    return total;
  }

  /// Calculate profit
  double get _expectedProfit {
    double investment = _topUpEnabled ? _totalInvestmentWithTopUp : _totalInvestment;
    return _expectedReturns - investment;
  }

  /// Calculate profit percentage
  double get _profitPercentage {
    double investment = _topUpEnabled ? _totalInvestmentWithTopUp : _totalInvestment;
    if (investment == 0) return 0;
    return (_expectedProfit / investment) * 100;
  }

  /// Helper function for power calculation
  double pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  /// Calculate weighted average return rate from selected funds
  double get _weightedAverageReturn {
    final allFunds = [..._selectedAMCFunds, ..._selectedTopFunds];
    if (allFunds.isEmpty) return EXPECTED_ANNUAL_RETURN;

    double totalWeightedReturn = 0;
    double totalPercentage = 0;

    for (var fund in allFunds) {
      double percentage = _fundPercentages[fund] ?? 0;
      double returnRate = _parseReturnRate(fund.returnRate);
      totalWeightedReturn += returnRate * percentage;
      totalPercentage += percentage;
    }

    if (totalPercentage == 0) return EXPECTED_ANNUAL_RETURN;
    return totalWeightedReturn / totalPercentage;
  }

  /// Parse return rate from string (e.g., "12.5%" -> 12.5)
  double _parseReturnRate(String returnRate) {
    try {
      String cleaned = returnRate.replaceAll('%', '').replaceAll(' ', '');
      return double.tryParse(cleaned) ?? EXPECTED_ANNUAL_RETURN;
    } catch (e) {
      return EXPECTED_ANNUAL_RETURN;
    }
  }

  // ==================== NEW: Auto-distribute percentages equally ====================

  void _distributePercentagesEqually() {
    final allFunds = [..._selectedAMCFunds, ..._selectedTopFunds];
    if (allFunds.isEmpty) return;

    double equalPercentage = 100.0 / allFunds.length;
    // Round to 1 decimal place
    equalPercentage = (equalPercentage * 10).round() / 10;

    // Calculate remainder to ensure total is exactly 100%
    double totalAssigned = equalPercentage * (allFunds.length - 1);
    double lastPercentage = 100.0 - totalAssigned;

    setState(() {
      for (int i = 0; i < allFunds.length; i++) {
        if (i == allFunds.length - 1) {
          _fundPercentages[allFunds[i]] = (lastPercentage * 10).round() / 10;
        } else {
          _fundPercentages[allFunds[i]] = equalPercentage;
        }
      }
    });
  }

  // Validation helper methods
  String? _getPeriodErrorText() {
    double value = double.tryParse(_periodController.text) ?? 0;
    if (_periodController.text.isEmpty) return null;

    if (_frequency == 'daily') {
      if (value < PERIOD_MIN_MONTHS) return 'Min: ${PERIOD_MIN_MONTHS.toInt()}';
      if (value > PERIOD_MAX_MONTHS) return 'Max: ${PERIOD_MAX_MONTHS.toInt()}';
    } else {
      if (value < PERIOD_MIN_YEARS) return 'Min: ${PERIOD_MIN_YEARS.toInt()}';
      if (value > PERIOD_MAX_YEARS) return 'Max: ${PERIOD_MAX_YEARS.toInt()}';
    }
    return null;
  }

  String? _getAmountErrorText() {
    double value = double.tryParse(_amountController.text) ?? 0;
    if (_amountController.text.isEmpty) return null;

    if (_frequency == 'daily') {
      if (value < DAILY_MIN) return 'Min: ₹${DAILY_MIN.toInt()}';
      if (value > DAILY_MAX) return 'Max: ₹${DAILY_MAX.toInt()}';
    } else {
      if (value < MONTHLY_MIN) return 'Min: ₹${MONTHLY_MIN.toInt()}';
      if (value > MONTHLY_MAX) return 'Max: ₹${MONTHLY_MAX.toInt()}';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Set default amount for daily frequency
    if (_frequency == 'daily') {
      _monthlyAmount = 100 * 30;
    }

    // Initialize text controllers
    _updateControllers();
  }

  void _updateControllers() {
    // Update period controller
    if (_frequency == 'daily') {
      _periodController.text = _period.toStringAsFixed(0);
    } else {
      _periodController.text = (_period / 12).toStringAsFixed(1);
    }

    // Update amount controller
    _amountController.text = _getDisplayAmount().toStringAsFixed(0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _periodController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveSip(Sip sip) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sips = prefs.getStringList('sips') ?? [];
    sips.add(jsonEncode(sip.toJson()));
    await prefs.setStringList('sips', sips);
  }

  // ==================== NEW: Investment Summary Widget ====================

  Widget _buildInvestmentSummaryCard() {
    final allFunds = [..._selectedAMCFunds, ..._selectedTopFunds];
    double totalPercentage = allFunds.fold(
        0.0, (sum, fund) => sum + (_fundPercentages[fund] ?? 0.0));

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withOpacity(0.95),
            const Color(0xFF283593).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 15.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Investment Summary',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_weightedAverageReturn.toStringAsFixed(1)}% p.a.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Summary Grid
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Total Investment',
                  value: '₹${_formatCurrency(_topUpEnabled ? _totalInvestmentWithTopUp : _totalInvestment)}',
                  iconColor: Colors.amber,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Expected Returns',
                  value: '₹${_formatCurrency(_expectedReturns)}',
                  iconColor: Colors.greenAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.emoji_events_outlined,
                  label: 'Expected Profit',
                  value: '₹${_formatCurrency(_expectedProfit)}',
                  subValue: '+${_profitPercentage.toStringAsFixed(1)}%',
                  iconColor: Colors.lightGreenAccent,
                  valueColor: Colors.lightGreenAccent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.pie_chart_outline,
                  label: 'Fund Allocation',
                  value: '${totalPercentage.toStringAsFixed(1)}%',
                  subValue: totalPercentage == 100 ? '✓ Complete' : '${(100 - totalPercentage).toStringAsFixed(1)}% remaining',
                  iconColor: totalPercentage == 100 ? Colors.greenAccent : Colors.orangeAccent,
                  valueColor: totalPercentage == 100 ? Colors.greenAccent : Colors.orangeAccent,
                ),
              ),
            ],
          ),

          // Progress bar for total allocation
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Allocation Progress',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '${totalPercentage.toStringAsFixed(1)}% / 100%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: (totalPercentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    totalPercentage == 100
                        ? Colors.greenAccent
                        : totalPercentage > 100
                        ? Colors.redAccent
                        : AppColors.primaryGold ?? const Color(0xFFDAA520),
                  ),
                  minHeight: 8.h,
                ),
              ),
            ],
          ),

          // Quick info
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _frequency == 'daily'
                        ? '₹${_getDisplayAmount().toStringAsFixed(0)}/day × ${_period.toInt()} months = ₹${_formatCurrency(_totalInvestment)}'
                        : '₹${_monthlyAmount.toStringAsFixed(0)}/month × ${(_period / 12).toStringAsFixed(1)} years = ₹${_formatCurrency(_totalInvestment)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white70,
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

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.white,
            ),
          ),
          if (subValue != null) ...[
            SizedBox(height: 2.h),
            Text(
              subValue,
              style: TextStyle(
                fontSize: 10.sp,
                color: valueColor ?? Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(2)} L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)} K';
    }
    return value.toStringAsFixed(0);
  }

  void _showSelectedFundsBottomSheet() {
    final allFunds = [..._selectedAMCFunds, ..._selectedTopFunds];
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surfaceColor?.withOpacity(0.95) ??
                  Colors.grey[100]!.withOpacity(0.95),
              AppColors.backgroundColor?.withOpacity(0.9) ??
                  Colors.white.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryText?.withOpacity(0.3) ??
                    Colors.grey[400],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Lottie.asset(
              'assets/anim/sip_anim_success.json',
              height: 80.h,
              width: 80.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 12.h),
            Text(
              'Selected Funds',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor ?? Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            if (allFunds.isEmpty)
              Text(
                'No funds selected',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.secondaryText ?? Colors.grey,
                ),
              )
            else
              ...allFunds.asMap().entries.map((entry) {
                int index = entry.key;
                Fund fund = entry.value;
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                fund.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.secondaryText ?? Colors.grey,
                                ),
                              ),
                            ),
                            Text(
                              '${(_fundPercentages[fund] ?? 0.0).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primaryGold ??
                                    const Color(0xFFDAA520),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
                shadowColor: Colors.transparent,
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => AppColors.primaryGold ?? const Color(0xFFDAA520),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSipConfirmationDialog() {
    final allFunds = [..._selectedAMCFunds, ..._selectedTopFunds];
    double totalPercentage = allFunds.fold(
        0.0, (sum, fund) => sum + (_fundPercentages[fund] ?? 0.0));
    if (allFunds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one fund')),
      );
      return;
    }
    if (totalPercentage != 100.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total fund allocation must be 100%')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surfaceColor?.withOpacity(0.95) ??
                    Colors.grey[100]!.withOpacity(0.95),
                AppColors.backgroundColor?.withOpacity(0.9) ??
                    Colors.white.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/anim/sip_anim_success.json',
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Your SIP is Ready to Start!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor ?? Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Enhanced Summary in Dialog
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      _buildDialogSummaryRow('Goal', widget.goal.name),
                      _buildDialogSummaryRow('Frequency', '${_frequency[0].toUpperCase()}${_frequency.substring(1)}'),
                      _buildDialogSummaryRow('Period', _periodDisplayValue),
                      _buildDialogSummaryRow(
                        '${_frequency == 'daily' ? 'Daily' : 'Monthly'} Amount',
                        '₹${_getDisplayAmount().toStringAsFixed(0)}',
                      ),
                      Divider(height: 16.h),
                      _buildDialogSummaryRow(
                        'Total Investment',
                        '₹${_formatCurrency(_topUpEnabled ? _totalInvestmentWithTopUp : _totalInvestment)}',
                        isBold: true,
                      ),
                      _buildDialogSummaryRow(
                        'Expected Returns',
                        '₹${_formatCurrency(_expectedReturns)}',
                        valueColor: Colors.green,
                        isBold: true,
                      ),
                      _buildDialogSummaryRow(
                        'Expected Profit',
                        '₹${_formatCurrency(_expectedProfit)} (+${_profitPercentage.toStringAsFixed(1)}%)',
                        valueColor: Colors.green,
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),
                Text(
                  'Selected Funds:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor ?? Colors.blue,
                  ),
                ),
                ...allFunds.map(
                      (fund) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Text(
                      '• ${fund.name} (${_fundPercentages[fund]?.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.secondaryText ?? Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (_topUpEnabled)
                  Text(
                    'Top-up: ${_topUpValue.toStringAsFixed(1)} ${_topUpType == 'percentage' ? '%' : '₹'}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.secondaryText ?? Colors.grey,
                    ),
                  ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.error ?? Colors.red,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final sipService = SipService();
                          final responseData = await sipService.registerSip(
                            totalAmount: _monthlyAmount,
                            funds: allFunds,
                            fundPercentages: _fundPercentages,
                            frequency: _frequency,
                            endMonth: 9,
                            endYear: 2026,
                          );

                          if (responseData['status'] == true) {
                            Goal newGoal = Goal(
                              id: widget.goal.toGoal().id,
                              name: widget.goal.name,
                              icon: widget.goal.icon ?? Icons.star,
                              target: _monthlyAmount * _period,
                              current: widget.goal.toGoal().current,
                              monthlyPayment: widget.goal.toGoal().monthlyPayment,
                              color: widget.goal.color,
                              progress: widget.goal.toGoal().progress,
                              lottieAsset: widget.goal.lottieAsset ??
                                  'assets/anim/sip_anim_1.json',
                            );
                            Sip newSip = Sip(
                              id: DateTime.now().millisecondsSinceEpoch,
                              goal: newGoal,
                              frequency: _frequency,
                              periodMonths: _period.round(),
                              monthlyAmount: _monthlyAmount,
                              funds: allFunds
                                  .map((f) => FundAllocation(
                                fund: f,
                                percentage: _fundPercentages[f] ?? 0.0,
                              ))
                                  .toList(),
                              topUp: _topUpEnabled
                                  ? TopUp(
                                type: _topUpType,
                                value: _topUpValue,
                                enabled: true,
                              )
                                  : null,
                            );
                            await _saveSip(newSip);

                            final approvalLink =
                            responseData['data']['approvalLink'] as String?;
                            if (approvalLink != null &&
                                approvalLink.isNotEmpty) {
                              final Uri uri = Uri.parse(approvalLink);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(responseData['message'])),
                            );

                            if (mounted) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'SIP registration failed: ${responseData['message']}')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error registering SIP: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith(
                              (states) =>
                          AppColors.primaryGold ?? const Color(0xFFDAA520),
                        ),
                      ),
                      child: Text(
                        'Confirm SIP',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildDialogSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.secondaryText ?? Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? (AppColors.primaryColor ?? Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allFunds = [..._selectedAMCFunds, ..._selectedTopFunds];
    return Scaffold(
      appBar: CommonAppBar(title: 'Invest in ${widget.goal.name}'),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== NEW: Investment Summary Card ====================
              _buildInvestmentSummaryCard(),
              SizedBox(height: 16.h),

              // SIP Frequency
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surfaceColor?.withOpacity(0.9) ??
                          Colors.grey[100]!.withOpacity(0.9),
                      AppColors.backgroundColor?.withOpacity(0.95) ??
                          Colors.white.withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIP Frequency',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor ?? Colors.blue,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(
                              'Daily',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _frequency == 'daily'
                                    ? Colors.white
                                    : AppColors.secondaryText ?? Colors.grey,
                              ),
                            ),
                            selected: _frequency == 'daily',
                            selectedColor:
                            AppColors.primaryGold ?? const Color(0xFFDAA520),
                            onSelected: (selected) => setState(() {
                              _frequency = 'daily';
                              _monthlyAmount = 100 * 30;
                              _period = 12;
                              _updateControllers();
                            }),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(
                              'Monthly',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _frequency == 'monthly'
                                    ? Colors.white
                                    : AppColors.secondaryText ?? Colors.grey,
                              ),
                            ),
                            selected: _frequency == 'monthly',
                            selectedColor:
                            AppColors.primaryGold ?? const Color(0xFFDAA520),
                            onSelected: (selected) => setState(() {
                              _frequency = 'monthly';
                              _monthlyAmount = 5000;
                              _period = 12;
                              _updateControllers();
                            }),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Investment Period with Input Box
                    Text(
                      'Investment Period',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor ?? Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Slider(
                            value: _period,
                            min: _frequency == 'daily'
                                ? PERIOD_MIN_MONTHS
                                : (PERIOD_MIN_YEARS * 12),
                            max: _frequency == 'daily'
                                ? PERIOD_MAX_MONTHS
                                : (PERIOD_MAX_YEARS * 12),
                            divisions: _frequency == 'daily'
                                ? (PERIOD_MAX_MONTHS - PERIOD_MIN_MONTHS).toInt()
                                : ((PERIOD_MAX_YEARS - PERIOD_MIN_YEARS) * 12)
                                .toInt(),
                            label: _periodDisplayValue,
                            activeColor:
                            AppColors.primaryGold ?? const Color(0xFFDAA520),
                            inactiveColor:
                            AppColors.secondaryText?.withOpacity(0.3) ??
                                Colors.grey[300],
                            onChanged: (value) => setState(() {
                              _period = value;
                              _updateControllers();
                            }),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        SizedBox(
                          width: 75.w,
                          child: TextField(
                            controller: _periodController,
                            keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*')),
                              LengthLimitingTextInputFormatter(5),
                            ],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 10.h),
                              isDense: true,
                              errorText: _getPeriodErrorText(),
                              errorStyle: TextStyle(fontSize: 8.sp),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) return;

                              double? parsed = double.tryParse(value);
                              if (parsed != null) {
                                if (_frequency == 'daily') {
                                  if (parsed >= PERIOD_MIN_MONTHS &&
                                      parsed <= PERIOD_MAX_MONTHS) {
                                    setState(() => _period = parsed);
                                  } else if (parsed > PERIOD_MAX_MONTHS) {
                                    setState(() {
                                      _period = PERIOD_MAX_MONTHS;
                                      _periodController.text =
                                          PERIOD_MAX_MONTHS.toStringAsFixed(0);
                                      _periodController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                                offset:
                                                _periodController.text.length),
                                          );
                                    });
                                  }
                                } else {
                                  double months = parsed * 12;
                                  if (months >= (PERIOD_MIN_YEARS * 12) &&
                                      months <= (PERIOD_MAX_YEARS * 12)) {
                                    setState(() => _period = months);
                                  } else if (months > (PERIOD_MAX_YEARS * 12)) {
                                    setState(() {
                                      _period = PERIOD_MAX_YEARS * 12;
                                      _periodController.text =
                                          PERIOD_MAX_YEARS.toStringAsFixed(1);
                                      _periodController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                                offset:
                                                _periodController.text.length),
                                          );
                                    });
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _periodDisplayValue,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.secondaryText ?? Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Monthly/Daily Investment with Input Box
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surfaceColor?.withOpacity(0.9) ??
                          Colors.grey[100]!.withOpacity(0.9),
                      AppColors.backgroundColor?.withOpacity(0.95) ??
                          Colors.white.withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _amountLabel,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor ?? Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Slider(
                            value: _frequency == 'daily'
                                ? _monthlyAmount / 30
                                : _monthlyAmount,
                            min: _frequency == 'daily' ? DAILY_MIN : MONTHLY_MIN,
                            max: _frequency == 'daily' ? DAILY_MAX : MONTHLY_MAX,
                            divisions: _frequency == 'daily'
                                ? ((DAILY_MAX - DAILY_MIN) / 100).toInt()
                                : ((MONTHLY_MAX - MONTHLY_MIN) / 1000).toInt(),
                            label: '₹${_getDisplayAmount().toStringAsFixed(0)}',
                            activeColor:
                            AppColors.primaryGold ?? const Color(0xFFDAA520),
                            inactiveColor:
                            AppColors.secondaryText?.withOpacity(0.3) ??
                                Colors.grey[300],
                            onChanged: (value) => setState(() {
                              if (_frequency == 'daily') {
                                _monthlyAmount = value * 30;
                              } else {
                                _monthlyAmount = value;
                              }
                              _updateControllers();
                            }),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        SizedBox(
                          width: 75.w,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              prefixText: '₹',
                              prefixStyle: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 10.h),
                              isDense: true,
                              errorText: _getAmountErrorText(),
                              errorStyle: TextStyle(fontSize: 8.sp),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) return;

                              double? parsed = double.tryParse(value);
                              if (parsed != null) {
                                if (_frequency == 'daily') {
                                  if (parsed >= DAILY_MIN &&
                                      parsed <= DAILY_MAX) {
                                    setState(() => _monthlyAmount = parsed * 30);
                                  } else if (parsed > DAILY_MAX) {
                                    setState(() {
                                      _monthlyAmount = DAILY_MAX * 30;
                                      _amountController.text =
                                          DAILY_MAX.toStringAsFixed(0);
                                      _amountController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                                offset:
                                                _amountController.text.length),
                                          );
                                    });
                                  }
                                } else {
                                  if (parsed >= MONTHLY_MIN &&
                                      parsed <= MONTHLY_MAX) {
                                    setState(() => _monthlyAmount = parsed);
                                  } else if (parsed > MONTHLY_MAX) {
                                    setState(() {
                                      _monthlyAmount = MONTHLY_MAX;
                                      _amountController.text =
                                          MONTHLY_MAX.toStringAsFixed(0);
                                      _amountController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                                offset:
                                                _amountController.text.length),
                                          );
                                    });
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _amountDisplayValue,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.secondaryText ?? Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Button Row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final selectedAMC = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AMCListScreen()),
                                  );
                                  if (selectedAMC != null) {
                                    final selectedSchemes =
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SchemeListScreen(amc: selectedAMC),
                                      ),
                                    );
                                    if (selectedSchemes != null &&
                                        selectedSchemes.isNotEmpty) {
                                      setState(() {
                                        for (var scheme in selectedSchemes) {
                                          Fund newFund = scheme.toFund();
                                          if (!_selectedAMCFunds.any(
                                                  (f) => f.name == newFund.name) &&
                                              !_selectedTopFunds.any(
                                                      (f) => f.name == newFund.name)) {
                                            _selectedAMCFunds.add(newFund);
                                            _fundPercentages[newFund] = 0.0;
                                          }
                                        }
                                        // Auto-distribute percentages equally
                                        _distributePercentagesEqually();
                                      });
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r)),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ).copyWith(
                                  backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                        (states) =>
                                    AppColors.primaryColor ?? Colors.blue,
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Select AMC',
                                    style: TextStyle(
                                        fontSize: 13.sp, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final selectedFunds = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const TopFundsScreen()),
                                  );
                                  if (selectedFunds != null &&
                                      selectedFunds.isNotEmpty) {
                                    setState(() {
                                      for (var fund in selectedFunds) {
                                        if (!_selectedAMCFunds.any(
                                                (f) => f.name == fund.name) &&
                                            !_selectedTopFunds.any(
                                                    (f) => f.name == fund.name)) {
                                          _selectedTopFunds.add(fund);
                                          _fundPercentages[fund] = 0.0;
                                        }
                                      }
                                      // Auto-distribute percentages equally
                                      _distributePercentagesEqually();
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r)),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ).copyWith(
                                  backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                        (states) => AppColors.primaryGold ??
                                        const Color(0xFFDAA520),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Top Funds',
                                    style: TextStyle(
                                        fontSize: 13.sp, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Selected Funds Section
              if (allFunds.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selected Funds',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor ?? Colors.blue,
                          ),
                        ),
                        // ==================== NEW: Auto-distribute button ====================
                        TextButton.icon(
                          onPressed: _distributePercentagesEqually,
                          icon: Icon(
                            Icons.auto_fix_high,
                            size: 16.sp,
                            color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                          ),
                          label: Text(
                            'Equal Split',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surfaceColor?.withOpacity(0.9) ??
                                Colors.grey[100]!.withOpacity(0.9),
                            AppColors.backgroundColor?.withOpacity(0.95) ??
                                Colors.white.withOpacity(0.95),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allFunds.length,
                        itemBuilder: (context, index) {
                          Fund fund = allFunds[index];
                          return TweenAnimationBuilder(
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 6.h),
                                    title: Text(
                                      fund.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color:
                                        AppColors.primaryColor ?? Colors.blue,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Return: ${fund.returnRate}, Risk: ${fund.risk}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColors.secondaryText ??
                                                Colors.grey,
                                          ),
                                        ),
                                        // Show allocation amount
                                        Text(
                                          'Allocation: ₹${((_fundPercentages[fund] ?? 0) / 100 * _monthlyAmount).toStringAsFixed(0)}/month',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 65.w,
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(3),
                                            ],
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                            controller: TextEditingController(
                                              text: (_fundPercentages[fund] ?? 0).toStringAsFixed(0),
                                            ),
                                            decoration: InputDecoration(
                                              labelText: '%',
                                              labelStyle:
                                              TextStyle(fontSize: 10.sp),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(8.r),
                                              ),
                                              contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 6.w,
                                                  vertical: 8.h),
                                              isDense: true,
                                              errorText:
                                              (_fundPercentages[fund] ?? 0.0) >
                                                  100
                                                  ? '≤100'
                                                  : null,
                                              errorStyle:
                                              TextStyle(fontSize: 8.sp),
                                            ),
                                            onChanged: (value) {
                                              double? parsedValue =
                                              double.tryParse(value);
                                              if (parsedValue != null) {
                                                if (parsedValue >= 0 &&
                                                    parsedValue <= 100) {
                                                  setState(() =>
                                                  _fundPercentages[fund] =
                                                      parsedValue);
                                                } else if (parsedValue > 100) {
                                                  setState(() =>
                                                  _fundPercentages[fund] =
                                                  100);
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: AppColors.error ?? Colors.red,
                                            size: 18.sp,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          onPressed: () => setState(() {
                                            _selectedAMCFunds.remove(fund);
                                            _selectedTopFunds.remove(fund);
                                            _fundPercentages.remove(fund);
                                            // Re-distribute after deletion
                                            if (_selectedAMCFunds.isNotEmpty || _selectedTopFunds.isNotEmpty) {
                                              _distributePercentagesEqually();
                                            }
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16.h),

              // Top-up Options
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surfaceColor?.withOpacity(0.9) ??
                          Colors.grey[100]!.withOpacity(0.9),
                      AppColors.backgroundColor?.withOpacity(0.95) ??
                          Colors.white.withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Enable Top-up SIP',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor ?? Colors.blue,
                        ),
                      ),
                      value: _topUpEnabled,
                      activeColor:
                      AppColors.primaryGold ?? const Color(0xFFDAA520),
                      onChanged: (value) => setState(() => _topUpEnabled = value),
                    ),
                    if (_topUpEnabled) ...[
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              visualDensity:
                              VisualDensity(horizontal: -4, vertical: -4),
                              title: Transform.translate(
                                offset: Offset(-8, 0),
                                child: Text('Value',
                                    style: TextStyle(fontSize: 12.sp)),
                              ),
                              value: 'value',
                              groupValue: _topUpType,
                              activeColor: AppColors.primaryGold ??
                                  const Color(0xFFDAA520),
                              onChanged: (value) =>
                                  setState(() => _topUpType = value!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              visualDensity:
                              VisualDensity(horizontal: -4, vertical: -4),
                              title: Transform.translate(
                                offset: Offset(-8, 0),
                                child: Text('Percentage',
                                    style: TextStyle(fontSize: 12.sp)),
                              ),
                              value: 'percentage',
                              groupValue: _topUpType,
                              activeColor: AppColors.primaryGold ??
                                  const Color(0xFFDAA520),
                              onChanged: (value) =>
                                  setState(() => _topUpType = value!),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                          LengthLimitingTextInputFormatter(8),
                        ],
                        style: TextStyle(fontSize: 13.sp),
                        decoration: InputDecoration(
                          labelText:
                          'Top-up ${_topUpType == 'value' ? 'Amount' : 'Percentage'}',
                          labelStyle: TextStyle(fontSize: 12.sp),
                          suffixText: _topUpType == 'percentage' ? '%' : '₹',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                          errorText:
                          _topUpValue < 0 ? 'Value must be ≥ 0' : null,
                        ),
                        onChanged: (value) {
                          double? parsedValue = double.tryParse(value);
                          if (parsedValue != null && parsedValue >= 0) {
                            setState(() => _topUpValue = parsedValue);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Start SIP Button and Selected Funds Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showSipConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith(
                              (states) =>
                          AppColors.primaryGold ?? const Color(0xFFDAA520),
                        ),
                      ),
                      child: Text(
                        'Start SIP Now',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  FloatingActionButton(
                    onPressed: _showSelectedFundsBottomSheet,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor ?? Colors.blue,
                            AppColors.primaryGold ?? const Color(0xFFDAA520),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${allFunds.length}/100',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}