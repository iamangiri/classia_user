import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screenutills/mutual_fund_transation.dart';
import '../can/can_create_screen.dart';
import '../can/payezz_registration_screen.dart';
import '../learn/learn_screen.dart';
import '../learn/my_courses_screen.dart';
import '../learn/certificates_screen.dart';
import '../profile/about_us_screen.dart';
import '../profile/bank_info_screen.dart';
import '../profile/chnage_password_screen.dart';
import '../profile/customer_support_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/kyc_screen.dart';
import '../profile/my_wallet_screen.dart';
import '../profile/privicy_policy.dart';
import '../profile/demat_account_screen.dart';
import '../profile/login_history_screen.dart';
import '../stock/stock_market_fund_screen.dart';
import '../stock/stock_market_holding_screen.dart';
import '../stock/order_book_screen.dart';
import '../stock/trade_book_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(title: 'Profile'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernProfileCard(context),
            SizedBox(height: 24.h),
            _buildSectionTitle('Account'),
            _buildAccountOptionsList(context),
            SizedBox(height: 24.h),
            _buildSectionTitle('Learning'),
            _buildLearningOptionsList(context),
            SizedBox(height: 24.h),
            _buildSectionTitle('Transactions'),
            _buildTransactionsOptionsList(context),
            SizedBox(height: 24.h),
            _buildSectionTitle('Security'),
            _buildSecurityOptionsList(context),
            SizedBox(height: 24.h),
            _buildSectionTitle('Support'),
            _buildSupportOptionsList(context),
            SizedBox(height: 32.h),
            _buildModernLogoutButton(context),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ------------------ MODERN PROFILE CARD ------------------
  Widget _buildModernProfileCard(BuildContext context) {
    String userName = UserConstants.NAME?.toString() ?? "User";
    String userEmail = UserConstants.EMAIL?.toString() ?? "user@example.com";
    if (userName.trim().isEmpty) userName = "User";

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F3A), Color(0xFF1A3A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1F3A).withOpacity(0.3),
            blurRadius: 20.r,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700), width: 2.w),
            ),
            child: CircleAvatar(
              radius: 36.r,
              backgroundColor: const Color(0xFFFFD700).withOpacity(0.2),
              child: Text(
                userName.trim()[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(Icons.edit_outlined, color: const Color(0xFFFFD700)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileDetailsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ SECTION TITLE ------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0A1F3A),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ------------------ ACCOUNT OPTIONS ------------------
  Widget _buildAccountOptionsList(BuildContext context) {
    final options = [
      {'title': 'KYC', 'icon': Icons.verified_user, 'color': 0xFF4CAF50},
      {'title': 'CAN', 'icon': Icons.account_circle, 'color': 0xFF2196F3},
      {
        'title': 'PayZee Registration',
        'icon': Icons.payment,
        'color': 0xFF9C27B0
      },
      {
        'title': 'Demat Account',
        'icon': Icons.account_balance_wallet,
        'color': 0xFFFF9800
      },
      {
        'title': 'Bank Info',
        'icon': Icons.account_balance,
        'color': 0xFF00BCD4
      },
    ];
    return _buildModernOptionsList(options, context);
  }

  // ------------------ LEARNING OPTIONS ------------------
  Widget _buildLearningOptionsList(BuildContext context) {
    final options = [
      {'title': 'Learn', 'icon': Icons.school_rounded, 'color': 0xFF673AB7},
      {
        'title': 'My Courses',
        'icon': Icons.play_lesson_rounded,
        'color': 0xFF00BCD4
      },
      {
        'title': 'Certificates',
        'icon': Icons.workspace_premium,
        'color': 0xFFD4AF37
      },
    ];
    return _buildModernOptionsList(options, context);
  }

  // ------------------ TRANSACTIONS OPTIONS ------------------
  Widget _buildTransactionsOptionsList(BuildContext context) {
    final options = [
      {
        'title': 'My Wallet',
        'icon': Icons.account_balance_wallet,
        'color': 0xFFFFD700
      },
      {
        'title': 'Stock Market Fund',
        'icon': Icons.trending_up,
        'color': 0xFF4CAF50
      },
      {
        'title': 'Stock Market Holdings',
        'icon': Icons.show_chart,
        'color': 0xFF2196F3
      },
      {'title': 'Order Book', 'icon': Icons.receipt_long, 'color': 0xFFFF5722},
      {'title': 'Trade Book', 'icon': Icons.swap_vert, 'color': 0xFF9C27B0},
      {
        'title': 'Mutual Fund Transaction',
        'icon': Icons.history,
        'color': 0xFF607D8B
      },
    ];
    return _buildModernOptionsList(options, context);
  }

  // ------------------ SECURITY OPTIONS ------------------
  Widget _buildSecurityOptionsList(BuildContext context) {
    final options = [
      {
        'title': 'Change Password',
        'icon': Icons.lock_reset,
        'color': 0xFFFF9800
      },
      {'title': 'Login History', 'icon': Icons.history, 'color': 0xFF3F51B5},
    ];
    return _buildModernOptionsList(options, context);
  }

  // ------------------ SUPPORT OPTIONS ------------------
  Widget _buildSupportOptionsList(BuildContext context) {
    final options = [
      {'title': 'About Us', 'icon': Icons.info_outline, 'color': 0xFF2196F3},
      {'title': 'Help Center', 'icon': Icons.help_outline, 'color': 0xFF4CAF50},
      {
        'title': 'Privacy Policy',
        'icon': Icons.privacy_tip_outlined,
        'color': 0xFF9C27B0
      },
    ];
    return _buildModernOptionsList(options, context);
  }

  // ------------------ MODERN REUSABLE LIST UI ------------------
  Widget _buildModernOptionsList(
      List<Map<String, dynamic>> options, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade100,
          indent: 60.w,
        ),
        itemBuilder: (context, index) {
          final opt = options[index];
          final icon = opt['icon'] as IconData;
          final color = Color(opt['color'] as int);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToOption(context, opt['title'] as String),
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? Radius.circular(16.r) : Radius.zero,
                bottom: index == options.length - 1
                    ? Radius.circular(16.r)
                    : Radius.zero,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(icon, color: color, size: 22.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        opt['title'] as String,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF0A1F3A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade400,
                      size: 16.sp,
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

  // ------------------ NAVIGATION HANDLER ------------------
  void _navigateToOption(BuildContext context, String title) {
    late Widget screen;
    switch (title) {
      case 'KYC':
        screen = KYCVerificationScreen();
        break;
      case 'CAN':
        screen = CamsCreationScreen();
        break;
      case 'PayZee Registration':
        screen = PayZeeRegistrationScreen();
        break;
      case 'Learn':
        screen = const LearnScreen();
        break;
      case 'My Courses':
        screen = const MyCoursesScreen();
        break;
      case 'Certificates':
        screen = const CertificatesScreen();
        break;
      case 'Demat Account':
        screen = DematAccountScreen();
        break;
      case 'Bank Info':
        screen = BankInfoScreen();
        break;
      case 'My Wallet':
        screen = MyWalletScreen();
        break;
      case 'Stock Market Fund':
        screen = StockMarketFundScreen();
        break;
      case 'Stock Market Holdings':
        screen = StockHoldingsScreen();
        break;
      case 'Order Book':
        screen = OrderBookScreen();
        break;
      case 'Trade Book':
        screen = TradeBookScreen();
        break;
      case 'Mutual Fund Transaction':
        screen = TransactionScreen();
        break;

      case 'Change Password':
        screen = ChangePasswordScreen();
        break;
      case 'Login History':
        screen = LoginHistoryScreen();
        break;
      case 'About Us':
        screen = AboutUsScreen();
        break;
      case 'Help Center':
        screen = CustomerSupportScreen(showBackButton: true);
        break;
      case 'Privacy Policy':
        screen = PrivacyPolicyScreen();
        break;
      default:
        screen = Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text("Coming Soon")),
        );
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ------------------ MODERN LOGOUT BUTTON ------------------
  Widget _buildModernLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE53935), width: 2.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final confirmed = await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r)),
                title: Row(
                  children: [
                    Icon(Icons.logout,
                        color: const Color(0xFFE53935), size: 24.sp),
                    SizedBox(width: 12.w),
                    Text(
                      'Confirm Logout',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Text(
                  'Are you sure you want to log out?',
                  style:
                      TextStyle(fontSize: 15.sp, color: Colors.grey.shade700),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await SharedPreferences.getInstance()
                          .then((p) => p.clear());
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Logout',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) context.goNamed('splash');
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: const Color(0xFFE53935), size: 22.sp),
              SizedBox(width: 12.w),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
