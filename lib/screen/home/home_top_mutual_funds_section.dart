import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../screenutills/fund_card_items.dart';
import '../../themes/app_colors.dart';
import '../../utills/constent/home_screen_data.dart';
import '../../widget/custom_heading.dart';
import '../main/market_screen.dart';


class TopMutualFundsSection extends StatelessWidget {
  const TopMutualFundsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomHeading(text: 'Top Mutual Funds', lineWidth: 40.w),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MarketScreen()),
              ),
              child: Text(
                'View More',
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.85, // Adjusted to accommodate FundCard's 160x190 size
          ),
          itemCount: HomeScreenData.mutualFunds.length,
          itemBuilder: (context, index) {
            final fund = HomeScreenData.mutualFunds[index];
            // Adapt mutualFunds data to FundCard's expected structure
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