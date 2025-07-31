import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../screen/calcutator/sip_calcutator.dart';
import '../../themes/app_colors.dart';
import 'dart:async';

import '../../screen/main/profile_screen.dart';
import '../../screen/profile/customer_support_screen.dart';

class TradeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(String) onFilterSelected; // Callback for filter selection
  final Function(int) onTabSelected; // Callback for tab selection
  final int currentTabIndex; // Current tab index (0 for Sell, 1 for Buy)

  const TradeAppBar({
    Key? key,
    required this.onFilterSelected,
    required this.onTabSelected,
    required this.currentTabIndex,
  }) : super(key: key);

  @override
  State<TradeAppBar> createState() => _TradeAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(90.h); // Height for slider and status
}

class _TradeAppBarState extends State<TradeAppBar> {
  DateTime currentTime = DateTime.now();
  Timer? _timer;
  bool _isProfileHovered = false;
  bool _isCalcHovered = false;
  bool _isSupportHovered = false;
  bool _isFilterHovered = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          currentTime = DateTime.now();
        });
      }
    });
  }

  bool _isMarketOpen() {
    final now = DateTime.now();
    final weekday = now.weekday;

    // Check if it's Saturday (6) or Sunday (7)
    if (weekday == 6 || weekday == 7) {
      return false;
    }

    // Market hours: 9:15 AM to 3:30 PM (Indian Stock Exchange)
    final marketOpen = DateTime(now.year, now.month, now.day, 9, 15);
    final marketClose = DateTime(now.year, now.month, now.day, 15, 30);

    return now.isAfter(marketOpen) && now.isBefore(marketClose);
  }

  String _formatTime(DateTime time) {
    String period = time.hour >= 12 ? 'PM' : 'AM';
    int hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    String minute = time.minute.toString().padLeft(2, '0');
    String second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second $period';
  }

  Widget _buildMarketStatusIndicator() {
    final isOpen = _isMarketOpen();
    return Text(
      '${isOpen ? 'LIVE' : 'CLOSED'} ${_formatTime(currentTime)}',
      style: TextStyle(
        color: AppColors.primaryGold,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'monospace',
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Color(0xFF121212)
          : AppColors.backgroundColor,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Trades',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  'Live',
                  'Last 7 Days',
                  '1 Month',
                  '3 Months',
                  '6 Months',
                  '1 Year',
                  '3 Years',
                  '5 Years',
                  'All',
                ].map((filter) {
                  return ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: false,
                    selectedColor: AppColors.success,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                    onSelected: (selected) {
                      widget.onFilterSelected(filter);
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      toolbarHeight: 90.h,

      backgroundColor: isDarkMode ? Color(0xFF121212) : AppColors.primaryColor,
      elevation: 2,
      flexibleSpace: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Slider and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Actions (Profile)
                  MouseRegion(
                    onEnter: (_) => setState(() => _isProfileHovered = true),
                    onExit: (_) => setState(() => _isProfileHovered = false),
                    child: IconButton(
                      icon: Icon(
                        Icons.person,
                        color: AppColors.primaryGold,
                        size: 24.sp,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      ),
                      tooltip: 'Profile',
                      padding: EdgeInsets.all(8.w),
                      splashRadius: 20.r,
                      color: _isProfileHovered
                          ? AppColors.primaryGold.withOpacity(0.8)
                          : AppColors.primaryGold,
                    ),
                  ),
                  // Tab Bar (Slider)
                  Container(
                    height: 36.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: widget.currentTabIndex == 1 ? 0 : 100.w,
                          child: Container(
                            width: 100.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.currentTabIndex == 1
                                    ? [
                                  AppColors.success ?? Colors.green,
                                  AppColors.success?.withOpacity(0.8) ?? Colors.green.withOpacity(0.8),
                                ]
                                    : [
                                  AppColors.error ?? Colors.red,
                                  AppColors.error?.withOpacity(0.8) ?? Colors.red.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => widget.onTabSelected(1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Buy',
                                      style: TextStyle(
                                        color: widget.currentTabIndex == 1
                                            ? AppColors.buttonText ?? Colors.white
                                            : AppColors.primaryGold ?? const Color(0xFFDAA520),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => widget.onTabSelected(0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Sell',
                                      style: TextStyle(
                                        color: widget.currentTabIndex == 0
                                            ? AppColors.buttonText ?? Colors.white
                                            : AppColors.primaryGold ?? const Color(0xFFDAA520),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
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
                  // Right Actions (Filter, Calculator, Support)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MouseRegion(
                        onEnter: (_) => setState(() => _isFilterHovered = true),
                        onExit: (_) => setState(() => _isFilterHovered = false),
                        child: IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: _isFilterHovered
                                ? AppColors.primaryGold.withOpacity(0.8)
                                : AppColors.primaryGold,
                            size: 24.sp,
                          ),
                          onPressed: () => _showFilterBottomSheet(context),
                          tooltip: 'Filter Trades',
                          padding: EdgeInsets.all(8.w),
                          splashRadius: 20.r,
                        ),
                      ),
                      MouseRegion(
                        onEnter: (_) => setState(() => _isCalcHovered = true),
                        onExit: (_) => setState(() => _isCalcHovered = false),
                        child: IconButton(
                          icon: Icon(
                            Icons.calculate,
                            color: AppColors.primaryGold,
                            size: 24.sp,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InvestmentCalculator()),
                          ),
                          tooltip: 'Calculator',
                          padding: EdgeInsets.all(8.w),
                          splashRadius: 20.r,
                          color: _isCalcHovered
                              ? AppColors.primaryGold.withOpacity(0.8)
                              : AppColors.primaryGold,
                        ),
                      ),

                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Market Status
              _buildMarketStatusIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}