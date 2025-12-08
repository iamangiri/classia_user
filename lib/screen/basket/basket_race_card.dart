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

// ============================================
// UPDATED BasketRaceCard - Same 0-10 Scale Logic
// ============================================

class _BasketRaceCardState extends State<BasketRaceCard> with SingleTickerProviderStateMixin {
  late AnimationController _horseController;
  late Animation<double> _horseAnimation;

  @override
  void initState() {
    super.initState();
    _horseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _updateHorseAnimation();
    _horseController.forward();
  }

  void _updateHorseAnimation() {
    // Get the actual performance value (can be negative or positive)
    final double performance = widget.basket.performanceValue;

    // Map performance to 0-10 scale where:
    // performance = 0 → racePosition = 0 (start)
    // performance = 10 → racePosition = 1.0 (end)
    // performance = -10 → racePosition = 0 (start, but will show red)

    // Clamp the performance between -10 and +10, then normalize to 0-1
    double racePosition = (performance.abs() / 10).clamp(0.0, 1.0);

    _horseAnimation = Tween<double>(begin: 0, end: racePosition).animate(
      CurvedAnimation(parent: _horseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(BasketRaceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.basket.currentPriceValue != widget.basket.currentPriceValue ||
        oldWidget.basket.initialPriceValue != widget.basket.initialPriceValue) {
      _updateHorseAnimation();
      _horseController.reset();
      _horseController.forward();
    }
  }

  @override
  void dispose() {
    _horseController.dispose();
    super.dispose();
  }

  Color _volatilityColor(String vol) {
    return switch (vol.toUpperCase()) {
      'LOW' => AppColors.success.withOpacity(0.2),
      'MID' => AppColors.warning.withOpacity(0.2),
      'HIGH' => AppColors.error.withOpacity(0.2),
      _ => AppColors.disabled.withOpacity(0.2),
    };
  }

  Color _volatilityTextColor(String vol) {
    return switch (vol.toUpperCase()) {
      'LOW' => AppColors.success,
      'MID' => AppColors.warning,
      'HIGH' => AppColors.error,
      _ => AppColors.secondaryText,
    };
  }

  Color _actionBgColor(String action) {
    return action.toUpperCase() == 'BUY'
        ? AppColors.success.withOpacity(0.15)
        : AppColors.error.withOpacity(0.15);
  }

  Color _actionTextColor(String action) {
    return action.toUpperCase() == 'BUY' ? AppColors.success : AppColors.error;
  }

  IconData _actionIcon(String action) {
    return action.toUpperCase() == 'BUY' ? Icons.arrow_upward : Icons.arrow_downward;
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width - 48.w;
    final String action = widget.basket.action;
    final double performance = widget.basket.performanceValue;
    final bool isPositive = performance >= 0;

    // Determine race bar color based on positive/negative
    final Color raceBarColor = isPositive ? AppColors.primaryGold : AppColors.error;

    return Card(
      elevation: widget.isSubscribed ? 6 : 3,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(
          color: widget.isSubscribed
              ? AppColors.primaryGold
              : AppColors.primaryGold.withOpacity(0.25),
          width: widget.isSubscribed ? 2.5 : 1.2,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: widget.onTap,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Name + RA + Action Badge
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
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.headingText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.isSubscribed) ...[
                                  SizedBox(width: 8.w),
                                  Icon(Icons.verified, color: AppColors.primaryGold, size: 20.sp),
                                ],
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  'RA: ${widget.basket.raName}',
                                  style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: _actionBgColor(action),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(color: _actionTextColor(action), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_actionIcon(action), color: _actionTextColor(action), size: 12.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        action.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: _actionTextColor(action),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Price Information
                  Row(
                    children: [
                      Expanded(
                        child: _priceBox(
                          'Initial',
                          widget.basket.initialPriceValue > 0
                              ? '₹${widget.basket.initialPriceValue.toStringAsFixed(0)}'
                              : '₹0',
                          AppColors.primaryColor.withOpacity(0.12),
                          AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _priceBox(
                          'Current',
                          widget.basket.currentPriceValue > 0
                              ? '₹${widget.basket.currentPriceValue.toStringAsFixed(0)}'
                              : '₹0',
                          isPositive
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          isPositive ? AppColors.success : AppColors.error,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isPositive ? AppColors.success : AppColors.error,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive ? Icons.trending_up : Icons.trending_down,
                                  color: isPositive ? AppColors.success : AppColors.error,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${performance.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: isPositive ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Change',
                              style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Horse Race Animation with 0-10 Scale
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background Track
                      Container(
                        width: cardWidth,
                        height: 10.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          color: raceBarColor.withOpacity(0.18),
                          border: Border.all(color: raceBarColor.withOpacity(0.4), width: 1.5),
                        ),
                      ),

                      // Progress Bar
                      AnimatedBuilder(
                        animation: _horseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: _horseAnimation.value * cardWidth,
                            height: 10.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              gradient: LinearGradient(
                                colors: [raceBarColor, raceBarColor.withOpacity(0.7)],
                              ),
                            ),
                          );
                        },
                      ),

                      // Horse Animation
                      AnimatedBuilder(
                        animation: _horseAnimation,
                        builder: (context, child) {
                          final double horsePosition = _horseAnimation.value * cardWidth;
                          return Positioned(
                            left: (horsePosition - 30.w).clamp(0.0, cardWidth - 60.w),
                            top: -38.h,
                            child: Image.asset(
                              'assets/images/jt1.gif',
                              height: 60.h,
                              width: 70.w,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),

                      // Scale Labels (0 to 10)
                      Positioned(
                        bottom: -20.h,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0', style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText)),
                            Text('2.5', style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText)),
                            Text('5', style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText)),
                            Text('7.5', style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText)),
                            Text('10', style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h), // Extra space for scale labels

                  // Invested Amount
                  if (widget.isSubscribed && widget.investedAmount > 0) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGold.withOpacity(0.15),
                            AppColors.primaryGold.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primaryGold.withOpacity(0.4), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: AppColors.primaryGold, size: 20.sp),
                          SizedBox(width: 10.w),
                          Text('Total Invested: ', style: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText)),
                          Text(
                            '₹${widget.investedAmount.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Chips
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 8.h,
                    children: [
                      _miniChip(widget.basket.subscryptionType, AppColors.primaryColor.withOpacity(0.12), AppColors.primaryColor),
                      _miniChip(widget.basket.volatility, _volatilityColor(widget.basket.volatility), _volatilityTextColor(widget.basket.volatility)),
                      if (!widget.basket.isFree)
                        _miniChip('₹${widget.basket.subscriptionAmountValue.toString()}', AppColors.primaryGold.withOpacity(0.12), AppColors.primaryGold),
                      _miniChip('${widget.basket.holdingsCount} Holdings', AppColors.accent.withOpacity(0.12), AppColors.accent),
                    ],
                  ),
                ],
              ),
            ),

            // Subscribed Badge
            if (widget.isSubscribed)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.onPrimaryColor, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('Subscribed', style: TextStyle(color: AppColors.onPrimaryColor, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _priceBox(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText)),
          SizedBox(height: 2.h),
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Text(label, style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
