import 'package:classia_amc/screen/homefetures/withdraw_screen.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screenutills/mutual_fund_transation.dart';
import '../can/can_create_screen.dart';
import '../can/payezz_registration_screen.dart';
import '../profile/about_us_screen.dart';
import '../profile/bank_info_screen.dart';
import '../profile/customer_support_screen.dart';
import '../homefetures/investment_history_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/kyc_screen.dart';
import '../profile/learn_screen.dart';
import '../profile/manage_folio_screen.dart';
import '../profile/my_wallet_screen.dart';
import '../profile/privicy_policy.dart';
import '../profile/security_setting _screen.dart';
import '../profile/demat_account_screen.dart';

// Import both stock screens
import '../stock/stock_market_fund_screen.dart';
import '../stock/stock_market_holding_screen.dart'; // or stock_holdings_screen.dart

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Profile'),
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
            _buildSectionTitle('Transactions'),
            _buildTransactionsOptionsList(context), // Now includes both Fund & Holdings
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
    String userName = UserConstants.NAME?.toString() ?? "User";
    String userEmail = UserConstants.EMAIL?.toString() ?? "user@example.com";
    if (userName.trim().isEmpty) userName = "User";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40.r,
          backgroundColor: AppColors.border,
          child: Text(
            userName.trim()[0].toUpperCase(),
            style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primaryText), overflow: TextOverflow.ellipsis),
              SizedBox(height: 4.h),
              Text(userEmail, style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit, color: AppColors.accent),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen())),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
    );
  }

  // Account Section
  Widget _buildAccountOptionsList(BuildContext context) {
    final options = [
      {'title': 'KYC', 'icon': 'verified_user'},
      {'title': 'CAN', 'icon': 'account_circle'},
      {'title': 'PayZee Registration', 'icon': 'payment'},
      {'title': 'Demat Account', 'icon': 'account_balance_wallet'},
      {'title': 'Bank Info', 'icon': 'account_balance'},
    ];
    return _buildOptionsList(options, context);
  }

  // Transactions Section — Now includes both Fund & Holdings
  Widget _buildTransactionsOptionsList(BuildContext context) {
    final options = [
      {'title': 'My Wallet', 'icon': 'account_balance_wallet'},
      {'title': 'Stock Market Fund', 'icon': 'account_balance_wallet'},     // Same icon style
      {'title': 'Stock Market Holdings', 'icon': 'show_chart'},             // Same icon style
      {'title': 'Jockey Investment', 'icon': 'trending_up'},
      {'title': 'Jockey Withdraw', 'icon': 'money_off'},
      {'title': 'Mutual Fund Transaction', 'icon': 'history'},
    ];
    return _buildOptionsList(options, context);
  }

  // Preferences Section
  Widget _buildPreferencesList(BuildContext context) {
    final options = [
      {'title': 'Security Settings', 'icon': 'security'},
      {'title': 'About Us', 'icon': 'info'},
      {'title': 'Help Center', 'icon': 'help'},
      {'title': 'Privacy Policy', 'icon': 'privacy'},
    ];
    return _buildOptionsList(options, context);
  }

  // Reusable list builder — 100% same design for all items
  Widget _buildOptionsList(List<Map<String, String>> options, BuildContext context) {
    final iconMap = {
      'verified_user': Icons.verified_user,
      'account_circle': Icons.account_circle,
      'payment': Icons.payment,
      'account_balance_wallet': Icons.account_balance_wallet,
      'account_balance': Icons.account_balance,
      'show_chart': Icons.show_chart,
      'trending_up': Icons.trending_up,
      'money_off': Icons.money_off,
      'history': Icons.history,
      'security': Icons.security,
      'info': Icons.info,
      'help': Icons.help,
      'privacy': Icons.privacy_tip,
    };

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final opt = options[index];
        final icon = iconMap[opt['icon']] ?? Icons.help_outline;

        return GestureDetector(
          onTap: () => _navigateToOption(context, opt['title']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(vertical: 4.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6.r, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryGold, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    opt['title']!,
                    style: TextStyle(fontSize: 16.sp, color: AppColors.primaryText, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: AppColors.secondaryText, size: 16.sp),
              ],
            ),
          ),
        );
      },
    );
  }

  // Navigation logic — both screens added
  void _navigateToOption(BuildContext context, String title) {
    late Widget screen;

    switch (title) {
      case 'KYC': screen = const KYCVerificationScreen(); break;
      case 'CAN': screen = const CamsCreationScreen(); break;
      case 'PayZee Registration': screen = const PayZeeRegistrationScreen(); break;
      case 'Demat Account': screen = const DematAccountScreen(); break;
      case 'Bank Info': screen = BankInfoScreen(); break;
      case 'My Wallet': screen = const MyWalletScreen(); break;
      case 'Jockey Investment': screen = const InvestmentHistoryScreen(); break;
      case 'Jockey Withdraw': screen = const WithdrawScreen(); break;
      case 'Mutual Fund Transaction': screen = TransactionScreen(); break;
      case 'Security Settings': screen = const SecuritySettingsScreen(); break;
      case 'About Us': screen = AboutUsScreen(); break;
      case 'Help Center': screen = CustomerSupportScreen(); break;
      case 'Privacy Policy': screen = PrivacyPolicyScreen(); break;

    // Both Stock Screens — Same navigation style
      case 'Stock Market Fund':
        screen = StockMarketFundScreen();
        break;
      case 'Stock Market Holdings':
        screen = StockHoldingsScreen(); // or StockMarketHoldingScreen()
        break;

      default:
        screen = Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('Coming Soon')));
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              title: Text('Confirm Logout', style: TextStyle(fontSize: 18.sp)),
              content: Text('Are you sure you want to log out?', style: TextStyle(fontSize: 16.sp)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: AppColors.primaryGold))),
                TextButton(
                  onPressed: () async {
                    await SharedPreferences.getInstance().then((p) => p.clear());
                    Navigator.pop(context, true);
                  },
                  child: Text('Logout', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) context.goNamed('splash');
        },
        icon: Icon(Icons.logout, color: AppColors.error, size: 20.sp),
        label: Text('Logout', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.error)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
        ),
      ),
    );
  }
}