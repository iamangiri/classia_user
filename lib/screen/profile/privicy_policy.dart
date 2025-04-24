import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

import 'customer_support_screen.dart';


class PrivacyPolicyScreen extends StatelessWidget {
  final List<Map<String, String>> policySections = [
    {
      'title': 'Introduction',
      'content':
      'At Jockey Trading, your privacy is our top priority. We are committed to safeguarding your personal information and ensuring transparency about how we collect, use, and store your data. This Privacy Policy outlines our practices and your rights regarding your data.',
    },
    {
      'title': 'Data Collection',
      'content':
      'We collect information you provide directly, such as your name, email, phone number, and financial details, when you register, use our services, or contact our support team. We may also collect usage data, like app interactions, to improve our platform.',
    },
    {
      'title': 'Data Usage',
      'content':
      'Your data is used to enhance your trading experience, process transactions, and deliver personalized services. We also use it to send account updates, promotional offers, and critical security notifications to keep you informed.',
    },
    {
      'title': 'Data Security',
      'content':
      'We employ industry-standard encryption and security measures to protect your data from unauthorized access, loss, or misuse. Our systems are regularly audited to ensure the highest level of security for your information.',
    },
    {
      'title': 'Third Party Services',
      'content':
      'We may share your data with trusted third-party providers who assist with platform operations, such as payment processing or analytics, under strict confidentiality agreements. These partners are prohibited from using your data independently.',
    },
    {
      'title': 'Cookies',
      'content':
      'Our platform uses cookies to enhance your browsing experience, analyze usage, and deliver personalized content. You can manage cookie preferences in your app settings or browser, though disabling cookies may affect functionality.',
    },
    {
      'title': 'Your Rights',
      'content':
      'You have the right to access, update, or delete your personal data. You may also request restrictions on data processing or object to certain uses. Contact our support team to exercise these rights.',
    },
    {
      'title': 'Policy Updates',
      'content':
      'We may update this Privacy Policy periodically to reflect changes in our practices or legal requirements. We will notify you of significant updates via email or in-app notifications, with the updated policy available on this page.',
    },
    {
      'title': 'Contact Information',
      'content':
      'If you have questions or concerns about our Privacy Policy, please reach out to us at privacy@jockeytrading.com or through our Customer Support portal.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Privacy Policy',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Last Updated: March 15, 2025',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(height: 24.h),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: policySections.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final section = policySections[index];
                return Container(
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
                  child: ExpansionTile(
                    title: Text(
                      section['title']!,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    iconColor: AppColors.primaryGold,
                    collapsedIconColor: AppColors.secondaryText,
                    childrenPadding: EdgeInsets.all(16.w),
                    children: [
                      Text(
                        section['content']!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerSupportScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Contact Support',
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
}