import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

import 'customer_support_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final List<Map<String, dynamic>> policySections = [
    {
      'title': 'Introduction',
      'icon': Icons.info_outline,
      'content':
      'Classia Capital Private Limited ("we," "our," or "us") operates the Classia AMC mobile application and website (the "Service"). This Privacy Policy informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.',
    },
    {
      'title': 'Information We Collect',
      'icon': Icons.data_usage_outlined,
      'content':
      'We collect personal information including your name, email, phone number, date of birth, PAN and Aadhaar details for KYC compliance, bank account details, investment preferences, and financial information. We also automatically collect device information, IP address, app usage statistics, location data (with permission), and use cookies for enhanced user experience.',
    },
    {
      'title': 'How We Use Your Information',
      'icon': Icons.settings_outlined,
      'content':
      'Your information is used for providing investment services, processing transactions, managing your portfolio, KYC verification, regulatory compliance, customer support, service improvements, marketing activities (with consent), and fraud prevention.',
    },
    {
      'title': 'Information Sharing and Disclosure',
      'icon': Icons.share_outlined,
      'content':
      'We may share your information with Asset Management Companies (AMCs), Registrar and Transfer Agents (RTAs), payment processors, banks, KYC verification agencies, regulatory authorities (SEBI, RBI), service providers, business partners, and legal authorities when required by law.',
    },
    {
      'title': 'Data Security',
      'icon': Icons.security_outlined,
      'content':
      'We implement SSL encryption for data transmission, secure servers and databases, regular security audits, access controls and authentication, and employee training on data protection to safeguard your personal information from unauthorized access, loss, or misuse.',
    },
    {
      'title': 'Data Retention',
      'icon': Icons.schedule_outlined,
      'content':
      'We retain your personal information for as long as necessary to provide our services and comply with legal obligations. Investment records are maintained as per SEBI guidelines (typically 8 years).',
    },
    {
      'title': 'Your Rights',
      'icon': Icons.account_circle_outlined,
      'content':
      'You have the right to access your personal information, correct inaccurate data, request deletion of your data (subject to legal requirements), withdraw consent for marketing communications, data portability, and file complaints with data protection authorities.',
    },
    {
      'title': 'Cookies and Tracking',
      'icon': Icons.cookie_outlined,
      'content':
      'Our app and website use cookies and similar technologies to enhance user experience, analyze usage, and provide personalized content. You can manage cookie preferences through your device settings.',
    },
    {
      'title': 'Third-Party Services',
      'icon': Icons.link_outlined,
      'content':
      'Our app may contain links to third-party services. We are not responsible for the privacy practices of these external services. Please review their privacy policies before providing any information.',
    },
    {
      'title': 'Children\'s Privacy',
      'icon': Icons.child_care_outlined,
      'content':
      'Our services are not intended for individuals under 18 years of age. We do not knowingly collect personal information from children under 18.',
    },
    {
      'title': 'International Data Transfers',
      'icon': Icons.public_outlined,
      'content':
      'Your information may be transferred to and processed in countries other than India. We ensure appropriate safeguards are in place for such transfers.',
    },
    {
      'title': 'Regulatory Compliance',
      'icon': Icons.gavel_outlined,
      'content':
      'This Privacy Policy complies with Information Technology Act, 2000 and Rules, SEBI (Investment Advisers) Regulations, 2013, RBI guidelines on data protection, and Google Play Store and Apple App Store policies.',
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
                  color: AppColors.primaryGold.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.primaryGold,
                        size: 28.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Classia Capital Private Limited',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16.sp,
                        color: AppColors.secondaryText,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Last Updated: January 2024',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Policy Sections
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: policySections.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final section = policySections[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8.r,
                        offset: Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          section['icon'],
                          color: AppColors.primaryGold,
                          size: 20.sp,
                        ),
                      ),
                      title: Text(
                        section['title']!,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      iconColor: AppColors.primaryGold,
                      collapsedIconColor: AppColors.secondaryText,
                      childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                      tilePadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.screenBackground.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.primaryGold.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            section['content']!,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.secondaryText,
                              height: 1.6,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 32.h),

            // Contact Information Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    blurRadius: 12.r,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_support_outlined,
                        color: AppColors.primaryGold,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildContactItem(
                    Icons.business_outlined,
                    'Classia Capital Private Limited',
                    '58, 2nd Cross Rd, Chowdiah Block, Mannarayanapalya\nChamundi Nagar, RT Nagar, Bengaluru, Karnataka 560032',
                  ),
                  SizedBox(height: 12.h),
                  _buildContactItem(
                    Icons.email_outlined,
                    'Email',
                    'privacy@classiacapital.com',
                  ),
                  SizedBox(height: 12.h),
                  _buildContactItem(
                    Icons.phone_outlined,
                    'Phone',
                    '+91 98869 88679',
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerSupportScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.support_agent,
                      size: 18.sp,
                      color: AppColors.buttonText,
                    ),
                    label: Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.buttonText,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 14.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Acknowledgment Text
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                'By using our services, you acknowledge that you have read and understood this Privacy Policy.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
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