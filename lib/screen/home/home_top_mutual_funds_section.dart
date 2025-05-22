import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../screenutills/fund_deatils_screen.dart';
import '../../themes/app_colors.dart';
import '../../utills/constent/home_screen_data.dart';
import '../../widget/custom_heading.dart';
import '../main/market_screen.dart';

class TopMutualFundsSection extends StatelessWidget {
  const TopMutualFundsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
            childAspectRatio: 0.9,
          ),
          itemCount: HomeScreenData.mutualFunds.length,
          itemBuilder: (context, index) {
            final fund = HomeScreenData.mutualFunds[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FundDetailsScreen(fund: fund),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: fund['logo']!,
                            width: 32.w,
                            height: 32.h,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 32.w,
                              height: 32.h,
                              color: AppColors.border,
                              child: Icon(
                                Icons.image,
                                color: AppColors.disabled,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            fund['symbol']!,
                            style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      fund['company']!,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '₹${fund['price']}',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      fund['change']!,
                      style: TextStyle(
                        color: fund['change']!.startsWith('+')
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
