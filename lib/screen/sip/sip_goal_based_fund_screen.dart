import 'dart:convert';
import 'package:classia_amc/screen/sip/sip_goal_amc_fund.dart';
import 'package:classia_amc/screen/sip/sip_model.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
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

class _SipGoalBasedFundScreenState extends State<SipGoalBasedFundScreen> with TickerProviderStateMixin {
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

  // Helper methods for dynamic text based on frequency
  String get _periodLabel => _frequency == 'daily' ? 'months' : 'years';
  String get _periodDisplayValue => _frequency == 'daily'
      ? '${(_period).toStringAsFixed(1)} months'
      : '${(_period / 12).toStringAsFixed(1)} years';

  String get _amountLabel => _frequency == 'daily' ? 'Daily Investment Amount' : 'Monthly Investment Amount';
  String get _amountDisplayValue => _frequency == 'daily'
      ? '₹${_getDisplayAmount().toStringAsFixed(0)} / day'
      : '₹${_monthlyAmount.toStringAsFixed(0)} / month';

  double _getDisplayAmount() => _frequency == 'daily' ? _monthlyAmount / 30 : _monthlyAmount;

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
      _monthlyAmount = 100 * 30; // 100 per day * 30 days = 3000 monthly equivalent
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveSip(Sip sip) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sips = prefs.getStringList('sips') ?? [];
    sips.add(jsonEncode(sip.toJson()));
    await prefs.setStringList('sips', sips);
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
              AppColors.surfaceColor?.withOpacity(0.95) ?? Colors.grey[100]!.withOpacity(0.95),
              AppColors.backgroundColor?.withOpacity(0.9) ?? Colors.white.withOpacity(0.9),
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
                color: AppColors.secondaryText?.withOpacity(0.3) ?? Colors.grey[400],
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
                                color: AppColors.primaryGold ?? const Color(0xFFDAA520),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
    double totalPercentage = allFunds.fold(0.0, (sum, fund) => sum + (_fundPercentages[fund] ?? 0.0));
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
                  AppColors.surfaceColor?.withOpacity(0.95) ?? Colors.grey[100]!.withOpacity(0.95),
                  AppColors.backgroundColor?.withOpacity(0.9) ?? Colors.white.withOpacity(0.9),
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
                Text(
                  'Goal: ${widget.goal.name}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
                Text(
                  'Frequency: ${_frequency[0].toUpperCase()}${_frequency.substring(1)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
                Text(
                  'Period: $_periodDisplayValue',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
                Text(
                  '${_frequency == 'daily' ? 'Daily' : 'Monthly'} Amount: ₹${_getDisplayAmount().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.secondaryText ?? Colors.grey,
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
                          // Call SipService to register SIP
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
                            // Save SIP locally
                            Goal newGoal = Goal(
                              id: widget.goal.toGoal().id,
                              name: widget.goal.name,
                              icon: widget.goal.icon ?? Icons.star,
                              target: _monthlyAmount * _period,
                              current: widget.goal.toGoal().current,
                              monthlyPayment: widget.goal.toGoal().monthlyPayment,
                              color: widget.goal.color,
                              progress: widget.goal.toGoal().progress,
                              lottieAsset: widget.goal.lottieAsset ?? 'assets/anim/sip_anim_1.json',
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

                            // Extract approval link
                            final approvalLink = responseData['data']['approvalLink'] as String?;
                            if (approvalLink != null && approvalLink.isNotEmpty) {
                              // Launch the approval link
                              final Uri uri = Uri.parse(approvalLink);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not launch UPI Autopay link')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('No approval link provided')),
                              );
                            }

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(responseData['message']),
                                action: approvalLink != null
                                    ? SnackBarAction(
                                  label: 'Open UPI Link',
                                  onPressed: () async {
                                    final Uri uri = Uri.parse(approvalLink);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Could not launch UPI Autopay link')),
                                      );
                                    }
                                  },
                                )
                                    : null,
                              ),
                            );

