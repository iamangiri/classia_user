import 'dart:convert';
import 'package:classia_amc/screen/sip/sip_goal_amc_fund.dart';
import 'package:classia_amc/screen/sip/sip_model.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/app_colors.dart';


class SipEditScreen extends StatefulWidget {
  final Sip sip;

  const SipEditScreen({super.key, required this.sip});

  @override
  _SipEditScreenState createState() => _SipEditScreenState();
}

class _SipEditScreenState extends State<SipEditScreen> with TickerProviderStateMixin {
  late String _frequency;
  late double _period;
  late double _monthlyAmount;
  late List<Fund> _selectedAMCFunds;
  late List<Fund> _selectedTopFunds;
  late Map<Fund, double> _fundPercentages;
  late bool _topUpEnabled;
  late String _topUpType;
  late double _topUpValue;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize with existing SIP data
    _frequency = widget.sip.frequency;
    _period = widget.sip.periodMonths.toDouble();
    _monthlyAmount = widget.sip.monthlyAmount;
    _selectedAMCFunds = [];
    _selectedTopFunds = widget.sip.funds.map((allocation) => allocation.fund).toList();
    _fundPercentages = {for (var allocation in widget.sip.funds) allocation.fund: allocation.percentage};
    _topUpEnabled = widget.sip.topUp?.enabled ?? false;
    _topUpType = widget.sip.topUp?.type ?? 'value';
    _topUpValue = widget.sip.topUp?.value ?? 0.0;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateSip(Sip sip) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sips = prefs.getStringList('sips') ?? [];
    int index = sips.indexWhere((json) => Sip.fromJson(jsonDecode(json)).id == sip.id);
    if (index != -1) {
      sips[index] = jsonEncode(sip.toJson());
      await prefs.setStringList('sips', sips);
    }
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
                'Confirm SIP Update',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Goal: ${widget.sip.goal.name}',
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
                'Period: ${(_period / 12).toStringAsFixed(1)} years',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.secondaryText ?? Colors.grey,
                ),
              ),
              Text(
                'Monthly Amount: ₹${_monthlyAmount.toStringAsFixed(0)}',
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
                      Goal newGoal = Goal(
                        id: widget.sip.goal.id,
                        name: widget.sip.goal.name,
                        icon: widget.sip.goal.icon,
                        target: _monthlyAmount * _period,
                        current: widget.sip.goal.current,
                        monthlyPayment: widget.sip.goal.monthlyPayment,
                        color: widget.sip.goal.color,
                        progress: widget.sip.goal.progress,
                        lottieAsset: widget.sip.goal.lottieAsset,
                      );
                      Sip updatedSip = Sip(
                        id: widget.sip.id,
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
                        status: widget.sip.status,
                      );
                      await _updateSip(updatedSip);
                      if (mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context); // Return to PortfolioTab
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
                      'Update SIP',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final allFunds = [..._selectedAMCFunds, ..._selectedTopFunds];
    return Scaffold(
      appBar: CommonAppBar(title:  'Edit ${widget.sip.goal.name} SIP'),
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
                          onSelected: (selected) => setState(() => _frequency = 'daily'),
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
                          onSelected: (selected) => setState(() => _frequency = 'monthly'),
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
                      min: 12,
                      max: 360,
                      divisions: 348,
                      label: '${(_period / 12).toStringAsFixed(1)} years',
                      activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      inactiveColor: AppColors.secondaryText?.withOpacity(0.3) ?? Colors.grey[300],
                      onChanged: (value) => setState(() => _period = value),
                    ),
                    Text(
                      '${(_period / 12).toStringAsFixed(1)} years',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.secondaryText ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Monthly Investment
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
                      'Monthly Investment Amount',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor ?? Colors.blue,
                      ),
                    ),
                    Slider(
                      value: _monthlyAmount,
                      min: 1000,
                      max: 100000,
                      divisions: 99,
                      label: '₹${_monthlyAmount.toStringAsFixed(0)}',
                      activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      inactiveColor: AppColors.secondaryText?.withOpacity(0.3) ?? Colors.grey[300],
                      onChanged: (value) => setState(() => _monthlyAmount = value),
                    ),
                    Text(
                      '₹${_monthlyAmount.toStringAsFixed(0)} / month',
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
                      SizedBox(height: 12.h),
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
              // Update SIP Button and Selected Funds Count
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
                        'Update SIP',
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