import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';
import '../../widget/trading_card.dart';

class TradeSellTab extends StatelessWidget {
  final List<Map<String, dynamic>> amcList;
  final Function(Map<String, dynamic>) onSell;

  const TradeSellTab({
    Key? key,
    required this.amcList,
    required this.onSell,
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
              'No sellable trades available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check back later or adjust filters',
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
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(amc['logo'] ?? 'assets/images/default_logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Trade Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            amc['fundName'] ?? 'Unknown Fund',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            amc['name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Value: ₹${amc['value']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sell Button
                    ElevatedButton(
                      onPressed: () => onSell(amc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Sell',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}