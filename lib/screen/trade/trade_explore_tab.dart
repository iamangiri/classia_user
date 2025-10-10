import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';
import '../../widget/trading_card.dart';


class TradeExploreTab extends StatelessWidget {
  final List<Map<String, dynamic>> amcList;
  final Function(Map<String, dynamic>) onBuy;

  const TradeExploreTab({
    Key? key,
    required this.amcList,
    required this.onBuy,
  }) : super(key: key);

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
              'Amc list not list',
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
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h), // Slightly increased padding
        itemCount: amcList.length,
        itemBuilder: (context, index) {
          var amc = amcList[index];
          return Container(
            margin: EdgeInsets.only(bottom: 6.h), // Slightly increased bottom margin
            child: Stack(
              children: [
                TradingCard(
                  id :amc['id'],
                  logo: amc['logo'],
                  name: amc['name'],
                  fundName: amc['fundName'],
                  value: amc['value'],
                  projection: amc['projection'],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}