import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';

class DematAccountScreen extends StatelessWidget {
  const DematAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Demat Account',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),

            // Icon Container
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
                Icons.account_balance_wallet,
                size: 60.sp,
                color: AppColors.primaryGold,
              ),
            ),

            SizedBox(height: 32.h),

            // Main Title
            Text(
              'Demat Account Services',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            // Subtitle
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            // Information Card
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
                  // Partnership Info
                  Row(
                    children: [
                      Icon(
                        Icons.handshake,
                        color: AppColors.primaryGold,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Partnership with Leading Brokers',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Main Description
                  Text(
                    'We are establishing partnerships with top-tier brokers to provide you with seamless demat account services.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Features Section
                  _buildFeatureItem(
                    icon: Icons.trending_up,
                    title: 'Open Demat Account',
                    description: 'Quick and easy demat account opening process',
                  ),

                  SizedBox(height: 12.h),

                  _buildFeatureItem(
                    icon: Icons.track_changes,
                    title: 'Track Your Portfolio',
                    description: 'Real-time tracking of your investment portfolio',
                  ),

                  SizedBox(height: 12.h),

                  _buildFeatureItem(
                    icon: Icons.security,
                    title: 'Secure Trading',
                    description: 'Safe and secure trading environment',
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Coming Soon Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold.withOpacity(0.1),
                    AppColors.primaryGold.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.primaryGold,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Feature launching soon',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Notification Button
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showNotificationDialog(context);
                },
                icon: Icon(
                  Icons.notifications_active,
                  color: AppColors.cardBackground,
                  size: 20.sp,
                ),
                label: Text(
                  'Notify Me When Available',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cardBackground,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryGold,
            size: 16.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: AppColors.primaryGold,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Get Notified',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'We\'ll notify you as soon as demat account services become available through our broker partnerships.',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessSnackBar(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Notify Me',
                style: TextStyle(
                  color: AppColors.cardBackground,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'You\'ll be notified when available!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        margin: EdgeInsets.all(16.w),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}