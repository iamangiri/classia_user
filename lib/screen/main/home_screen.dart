import 'package:classia_amc/screen/homefetures/investment_history_screen.dart';
import 'package:classia_amc/screen/homefetures/market_news.dart';
import 'package:classia_amc/screen/learn/learn_screen.dart';
import 'package:classia_amc/screen/main/profile_heath_screen.dart';
import 'package:classia_amc/screen/profile/my_wallet_screen.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/widget/custom_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../screenutills/mutual_fund_transation.dart';
import '../../themes/app_colors.dart';
import '../../widget/custom_app_bar.dart';
import '../home/home_certificate_section.dart';
import '../home/home_features_widget.dart';
import '../home/home_learn_section.dart';
import '../home/home_pending_kyc_dialog_box.dart';
import '../home/home_sip_goal_section.dart';
import '../home/home_slider.dart';
import '../home/home_stock_market_section.dart';
import '../homefetures/lunchpad_screen.dart';
import 'home_disclamer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserDataAndShowPopups();
  }

  Future<void> _loadUserDataAndShowPopups() async {
    await UserConstants.loadUserData();
    print(UserConstants.USER_ID);
    print(UserConstants.TOKEN);
    print(UserConstants.NAME);
    print(UserConstants.EMAIL);
    print(UserConstants.PHONE);
    print(UserConstants.KYC_STATUS);
    print(UserConstants.BANK_DETAILS);

    // Check KYC status and show popup if incomplete
    if (UserConstants.KYC_STATUS == null || UserConstants.KYC_STATUS == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => HomePendingKycDialogBox(
            title: 'Complete Your KYC',
            message: 'Please complete your KYC verification to start trading and investing securely.',
            icon: FontAwesomeIcons.idCard,
            actionType: 'KYC',
          ),
        );
      });
    }

    // Check bank details and show popup if incomplete
    if (UserConstants.BANK_DETAILS == null || UserConstants.BANK_DETAILS == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => HomePendingKycDialogBox(
            title: 'Add Bank Details',
            message: 'Please add your bank details to enable seamless transactions for deposits and withdrawals.',
            icon: FontAwesomeIcons.bank,
            actionType: 'Bank Details',
          ),
        );
      });
    }
  }

  void _navigateToFeature(String title, BuildContext context) {
    Widget destination;
    switch (title) {
      case 'My Wallet':
        destination = MyWalletScreen();
        break;
      case 'Investment':
        destination = const InvestmentHistoryScreen();
        break;
      case 'Learn':
        destination = LearnScreen();
        break;
      case 'Market News':
        destination = const MarketNewsScreen();
        break;
      case 'Launchpad':
        destination = LaunchpadScreen();
        break;
      // case 'My Reports':
      //   destination = const DownloadReportsScreen();
      //   break;
      case 'Transactions':
        destination = TransactionScreen();
        break;
      default:
        destination = Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: TextStyle(
                color: AppColors.primaryText ?? Colors.black87,
                fontSize: 18.sp,
              ),
            ),
            backgroundColor: AppColors.screenBackground ?? Colors.white,
          ),
          backgroundColor: AppColors.screenBackground ?? Colors.white,
          body: Center(
            child: Text(
              'Screen for $title',
              style: TextStyle(
                color: AppColors.primaryText ?? Colors.black87,
                fontSize: 16.sp,
              ),
            ),
          ),
        );
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide from right
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        reverseTransitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildProgressFab(BuildContext context) {
    const totalProgress = 0.50;
    return FloatingActionButton(
      backgroundColor: AppColors.primaryGold,
      elevation: 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: totalProgress,
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
            backgroundColor: AppColors.screenBackground.withOpacity(0.5),
          ),
          Text(
            '${(totalProgress * 100).toInt()}%',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileHealthScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CustomAppBar(
        title: 'Classia Capital',
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel Slider
              HomeDisclaimer(
                message: "Mutual Fund investments are subject to market risks, read all scheme related documents carefully.",
              ),
              HomeSliderWidget(),
              SizedBox(height: 24.h),
              // Features Section
              CustomHeading(text: 'Features', lineWidth: 40.w),
              SizedBox(height: 12.h),
              HomeFeaturesWidget(
                onFeatureTap: _navigateToFeature,
              ),
              SizedBox(height: 24.h),

              HomeStockMarketSection(),
              // HomeJockeyTradeSection(),
              SizedBox(height: 24.h),
              // New Section: Learn & Earn
             HomeLearnSection(),
             // SizedBox(height: 24.h),
           //   HomeTrendingFundWidget(),
              SizedBox(height: 24.h),
              HomeSipGoalSection(),
              SizedBox(height: 24.h),
              // Top Mutual Funds Section
            //  TopMutualFundsSection(),
             SizedBox(height: 12.h),
              HomeCertificateSection(),
            ],
          ),
        ),
      ),
     // floatingActionButton: _buildProgressFab(context),
    );
  }
}