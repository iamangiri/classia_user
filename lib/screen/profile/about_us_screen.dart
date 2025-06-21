import 'package:cached_network_image/cached_network_image.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';


class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'About Us',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: 'https://via.placeholder.com/300',
                  width: 150.w,
                  height: 150.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 150.w,
                    height: 150.h,
                    color: AppColors.border,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 150.w,
                    height: 150.h,
                    color: AppColors.border,
                    child: Icon(
                      Icons.image,
                      color: AppColors.disabled,
                      size: 48.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Welcome Section
            Text(
              'Welcome to Classia Capital',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'At Jockey Trading, we make trading accessible to everyone. Our platform is designed to be simple, intuitive, and user-friendly, empowering both novice and experienced investors to make informed decisions without needing advanced technical knowledge.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            // Mission Statement
            Text(
              'Our Mission & Vision',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6.r,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Our mission is to democratize wealth creation by providing a seamless trading experience. We envision a world where anyone can confidently invest in their future, supported by cutting-edge technology and exceptional customer service.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16.sp,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Market Section
            Text(
              'Our Market',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'We offer a curated selection of mutual funds, stocks, and other trading options tailored to diverse investment goals. Our market is designed to provide high-quality opportunities, backed by real-time data and insights, making it easy for you to build a robust portfolio.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            // Benefits Section
            Text(
              'Why Choose Jockey Trading?',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            _buildBenefitCard(
              icon: Icons.check_circle,
              text: 'Simple and intuitive platform design',
            ),
            SizedBox(height: 8.h),
            _buildBenefitCard(
              icon: Icons.trending_up,
              text: 'Wide range of mutual funds and trading options',
            ),
            SizedBox(height: 8.h),
            _buildBenefitCard(
              icon: Icons.school,
              text: 'No need for complex trading knowledge',
            ),
            SizedBox(height: 8.h),
            _buildBenefitCard(
              icon: Icons.support_agent,
              text: '24/7 customer support and real-time market data',
            ),
            SizedBox(height: 24.h),
            // Team Section
            Text(
              'Meet Our Team',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6.r,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Our team of financial experts, technologists, and customer support specialists is dedicated to your success. Led by industry veterans, we work tirelessly to innovate and provide the best trading experience.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16.sp,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Contact Section
            Text(
              'Get in Touch',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6.r,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email: support@jockeytrading.com',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Phone: +91 123-456-7890',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to contact screen or open email client
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // Call-to-Action
            Center(
              child: Text(
                'Join Jockey Trading today and start your trading journey with confidence!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to registration screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
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

  Widget _buildBenefitCard({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.success,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}