                            // Navigate back
                            if (mounted) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('SIP registration failed: ${responseData['message']}')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error registering SIP: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => AppColors.primaryGold ?? const Color(0xFFDAA520),
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
    ) ;
    }

  @override
  Widget build(BuildContext context) {
    final allFunds = [..._selectedAMCFunds, ..._selectedTopFunds];
    return Scaffold(
      appBar:  CommonAppBar(title: 'Invest in ${widget.goal.name}'),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SIP Frequency
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
                      AppColors.backgroundColor?.withOpacity(0.95) ?? Colors.white.withOpacity(0.95),
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
                        ChoiceChip(
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
                          selectedColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                          onSelected: (selected) => setState(() {
                            _frequency = 'daily';
                            // Reset amount to default daily equivalent
                            _monthlyAmount = 100 * 30; // 100/day = 3000/month
                            // Reset period to months for daily
                            _period = 12; // 12 months
                          }),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        ChoiceChip(
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
                          selectedColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                          onSelected: (selected) => setState(() {
                            _frequency = 'monthly';
                            // Reset amount to default monthly
                            _monthlyAmount = 5000;
                            // Reset period to months for conversion to years
                            _period = 12; // 1 year
                          }),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Investment Period',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor ?? Colors.blue,
                      ),
                    ),
                    Slider(
                      value: _period,
                      min: _frequency == 'daily' ? 1 : 12, // 1 month min for daily, 12 months (1 year) for monthly
                      max: _frequency == 'daily' ? 60 : 360, // 60 months max for daily, 360 months (30 years) for monthly
                      divisions: _frequency == 'daily' ? 59 : 348,
                      label: _periodDisplayValue,
                      activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      inactiveColor: AppColors.secondaryText?.withOpacity(0.3) ?? Colors.grey[300],
                      onChanged: (value) => setState(() => _period = value),
                    ),
                    Text(
                      _periodDisplayValue,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.secondaryText ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Monthly/Daily Investment
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
                      AppColors.backgroundColor?.withOpacity(0.95) ?? Colors.white.withOpacity(0.95),
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
                    Slider(
                      value: _frequency == 'daily' ? _monthlyAmount / 30 : _monthlyAmount,
                      min: _frequency == 'daily' ? 100 : 1000, // Min 100/day or 1000/month
                      max: _frequency == 'daily' ? 3333 : 100000, // Max ~3333/day (100k/month) or 100k/month
                      divisions: _frequency == 'daily' ? 32 : 99,
                      label: '₹${_getDisplayAmount().toStringAsFixed(0)}',
                      activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      inactiveColor: AppColors.secondaryText?.withOpacity(0.3) ?? Colors.grey[300],
                      onChanged: (value) => setState(() {
                        if (_frequency == 'daily') {
                          _monthlyAmount = value * 30; // Convert daily to monthly equivalent for storage
                        } else {
                          _monthlyAmount = value;
                        }
                      }),
                    ),
                    Text(
                      _amountDisplayValue,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.secondaryText ?? Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final selectedAMC = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AMCListScreen()),
                            );
                            if (selectedAMC != null) {
                              final selectedSchemes = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SchemeListScreen(amc: selectedAMC),
                                ),
                              );
                              if (selectedSchemes != null && selectedSchemes.isNotEmpty) {
                                setState(() {
                                  for (var scheme in selectedSchemes) {
                                    Fund newFund = scheme.toFund();
                                    if (!_selectedAMCFunds.any((f) => f.name == newFund.name) &&
                                        !_selectedTopFunds.any((f) => f.name == newFund.name)) {
                                      _selectedAMCFunds.add(newFund);
                                      _fundPercentages[newFund] = 0.0;
                                    }
                                  }
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                  (states) => AppColors.primaryColor ?? Colors.blue,
                            ),
                          ),
                          child: Text(
                            'Select AMC',
                            style: TextStyle(fontSize: 14.sp, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final selectedFunds = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TopFundsScreen()),
                            );
                            if (selectedFunds != null && selectedFunds.isNotEmpty) {
                              setState(() {
                                for (var fund in selectedFunds) {
                                  if (!_selectedAMCFunds.any((f) => f.name == fund.name) &&
                                      !_selectedTopFunds.any((f) => f.name == fund.name)) {
                                    _selectedTopFunds.add(fund);
                                    _fundPercentages[fund] = 0.0;
                                  }
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                  (states) => AppColors.primaryGold ?? const Color(0xFFDAA520),
                            ),
                          ),
                          child: Text(
                            'Select Top Funds',
                            style: TextStyle(fontSize: 14.sp, color: Colors.white),
                          ),
                        ),
                      ],
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
                    Text(
                      'Selected Funds',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor ?? Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
                            AppColors.backgroundColor?.withOpacity(0.95) ?? Colors.white.withOpacity(0.95),
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                    title: Text(
                                      fund.name,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor ?? Colors.blue,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Return: ${fund.returnRate}, Risk: ${fund.risk}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.secondaryText ?? Colors.grey,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 80.w,
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: '%',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                              errorText: (_fundPercentages[fund] ?? 0.0) > 100 ? '≤ 100' : null,
                                            ),
                                            onChanged: (value) {
                                              double? parsedValue = double.tryParse(value);
                                              if (parsedValue != null && parsedValue >= 0 && parsedValue <= 100) {
                                                setState(() => _fundPercentages[fund] = parsedValue);
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: AppColors.error ?? Colors.red,
                                            size: 20.sp,
                                          ),
                                          onPressed: () => setState(() {
                                            _selectedAMCFunds.remove(fund);
                                            _selectedTopFunds.remove(fund);
                                            _fundPercentages.remove(fund);
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
                      AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
                      AppColors.backgroundColor?.withOpacity(0.95) ?? Colors.white.withOpacity(0.95),
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
                      title: Text(
                        'Enable Top-up SIP',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor ?? Colors.blue,
                        ),
                      ),
                      value: _topUpEnabled,
                      activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      onChanged: (value) => setState(() => _topUpEnabled = value),
                    ),
                    if (_topUpEnabled) ...[

                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              contentPadding: EdgeInsets.zero, // Removes internal padding
                              dense: true, // Makes the tile more compact
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4), // Reduces spacing further
                              title: Transform.translate(
                                offset: Offset(-8, 0), // Move text slightly left to be closer to radio
                                child: Text('Value', style: TextStyle(fontSize: 13.sp)),
                              ),
                              value: 'value',
                              groupValue: _topUpType,
                              activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                              onChanged: (value) => setState(() => _topUpType = value!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              title: Transform.translate(
                                offset: Offset(-8, 0),
                                child: Text('Percentage', style: TextStyle(fontSize: 13.sp)),
                              ),
                              value: 'percentage',
                              groupValue: _topUpType,
                              activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                              onChanged: (value) => setState(() => _topUpType = value!),
                            ),
                          ),
                        ],
                      ),

                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Top-up ${_topUpType == 'value' ? 'Amount' : 'Percentage'}',
                          suffixText: _topUpType == 'percentage' ? '%' : '₹',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                          errorText: _topUpValue < 0 ? 'Value must be ≥ 0' : null,
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
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => AppColors.primaryGold ?? const Color(0xFFDAA520),
                        ),
                      ),
                      child: Text(
                        'Start SIP Now',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  FloatingActionButton(
                    onPressed: _showSelectedFundsBottomSheet,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    );
  }
}