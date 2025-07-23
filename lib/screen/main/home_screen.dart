import 'package:classia_amc/screen/homefetures/investment_history_screen.dart';
import 'package:classia_amc/screen/homefetures/market_news.dart';
import 'package:classia_amc/screen/main/profile_heath_screen.dart';
import 'package:classia_amc/screen/profile/learn_screen.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:classia_amc/widget/custom_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';
import '../../widget/custom_app_bar.dart';
import '../home/home_certificate_section.dart';
import '../home/home_features_widget.dart';
import '../home/home_learn_section.dart';
import '../home/home_slider.dart';
import '../home/home_top_mutual_funds_section.dart';
import '../home/home_trending_fund_widget.dart';
import '../homefetures/lunchpad_screen.dart';
import '../homefetures/withdraw_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    print(UserConstants.USER_ID);
    print(UserConstants.TOKEN);
    print(UserConstants.NAME);
    print(UserConstants.EMAIL);
    print(UserConstants.PHONE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CustomAppBar(
        title: 'Jockey Trading',
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
              HomeSliderWidget(),
              SizedBox(height: 24.h),

              // Features Section
              CustomHeading(text: 'Features', lineWidth: 40.w),
              SizedBox(height: 12.h),
              HomeFeaturesWidget(
                onFeatureTap: _navigateToFeature,
              ),
              SizedBox(height: 24.h),

              // New Section: Learn & Earn
              HomeLearnSection(),

              SizedBox(height: 24.h),

              // Trending Funds Section
              CustomHeading(text: 'Trending Funds', lineWidth: 40.w),
              SizedBox(height: 12.h),
              HomeTrendingFundWidget(),
              SizedBox(height: 24.h),
              // Top Mutual Funds Section
              TopMutualFundsSection(),
              SizedBox(height: 12.h),
              HomeCertificateSection(),

            ],
          ),
        ),
      ),
      floatingActionButton: _buildProgressFab(context),
    );
  }

  bool _isValidFund(Map<String, String?> fund) {
    return fund['logo'] != null &&
        fund['logo']!.isNotEmpty &&
        fund['symbol'] != null &&
        fund['symbol']!.isNotEmpty &&
        fund['company'] != null &&
        fund['company']!.isNotEmpty &&
        fund['price'] != null &&
        fund['price']!.isNotEmpty &&
        fund['change'] != null &&
        fund['change']!.isNotEmpty;
  }

  void _navigateToFeature(String title, BuildContext context) {
    Widget destination;
    switch (title) {
      case 'Withdraw':
        destination = const WithdrawScreen();
        break;
      case 'Deposit':
        destination = const InvestmentHistoryScreen();
        break;
      case 'Learn':
        destination = LearnScreen();
        break;
      case 'Market News':
        destination = MarketNewsScreen();
        break;
      case 'Launchpad':
        destination = LaunchpadScreen();
        break;
      default:
        destination = Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
            ),
          ),
          backgroundColor: AppColors.screenBackground,
          body: Center(
            child: Text(
              'Screen for $title',
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
            ),
          ),
        );
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => destination));
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
}