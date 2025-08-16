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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Logo
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryGold.withOpacity(0.1),
                    AppColors.cardBackground,
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    blurRadius: 12.r,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Logo with enhanced styling
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo/logo.jpg',
                      width: 160.w,
                      height: 80.h,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 160.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.business,
                            color: AppColors.primaryGold,
                            size: 48.sp,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'MFD Classia Capital Private Limited',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your Trusted Investment Partner',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Welcome Section
            _buildSectionCard(
              title: 'Welcome to Classia Capital',
              content: 'At Classia Capital, we specialize in making wealth creation accessible to everyone through our comprehensive Asset Management Company (AMC) platform. Our innovative approach combines cutting-edge technology with deep financial expertise to provide you with seamless investment opportunities in mutual funds and financial markets.',
              icon: Icons.handshake_outlined,
            ),

            SizedBox(height: 20.h),

            // Mission & Vision Section
            _buildSectionCard(
              title: 'Our Mission & Vision',
              content: 'Our mission is to democratize wealth creation by providing world-class investment solutions that are simple, transparent, and accessible to all investors. We envision a future where every individual has the tools and knowledge to build long-term wealth through smart investment strategies backed by professional fund management.',
              icon: Icons.visibility_outlined,
              isHighlighted: true,
            ),

            SizedBox(height: 20.h),

            // Services Section
            _buildSectionCard(
              title: 'Our Investment Solutions',
              content: 'We offer a comprehensive range of mutual fund schemes designed to meet diverse investment objectives. From equity funds for growth-oriented investors to debt funds for conservative investors, our portfolio includes carefully curated investment options managed by experienced fund managers with proven track records.',
              icon: Icons.account_balance_outlined,
            ),

            SizedBox(height: 20.h),

            // Why Choose Us Section
            Text(
              'Why Choose Classia Capital?',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            _buildBenefitCard(
              icon: Icons.security_outlined,
              title: 'SEBI Registered & Compliant',
              description: 'Fully regulated Asset Management Company ensuring your investments are safe and secure',
            ),
            SizedBox(height: 12.h),

            _buildBenefitCard(
              icon: Icons.trending_up_outlined,
              title: 'Professional Fund Management',
              description: 'Expert fund managers with years of experience in Indian capital markets',
            ),
            SizedBox(height: 12.h),

            _buildBenefitCard(
              icon: Icons.mobile_friendly_outlined,
              title: 'User-Friendly Platform',
              description: 'Intuitive mobile app and web platform for seamless investment experience',
            ),
            SizedBox(height: 12.h),

            _buildBenefitCard(
              icon: Icons.analytics_outlined,
              title: 'Real-time Portfolio Tracking',
              description: 'Monitor your investments with detailed analytics and performance reports',
            ),
            SizedBox(height: 12.h),

            _buildBenefitCard(
              icon: Icons.support_agent_outlined,
              title: 'Dedicated Customer Support',
              description: 'Professional support team to assist you with all your investment queries',
            ),

            SizedBox(height: 24.h),

            // Team Section
            _buildSectionCard(
              title: 'Our Expert Team',
              content: 'Our team comprises seasoned professionals from the financial services industry, including certified fund managers, risk management experts, and technology specialists. With collective experience of over decades in Indian capital markets, we are committed to delivering superior investment outcomes for our investors.',
              icon: Icons.groups_outlined,
            ),

            SizedBox(height: 24.h),

            // Regulatory Information
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGold.withOpacity(0.1),
                    AppColors.primaryGold.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: AppColors.primaryGold,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Regulatory Information',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Classia Capital Private Limited is registered with the Securities and Exchange Board of India (SEBI) as an Asset Management Company. All our schemes are designed to comply with SEBI regulations and guidelines, ensuring complete transparency and investor protection.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 15.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Contact Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10.r,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_phone_outlined,
                        color: AppColors.primaryGold,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Get in Touch',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  _buildContactItem(
                    Icons.business_outlined,
                    'Address',
                    '58, 2nd Cross Rd, Chowdiah Block, Mannarayanapalya\nChamundi Nagar, RT Nagar, Bengaluru, Karnataka 560032',
                  ),
                  SizedBox(height: 12.h),

                  _buildContactItem(
                    Icons.email_outlined,
                    'Email',
                    'support@classiacapital.com',
                  ),
                  SizedBox(height: 12.h),

                  _buildContactItem(
                    Icons.phone_outlined,
                    'Phone',
                    '+91 98869 88679',
                  ),

                  SizedBox(height: 20.h),


                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Call-to-Action
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryGold.withOpacity(0.15),
                    AppColors.primaryGold.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Start Your Investment Journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Join thousands of investors who trust Classia Capital for their wealth creation journey. Start investing today with our professionally managed mutual fund schemes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 16.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),

                ],
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    bool isHighlighted = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primaryGold.withOpacity(0.05)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: isHighlighted
            ? Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
          width: 1,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGold,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            content,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16.sp,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: AppColors.success,
              size: 20.sp,
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
                    color: AppColors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: AppColors.primaryGold,
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
                content,
                style: TextStyle(
                  fontSize: 13.sp,
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
}