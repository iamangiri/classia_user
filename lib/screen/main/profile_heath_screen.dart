import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import '../../widget/common_app_bar.dart';

class ProfileHealthScreen extends StatelessWidget {
  const ProfileHealthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title:
          'Profile Health',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHealthOverview(context),
            SizedBox(height: 24.h),
            _buildInvestmentBreakdown(context),
            SizedBox(height: 24.h),
            _buildChartPlaceholder(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHealthOverview(BuildContext context) {
    const double healthProgress = 0.75; // 75% completion
    const String status = 'Good';
    const String totalInvestment = '₹50,00,000';
    const int numberOfFunds = 5;
    const String riskLevel = 'Moderate';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Health',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100.r,
                    height: 100.r,
                    child: CircularProgressIndicator(
                      value: healthProgress,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                      backgroundColor: AppColors.border,
                    ),
                  ),
                  Text(
                    '${(healthProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $status',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Complete your KYC and add bank details to improve your profile health.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricCard('Total Investment', totalInvestment, Icons.account_balance_wallet),
              SizedBox(width: 12.w),
              _buildMetricCard('Funds', numberOfFunds.toString(), Icons.pie_chart),
              SizedBox(width: 12.w),
              _buildMetricCard('Risk Level', riskLevel, Icons.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryGold, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentBreakdown(BuildContext context) {
    final List<Map<String, dynamic>> fundTypes = [
      {
        'name': 'Insurance',
        'amount': '₹10,00,000',
        'percentage': 20.0,
        'color': AppColors.primaryGold,
      },
      {
        'name': 'Live',
        'amount': '₹15,00,000',
        'percentage': 30.0,
        'color': AppColors.accent,
      },
      {
        'name': 'Equity',
        'amount': '₹20,00,000',
        'percentage': 40.0,
        'color': AppColors.success,
      },
      {
        'name': 'Debt',
        'amount': '₹4,00,000',
        'percentage': 8.0,
        'color': AppColors.secondaryText,
      },
      {
        'name': 'Cash',
        'amount': '₹1,00,000',
        'percentage': 2.0,
        'color': AppColors.border,
      },
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investment Breakdown',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          ...fundTypes.map((fund) => _buildFundItem(context, fund)).toList(),
        ],
      ),
    );
  }

  Widget _buildFundItem(BuildContext context, Map<String, dynamic> fund) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Details for ${fund['name']} coming soon!',
              style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(
              Icons.pie_chart,
              color: fund['color'] as Color,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fund['name'] as String,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    fund['amount'] as String,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${fund['percentage']}%',
                  style: TextStyle(
                    color: fund['color'] as Color,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: 100.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.r),
                    color: AppColors.border,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (fund['percentage'] as double) / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: fund['color'] as Color,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investment Distribution',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 150.h,
            color: AppColors.border.withOpacity(0.2),
            child: Center(
              child: Text(
                'Pie Chart Placeholder',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Note: Visual representation of your investment allocation.',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}