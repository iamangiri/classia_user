import 'package:classia_amc/screen/sip/sip_model.dart';
import 'package:classia_amc/screen/sip/sip_portfolio_edit_screen.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../themes/app_colors.dart';


class SipDetailsScreen extends StatefulWidget {
  final Sip sip;

  const SipDetailsScreen({super.key, required this.sip});

  @override
  _SipDetailsScreenState createState() => _SipDetailsScreenState();
}

class _SipDetailsScreenState extends State<SipDetailsScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(duration: const Duration(seconds: 3), vsync: this)..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _updateSipStatus(String newStatus) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/anim/sip_anim_confirm.json', height: 80.h, width: 80.w),
              SizedBox(height: 16.h),
              Text(
                'Confirm $newStatus',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primaryColor ?? Colors.blue),
              ),
              SizedBox(height: 8.h),
              Text(
                'Are you sure you want to $newStatus this SIP?',
                style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText ?? Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text('Confirm', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      setState(() {
        widget.sip.status = newStatus;
      });
      await _updateSip(widget.sip);
      if (mounted) {
        Navigator.pop(context); // Return to PortfolioTab to refresh
      }
    }
  }

  Future<void> _restartSip() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/anim/sip_anim_confirm.json', height: 80.h, width: 80.w),
              SizedBox(height: 16.h),
              Text(
                'Confirm Restart',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primaryColor ?? Colors.blue),
              ),
              SizedBox(height: 8.h),
              Text(
                'Restarting will create a new SIP with the same details but reset progress. Continue?',
                style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText ?? Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text('Confirm', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      List<String> sips = prefs.getStringList('sips') ?? [];
      Sip newSip = Sip(
        id: DateTime.now().millisecondsSinceEpoch,
        goal: Goal(
          id: widget.sip.goal.id,
          name: widget.sip.goal.name,
          icon: widget.sip.goal.icon,
          target: widget.sip.goal.target,
          current: 0.0, // Reset progress
          monthlyPayment: widget.sip.goal.monthlyPayment,
          color: widget.sip.goal.color,
          progress: 0.0,
          lottieAsset: widget.sip.goal.lottieAsset,
        ),
        frequency: widget.sip.frequency,
        periodMonths: widget.sip.periodMonths,
        monthlyAmount: widget.sip.monthlyAmount,
        funds: widget.sip.funds,
        topUp: widget.sip.topUp,
        status: 'active',
      );
      sips.add(jsonEncode(newSip.toJson()));
      await prefs.setStringList('sips', sips);
      if (mounted) {
        Navigator.pop(context); // Return to PortfolioTab to refresh
      }
    }
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

  String formatCurrency(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.sip.goal.current / widget.sip.goal.target;
    double cardWidth = MediaQuery.of(context).size.width - 32.w;

    return Scaffold(
      appBar: CommonAppBar(title: widget.sip.goal.name),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Overview
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: widget.sip.goal.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(widget.sip.goal.icon, color: widget.sip.goal.color, size: 24.sp),
                            ),
                            SizedBox(width: 16.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.sip.goal.name,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor ?? Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Status: ${widget.sip.status[0].toUpperCase()}${widget.sip.status.substring(1)}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: widget.sip.status == 'active'
                                        ? AppColors.success ?? Colors.green
                                        : widget.sip.status == 'paused'
                                        ? AppColors.warning ?? Colors.orange
                                        : AppColors.error ?? Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 60.w,
                          height: 60.h,
                          child: Lottie.asset(widget.sip.goal.lottieAsset, fit: BoxFit.contain),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Progress: ${(progress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryColor ?? Colors.blueAccent),
                    ),
                    SizedBox(height: 8.h),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: cardWidth,
                          height: 8.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            color: Colors.grey[300],
                          ),
                        ),
                        AnimatedBuilder(
                          animation: Tween<double>(begin: 0, end: progress).animate(
                            CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
                          ),
                          builder: (context, child) {
                            double progressValue = progress.clamp(0.0, 1.0);
                            return Container(
                              width: progressValue * cardWidth,
                              height: 8.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryGold ?? const Color(0xFFDAA520),
                                    Colors.amber[700]!,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: Tween<double>(begin: 0, end: progress).animate(
                            CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
                          ),
                          builder: (context, child) {
                            double progressValue = progress.clamp(0.0, 1.0);
                            return Positioned(
                              left: (progressValue * cardWidth) - 20.w,
                              top: -30.h,
                              child: SizedBox(
                                height: 70.h,
                                width: 90.w,
                                child: Image.asset('assets/images/jt1.gif', fit: BoxFit.contain),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Value',
                              style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText ?? Colors.grey),
                            ),
                            Text(
                              formatCurrency(widget.sip.goal.current),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success ?? Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Target',
                              style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText ?? Colors.grey),
                            ),
                            Text(
                              formatCurrency(widget.sip.goal.target),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor ?? Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              // SIP Details
              Text(
                'SIP Details',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primaryColor ?? Colors.blue),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
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
                    _buildDetailRow('Monthly Amount', '₹${widget.sip.monthlyAmount.toStringAsFixed(0)}'),
                    _buildDetailRow('Frequency', widget.sip.frequency[0].toUpperCase() + widget.sip.frequency.substring(1)),
                    _buildDetailRow('Period', '${(widget.sip.periodMonths / 12).toStringAsFixed(1)} years'),
                    if (widget.sip.topUp != null && widget.sip.topUp!.enabled)
                      _buildDetailRow(
                        'Top-up',
                        '${widget.sip.topUp!.value} ${widget.sip.topUp!.type == 'percentage' ? '%' : '₹'}',
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Fund Allocations
              Text(
                'Fund Allocations',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primaryColor ?? Colors.blue),
              ),
              SizedBox(height: 8.h),
              ...widget.sip.funds.map((allocation) => Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: allocation.fund.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allocation.fund.name,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Risk: ${allocation.fund.risk}',
                          style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText ?? Colors.grey),
                        ),
                        Text(
                          'Return: ${allocation.fund.returnRate}',
                          style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText ?? Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      '${allocation.percentage}%',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.primaryColor ?? Colors.blue),
                    ),
                  ],
                ),
              )),
              SizedBox(height: 24.h),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.sip.status != 'paused')
                    _buildActionButton(
                      icon: Icons.pause,
                      label: 'Pause',
                      color: AppColors.warning ?? Colors.orange,
                      onPressed: () => _updateSipStatus('paused'),
                    ),
                  if (widget.sip.status == 'paused')
                    _buildActionButton(
                      icon: Icons.play_arrow,
                      label: 'Resume',
                      color: AppColors.success ?? Colors.green,
                      onPressed: () => _updateSipStatus('active'),
                    ),
                  if (widget.sip.status != 'stopped')
                    _buildActionButton(
                      icon: Icons.stop,
                      label: 'Stop',
                      color: AppColors.error ?? Colors.red,
                      onPressed: () => _updateSipStatus('stopped'),
                    ),
                  if (widget.sip.status == 'stopped')
                    _buildActionButton(
                      icon: Icons.restart_alt,
                      label: 'Restart',
                      color: AppColors.primaryColor ?? Colors.blue,
                      onPressed: _restartSip,
                    ),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Edit',
                    color: AppColors.primaryColor ?? Colors.blue,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SipEditScreen(sip: widget.sip)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText ?? Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primaryColor ?? Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(onPressed == null ? 0.3 : 1.0),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}