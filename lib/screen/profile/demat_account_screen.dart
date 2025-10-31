import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'open_dimet_account.dart';

class DematAccountScreen extends StatelessWidget {
  const DematAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const CommonAppBar(title: 'Demat Account'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),

            // Icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60.r),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  width: 2.w,
                ),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 60.sp,
                color: AppColors.primaryGold,
              ),
            ),

            SizedBox(height: 32.h),

            Text(
              'Open Your Demat Account',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            Text(
              'Invest & trade seamlessly in stocks, ETFs & mutual funds.',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(
                    icon: Icons.bolt,
                    title: 'Fast Demat Opening',
                    description: 'Paperless & quick account opening process',
                  ),
                  SizedBox(height: 12.h),
                  _buildFeatureItem(
                    icon: Icons.security,
                    title: 'Highly Secure',
                    description: 'Bank-grade encryption & secure login',
                  ),
                  SizedBox(height: 12.h),
                  _buildFeatureItem(
                    icon: Icons.trending_up,
                    title: 'Start Trading',
                    description: 'Buy & sell stocks instantly',
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // ✅ Open Demat Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OpenDematWebView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Open Demat Account',
                  style: TextStyle(
                    color: AppColors.cardBackground,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),


          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      {required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText)),
              SizedBox(height: 4.h),
              Text(description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
