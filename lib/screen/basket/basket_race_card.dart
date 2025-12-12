import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'basket_model.dart';

// ============================================
// MODERN COMPACT BasketRaceCard
// ============================================

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

class _BasketRaceCardState extends State<BasketRaceCard> with SingleTickerProviderStateMixin {
  late AnimationController _horseController;
  late Animation<double> _horseAnimation;

  @override
  void initState() {
    super.initState();
    _horseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _updateHorseAnimation();
    _horseController.forward();
  }

  void _updateHorseAnimation() {
    final double performance = widget.basket.performanceValue;
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

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width - 40.w;
    final String action = widget.basket.action;
    final double performance = widget.basket.performanceValue;
    final bool isPositive = performance >= 0;
    final Color raceBarColor = isPositive ? const Color(0xFFFFD700) : const Color(0xFFE53935);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: widget.isSubscribed
              ? const Color(0xFFFFD700)
              : const Color(0xFFE0E0E0),
          width: widget.isSubscribed ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
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
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0A1F3A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.isSubscribed) ...[
                                SizedBox(width: 6.w),
                                Icon(Icons.verified, color: const Color(0xFFFFD700), size: 16.sp),
                              ],
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Text(
                                'RA: ${widget.basket.raName}',
                                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: action.toUpperCase() == 'BUY'
                                      ? const Color(0xFF4CAF50).withOpacity(0.15)
                                      : const Color(0xFFE53935).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      action.toUpperCase() == 'BUY' ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: action.toUpperCase() == 'BUY'
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFE53935),
                                      size: 10.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      action.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                        color: action.toUpperCase() == 'BUY'
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFE53935),
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : const Color(0xFFE53935).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${performance.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Price Row
                Row(
                  children: [
                    Expanded(
                      child: _compactPriceBox(
                        'Initial',
                        '₹${widget.basket.initialPriceValue > 0 ? widget.basket.initialPriceValue.toStringAsFixed(0) : '0'}',
                        const Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _compactPriceBox(
                        'Current',
                        '₹${widget.basket.currentPriceValue > 0 ? widget.basket.currentPriceValue.toStringAsFixed(0) : '0'}',
                        isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Horse Race Animation - Compact
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: cardWidth,
                      height: 6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.r),
                        color: raceBarColor.withOpacity(0.2),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _horseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: _horseAnimation.value * cardWidth,
                          height: 6.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.r),
                            gradient: LinearGradient(
                              colors: [raceBarColor, raceBarColor.withOpacity(0.7)],
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _horseAnimation,
                      builder: (context, child) {
                        final double horsePosition = _horseAnimation.value * cardWidth;
                        return Positioned(
                          left: (horsePosition - 20.w).clamp(0.0, cardWidth - 40.w),
                          top: -28.h,
                          child: Image.asset(
                            'assets/images/jt1.gif',
                            height: 40.h,
                            width: 45.w,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Invested Amount (if subscribed)
                if (widget.isSubscribed && widget.investedAmount > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFD700).withOpacity(0.15),
                          const Color(0xFFFFD700).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: const Color(0xFFFFD700), size: 16.sp),
                        SizedBox(width: 8.w),
                        Text('Invested: ', style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                        Text(
                          '₹${widget.investedAmount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFFFFD700)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],

                // Chips - Compact
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    _miniChip(widget.basket.subscryptionType, const Color(0xFF2196F3)),
                    _miniChip(widget.basket.volatility, _getVolatilityColor(widget.basket.volatility)),
                    if (!widget.basket.isFree)
                      _miniChip('₹${widget.basket.subscriptionAmountValue}', const Color(0xFFFFD700)),
                    _miniChip('${widget.basket.holdingsCount} Holdings', const Color(0xFF9C27B0)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _compactPriceBox(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9.sp, color: Colors.grey[600])),
          SizedBox(height: 2.h),
          Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _getVolatilityColor(String vol) {
    return switch (vol.toUpperCase()) {
      'LOW' => const Color(0xFF4CAF50),
      'MID' => const Color(0xFFFF9800),
      'HIGH' => const Color(0xFFE53935),
      _ => Colors.grey,
    };
  }
}