import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';
import 'jt_trade_card.dart';

class JtTradeExplore extends StatelessWidget {
  final List<Map<String, dynamic>> amcList;
  final Function(Map<String, dynamic>) onBuy;

  const JtTradeExplore({
    Key? key,
    required this.amcList,
    required this.onBuy,
  }) : super(key: key);

  // Helper to safely get value from map with default 0
  double _getSafeValue(Map<String, dynamic> amc) {
    var value = amc['value'];
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper to safely get string with default
  String _getSafeString(Map<String, dynamic> amc, String key, String defaultValue) {
    var value = amc[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF121212) : AppColors.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: amcList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Mutual fund data is not available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Data unavailable, please try again shortly',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        itemCount: amcList.length,
        itemBuilder: (context, index) {
          var amc = amcList[index];

          // Safely extract values with defaults
          final safeLogo = _getSafeString(amc, 'logo', '');
          final safeName = _getSafeString(amc, 'name', 'Unknown Fund');
          final safeFundName = _getSafeString(amc, 'fundName', 'N/A');
          final safeValue = _getSafeValue(amc);

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            child: JtTradeCard(
              logo: safeLogo,
              name: safeName,
              fundName: safeFundName,
              value: safeValue,
              fundData: amc, // Pass the entire AMC data
            ),
          );
        },
      ),
    );
  }
}