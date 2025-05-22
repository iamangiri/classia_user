import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../screenutills/fund_deatils_screen.dart';
import '../../themes/app_colors.dart';
import '../../utills/constent/home_screen_data.dart';

class HomeTrendingFundWidget extends StatelessWidget {
  const HomeTrendingFundWidget({super.key});

  bool _isValidFund(Map<String, dynamic> fund) {
    return fund['symbol'] != null && fund['price'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: HomeScreenData.trendingFunds.length,
        itemBuilder: (context, index) {
          final fund = HomeScreenData.trendingFunds[index];
          if (!_isValidFund(fund)) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FundDetailsScreen(fund: fund),
                  ),
                );
              },
              child: Container(
                width: 170.w,
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
                            imageUrl: fund['logo'] ?? 'https://via.placeholder.com/32',
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
                            fund['symbol'] ?? 'Unknown',
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
                      fund['company'] ?? 'Unknown Company',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '₹${fund['price'] ?? '0.00'}',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      fund['change'] ?? '0.00%',
                      style: TextStyle(
                        color: (fund['change'] ?? '0.00%').startsWith('+')
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 12.sp,
                      ),
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
}
