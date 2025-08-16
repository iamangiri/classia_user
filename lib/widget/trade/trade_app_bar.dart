import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../screen/calcutator/sip_calcutator.dart';
import '../../screen/main/profile_screen.dart';
import '../../themes/app_colors.dart';

class TradeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(String) onFilterSelected;
  final Function(int) onTabSelected;
  final int currentTabIndex;
  final String? selectedFilter;

  const TradeAppBar({
    Key? key,
    required this.onFilterSelected,
    required this.onTabSelected,
    required this.currentTabIndex,
    this.selectedFilter,
  }) : super(key: key);

  @override
  State<TradeAppBar> createState() => _TradeAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(90.h);
}

class _TradeAppBarState extends State<TradeAppBar> with TickerProviderStateMixin {
  bool _isProfileHovered = false;
  bool _isCalcHovered = false;
  bool _isFilterHovered = false;
  String? _selectedFilter;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterScaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter ?? 'Live';
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _filterScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surfaceColor?.withOpacity(0.95) ?? Colors.grey[100]!.withOpacity(0.95),
                    AppColors.backgroundColor?.withOpacity(0.98) ?? Colors.white.withOpacity(0.98),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24.r,
                    offset: Offset(0, -8.h),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primaryGold?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                                    AppColors.primaryColor?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.tune,
                                color: AppColors.primaryColor ?? Colors.blue,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Filter Trades',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor ?? Colors.blue,
                                  ),
                                ),
                                Text(
                                  'Select your preferred time range',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.grey[600],
                            size: 24.sp,
                          ),
                          splashRadius: 20.r,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                        ),
                        itemCount: _getFilterOptions().length,
                        itemBuilder: (context, index) {
                          final filter = _getFilterOptions()[index];
                          final isSelected = _selectedFilter == filter['value'];

                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: isSelected ? 65.h : 55.h,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                colors: [
                                  AppColors.primaryColor?.withOpacity(0.9) ?? Colors.blue.withOpacity(0.9),
                                  AppColors.primaryGold?.withOpacity(0.8) ?? Colors.amber.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : LinearGradient(
                                colors: [
                                  Colors.grey[100]!.withOpacity(0.8),
                                  Colors.grey[50]!.withOpacity(0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryGold?.withOpacity(0.6) ?? Colors.amber.withOpacity(0.6)
                                    : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: AppColors.primaryColor?.withOpacity(0.3) ?? Colors.blue.withOpacity(0.3),
                                  blurRadius: 12.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ]
                                  : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.r),
                                onTap: () {
                                  setModalState(() {
                                    _selectedFilter = filter['value'];
                                  });
                                  HapticFeedback.selectionClick();
                                  Future.delayed(Duration(milliseconds: 200), () {
                                    widget.onFilterSelected(filter['value']);
                                    Navigator.pop(context);
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36.w,
                                        height: 36.h,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.2)
                                              : AppColors.primaryColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Icon(
                                          filter['icon'],
                                          color: isSelected ? Colors.white : AppColors.primaryColor ?? Colors.blue,
                                          size: 18.sp,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              filter['label'],
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.grey[800],
                                                fontSize: 15.sp,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (filter['subtitle'] != null)
                                              Text(
                                                filter['subtitle'],
                                                style: TextStyle(
                                                  color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 24.w,
                                          height: 24.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: AppColors.primaryColor ?? Colors.blue,
                                            size: 16.sp,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(24.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onFilterSelected(_selectedFilter!);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor ?? Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
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

  List<Map<String, dynamic>> _getFilterOptions() {
    return [
      {'label': 'Live', 'value': 'Live', 'icon': Icons.radio_button_checked, 'subtitle': 'Daily'},
      {'label': 'Last 7 Days', 'value': 'Last 7 Days', 'icon': Icons.calendar_today, 'subtitle': 'Weekly'},
      {'label': '1 Month', 'value': '1 Month', 'icon': Icons.date_range, 'subtitle': 'Monthly'},
      {'label': '3 Months', 'value': '3 Months', 'icon': Icons.view_timeline, 'subtitle': 'Quarterly'},
      {'label': '6 Months', 'value': '6 Months', 'icon': Icons.timeline, 'subtitle': 'Halfyearly'},
      {'label': '1 Year', 'value': '1 Year', 'icon': Icons.trending_up, 'subtitle': 'Yearly'},
      {'label': '3 Years', 'value': '3 Years', 'icon': Icons.show_chart, 'subtitle': 'Longterm'},
      {'label': '5 Years', 'value': '5 Years', 'icon': Icons.analytics, 'subtitle': 'Extended'},
      {'label': 'All Time', 'value': 'All', 'icon': Icons.all_inclusive, 'subtitle': 'Alltime'},
    ];
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MouseRegion(
                    onEnter: (_) => setState(() => _isCalcHovered = true),
                    onExit: (_) => setState(() => _isCalcHovered = false),
                    child: IconButton(
                      icon: Icon(
                        Icons.calculate,
                        color: _isCalcHovered
                            ? AppColors.primaryGold.withOpacity(0.8)
                            : AppColors.primaryGold,
                        size: 24.sp,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InvestmentCalculator()),
                      ),
                      tooltip: 'Calculator',
                      padding: EdgeInsets.all(8.w),
                      splashRadius: 20.r,
                    ),
                  ),
                  ScaleTransition(
                    scale: _filterScaleAnimation,
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() => _isFilterHovered = true);
                        _filterAnimationController.forward();
                      },
                      onExit: (_) {
                        setState(() => _isFilterHovered = false);
                        _filterAnimationController.reverse();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: _isFilterHovered
                              ? LinearGradient(
                            colors: [
                              AppColors.primaryGold?.withOpacity(0.2) ?? Colors.amber.withOpacity(0.2),
                              AppColors.primaryGold?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
                            ],
                          )
                              : null,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: IconButton(
                          icon: Stack(
                            children: [
                              Icon(
                                Icons.tune,
                                color: _isFilterHovered
                                    ? AppColors.primaryGold
                                    : AppColors.primaryGold?.withOpacity(0.9),
                                size: 24.sp,
                              ),
                              if (_selectedFilter != null && _selectedFilter != 'Live')
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8.w,
                                    height: 8.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.success ?? Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: () => _showFilterBottomSheet(context),
                          tooltip: 'Filter Trades',
                          padding: EdgeInsets.all(8.w),
                          splashRadius: 20.r,
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