
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../themes/app_colors.dart';
import 'basket_model.dart';

class BasketRaceCard extends StatefulWidget {
  final Basket basket;
  final VoidCallback onTap;
  final bool isMarketOpen;
  final bool isSubscribed;
  final double investedAmount;

  const BasketRaceCard({
    super.key,
    required this.basket,
    required this.onTap,
    required this.isMarketOpen,
    required this.isSubscribed,
    required this.investedAmount,
  });

  @override
  State<BasketRaceCard> createState() => _BasketRaceCardState();
}

class _BasketRaceCardState extends State<BasketRaceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _horseController;
  late Animation<double> _horseAnimation;
  late double _raceScore;

  @override
  void initState() {
    super.initState();
    _raceScore = (Random().nextDouble() * 9 + 1);

    _horseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _updateHorseAnimation();
  }

  void _updateHorseAnimation() {
    double normalizedValue = (_raceScore / 10).clamp(0.0, 1.0);
    _horseAnimation = Tween<double>(
      begin: 0,
      end: normalizedValue,
    ).animate(CurvedAnimation(
      parent: _horseController,
      curve: Curves.easeInOut,
    ));
    _horseController.forward();
  }

  @override
  void dispose() {
    _horseController.dispose();
    super.dispose();
  }

  Color _volatilityColor(String vol) {
    switch (vol) {
      case 'LOW':
        return AppColors.success.withOpacity(0.2);
      case 'MID':
        return AppColors.warning.withOpacity(0.2);
      case 'HIGH':
        return AppColors.error.withOpacity(0.2);
      default:
        return AppColors.disabled.withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double performance = double.tryParse(widget.basket.expectedReturn) ?? 0;
    final bool isPositive = performance >= 0;
    final double cardWidth = MediaQuery.of(context).size.width - 48.w;

    return Card(
      elevation: widget.isSubscribed ? 4 : 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: widget.isSubscribed
              ? AppColors.primaryGold
              : AppColors.primaryGold.withOpacity(0.3),
          width: widget.isSubscribed ? 2 : 1,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: widget.onTap,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.basket.basketName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.headingText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.isSubscribed) ...[
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.verified,
                                    color: AppColors.primaryGold,
                                    size: 18.sp,
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'RA: ${widget.basket.raName}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isPositive ? AppColors.success : AppColors.error,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPositive ? Icons.trending_up : Icons.trending_down,
                                  color: isPositive ? AppColors.success : AppColors.error,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${widget.basket.expectedReturn}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: isPositive ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Expected',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: cardWidth,
                        height: 8.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          color: AppColors.primaryGold.withOpacity(0.2),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _horseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: _horseAnimation.value * cardWidth,
                            height: 8.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGold,
                                  AppColors.primaryGold.withOpacity(0.6),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _horseAnimation,
                        builder: (context, child) {
                          double horsePosition = _horseAnimation.value * cardWidth;
                          return Positioned(
                            left: (horsePosition - 25.w).clamp(0.0, cardWidth - 50.w),
                            top: -35.h,
                            child: SizedBox(
                              height: 50.h,
                              width: 60.w,
                              child: Image.asset(
                                'assets/images/jt1.gif',
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  if (widget.isSubscribed && widget.investedAmount > 0) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGold.withOpacity(0.1),
                            AppColors.primaryGold.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.primaryGold.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.primaryGold,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Invested: ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          Text(
                            '₹${widget.investedAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      _miniChip(
                        widget.basket.subscryptionType,
                        AppColors.primaryColor.withOpacity(0.1),
                        AppColors.primaryColor,
                      ),
                      _miniChip(
                        widget.basket.volatility,
                        _volatilityColor(widget.basket.volatility),
                        widget.basket.volatility == 'LOW'
                            ? AppColors.success
                            : widget.basket.volatility == 'MID'
                            ? AppColors.warning
                            : AppColors.error,
                      ),
                      if (!widget.basket.isFree)
                        _miniChip(
                          '₹${widget.basket.subscriptionAmount}',
                          AppColors.primaryGold.withOpacity(0.1),
                          AppColors.primaryGold,
                        ),
                      _miniChip(
                        '${widget.basket.holdings.length} Holdings',
                        AppColors.accent.withOpacity(0.1),
                        AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (widget.isSubscribed)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14.r),
                      bottomLeft: Radius.circular(14.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.onPrimaryColor,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Subscribed',
                        style: TextStyle(
                          color: AppColors.onPrimaryColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}



