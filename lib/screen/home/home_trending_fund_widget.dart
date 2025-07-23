import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../screenutills/fund_card_items.dart';
import '../../themes/app_colors.dart';
import '../../utills/constent/home_screen_data.dart';
import '../../widget/custom_heading.dart';
import '../main/market_screen.dart';

class HomeTrendingFundWidget extends StatelessWidget {
  const HomeTrendingFundWidget({super.key});

  bool _isValidFund(Map<String, dynamic> fund) {
    return fund['symbol'] != null && fund['price'] != null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final validFunds = HomeScreenData.trendingFunds.where(_isValidFund).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomHeading(text: 'Trending Funds', lineWidth: 40.w),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MarketScreen()),
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (validFunds.isEmpty)
          Center(
            child: Text(
              'No trending funds available',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.secondaryText?.withOpacity(0.8) ?? Colors.grey.withOpacity(0.8),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4, // 2 columns on small screens, 4 on larger
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.85, // Adjusted for FundCard's 160x190 size
            ),
            itemCount: validFunds.length,
            itemBuilder: (context, index) {
              final fund = validFunds[index];
              // Adapt trendingFunds data to FundCard's expected structure
              final adaptedFund = {
                'id': fund['id'] ?? fund['symbol'] ?? 'fund_$index',
                'name': fund['symbol'] ?? 'Demo Fund',
                'returns': fund['change'] ?? '0%',
                'minSip': fund['minSip'] ?? '₹1000', // Fallback
                'rating': fund['rating'] ?? '4.0', // Fallback
              };
              return FundCard(
                fund: adaptedFund,
                isDarkMode: isDarkMode,
              );
            },
          ),
      ],
    );
  }
}