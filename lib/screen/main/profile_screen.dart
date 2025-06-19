import 'package:classia_amc/screen/homefetures/withdraw_screen.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/about_us_screen.dart';
import '../profile/bank_info_screen.dart';
import '../profile/customer_support_screen.dart';
import '../homefetures/investment_history_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/kyc_screen.dart';
import '../profile/learn_screen.dart';
import '../profile/manage_folio_screen.dart';
import '../profile/privicy_policy.dart';
import '../profile/security_setting _screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title:'Profle'
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            SizedBox(height: 20.h),
            _buildSectionTitle('Account'),
            _buildAccountOptionsList(context),
            SizedBox(height: 20.h),
            _buildSectionTitle('Preferences'),
            _buildPreferencesList(context),
            SizedBox(height: 20.h),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }



  Widget _buildProfileSection(BuildContext context) {
    String userName = "${UserConstants.NAME}"; // Replace with actual username
    String userEmail = "${UserConstants.EMAIL}"; // Replace with actual email

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.border, // Light border color
          child: Text(
            userName[0], // Show first letter of user's name
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText, // Dark text for contrast
            ),
          ),
        ),
        SizedBox(width: 16),
        // User Name and Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText, // Dark text
              ),
            ),
            SizedBox(height: 4),
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText, // Lighter secondary text
              ),
            ),
          ],
        ),
        Spacer(),
        // Edit Icon
        IconButton(
          icon: Icon(Icons.edit, color: AppColors.accent), // Accent color for edit
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildAccountOptionsList(BuildContext context) {
    final List<Map<String, String>> accountOptions = [
      {'title': 'KYC', 'icon': 'verified_user'},
      {'title': 'Manage Folio', 'icon': 'folio'},
      {'title': 'Security Settings', 'icon': 'security'},
      {'title': 'Bank Info', 'icon': 'account_balance'},
      {'title': 'Learn', 'icon': 'school'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accountOptions.length,
      itemBuilder: (context, index) {
        return _buildOptionItem(context, accountOptions[index]);
      },
    );
  }

  Widget _buildPreferencesList(BuildContext context) {
    final List<Map<String, String>> preferenceOptions = [
      {'title': 'About Us', 'icon': 'info'},
      {'title': 'Help Center', 'icon': 'help'},
      {'title': 'Privacy Policy', 'icon': 'privacy'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: preferenceOptions.length,
      itemBuilder: (context, index) {
        return _buildOptionItem(context, preferenceOptions[index]);
      },
    );
  }

  Widget _buildOptionItem(BuildContext context, Map<String, String> option) {
    IconData iconData;
    switch (option['icon']) {
      case 'folio':
        iconData = Icons.folder_open;
        break;
      case 'security':
        iconData = Icons.security;
        break;
      case 'verified_user':
        iconData = Icons.verified_user;
        break;
      case 'account_balance':
        iconData = Icons.account_balance;
        break;
      case 'school':
        iconData = Icons.school;
        break;
      case 'info':
        iconData = Icons.info;
        break;
      case 'help':
        iconData = Icons.help;
        break;
      case 'privacy':
        iconData = Icons.privacy_tip;
        break;
      default:
        iconData = Icons.help;
    }

    return GestureDetector(
      onTap: () {
        _navigateToOption(context, option['title']!);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(12.w),
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
        child: Row(
          children: [
            Icon(iconData, color: AppColors.primaryGold, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                option['title']!,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.secondaryText, size: 16.sp),
          ],
        ),
      ),
    );
  }

  void _navigateToOption(BuildContext context, String optionTitle) {
    Widget destination;
    switch (optionTitle) {
      case 'Manage Folio':
        destination = const ManageFolioScreen();
        break;
      case 'Investment History':
        destination =  InvestmentHistoryScreen();
        break;
      case 'Withdrawals':
        destination =  WithdrawScreen();
        break;
      case 'Security Settings':
        destination = const SecuritySettingsScreen();
        break;
      case 'KYC':
        destination = const KYCVerificationScreen();
        break;
      case 'Bank Info':
        destination =  BankInfoScreen();
        break;
      case 'Learn':
        destination =  LearnScreen();
        break;
      case 'About Us':
        destination =  AboutUsScreen();
        break;
      case 'Help Center':
        destination = CustomerSupportScreen();
        break;
      case 'Privacy Policy':
        destination =  PrivacyPolicyScreen();
        break;
      default:
        destination = Scaffold(
          appBar: AppBar(
            title: Text(
              optionTitle,
              style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
            ),
          ),
          backgroundColor: AppColors.screenBackground,
          body: Center(
            child: Text(
              'Screen for $optionTitle',
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
            ),
          ),
        );
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              title: Text(
                'Confirm Logout',
                style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
              ),
              content: Text(
                'Are you sure you want to log out?',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.primaryGold, fontSize: 14.sp),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // 1. Get the prefs instance
                    final prefs = await SharedPreferences.getInstance();
                    // 2. Clear everything (all keys)
                    await prefs.clear();
                    // 3. Pop this dialog/screen (and signal “true” if needed)
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                  ),
                ),

              ],
            ),
          );

          if (confirmed ?? false) {
            if (context.mounted) {
              context.goNamed('splash');
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
          minimumSize: Size(200.w, 48.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, color: AppColors.error, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}