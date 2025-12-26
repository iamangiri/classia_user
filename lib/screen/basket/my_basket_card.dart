import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'basket_model.dart';

class MyBasketCard extends StatefulWidget {
  final Basket basket;
  final VoidCallback onTap;
  final bool isMarketOpen;
  final bool isSubscribed;
  final double investedAmount;
  final String basketType;

  const MyBasketCard({
    super.key,
    required this.basket,
    required this.onTap,
    required this.isMarketOpen,
    required this.isSubscribed,
    required this.investedAmount,
    required this.basketType,
  });

  @override
  State<MyBasketCard> createState() => _MyBasketCardState();
}

class _MyBasketCardState extends State<MyBasketCard> with SingleTickerProviderStateMixin {
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

    // ✅ Only move horse for POSITIVE values
    // For negative values, keep horse at position 0 (start)
    double racePosition = 0.0;

    if (performance > 0) {
      // For positive performance, scale to 0-1 range (0% to 100%)
      racePosition = (performance / 100).clamp(0.0, 1.0);
    }
    // else: negative values stay at 0.0 (horse doesn't move backwards)

    _horseAnimation = Tween<double>(begin: 0, end: racePosition).animate(
      CurvedAnimation(parent: _horseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MyBasketCard oldWidget) {
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

  Color _getTypeColor() {
    return widget.basketType == 'INTRADAY'
        ? const Color(0xFFFF9800)
        : const Color(0xFF9C27B0); // Purple for SWING
  }

  // ✅ Always use green for race - positive color scheme
  Color _getRaceColor() {
    return const Color(0xFF4CAF50); // Always green
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for better responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32; // 16px margin on each side

    final String action = widget.basket.action;
    final double performance = widget.basket.performanceValue;
    final bool isPositive = performance >= 0;
    final Color typeColor = _getTypeColor();
    final Color raceBarColor = _getRaceColor(); // ✅ Always green

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: widget.isSubscribed ? typeColor : const Color(0xFFE0E0E0),
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Type Icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        widget.basketType == 'INTRADAY'
                            ? Icons.flash_on
                            : Icons.speed,
                        color: typeColor,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
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
                                    color: const Color(0xFF0A1F3A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.isSubscribed) ...[
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.verified,
                                  color: typeColor,
                                  size: 18.sp,
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 4.h,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'RA: ${widget.basket.raName}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
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
                                      action.toUpperCase() == 'BUY'
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: action.toUpperCase() == 'BUY'
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFE53935),
                                      size: 11.sp,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      action.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10.sp,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
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
                            isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: isPositive
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE53935),
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${performance.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: isPositive
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Price Row - Responsive
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          child: _compactPriceBox(
                            'Initial',
                            '₹${widget.basket.initialPriceValue > 0 ? widget.basket.initialPriceValue.toStringAsFixed(0) : '0'}',
                            const Color(0xFF2196F3),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _compactPriceBox(
                            'Current',
                            '₹${widget.basket.currentPriceValue > 0 ? widget.basket.currentPriceValue.toStringAsFixed(0) : '0'}',
                            isPositive
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 14.h),

                // Horse Race Animation - Only moves for positive performance
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background track - Always green
                        Container(
                          width: availableWidth,
                          height: 8.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            color: raceBarColor.withOpacity(0.2),
                          ),
                        ),
                        // Animated progress bar - Only shows for positive performance
                        if (performance > 0)
                          AnimatedBuilder(
                            animation: _horseAnimation,
                            builder: (context, child) {
                              return Container(
                                width: _horseAnimation.value * availableWidth,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  gradient: LinearGradient(
                                    colors: [
                                      raceBarColor,
                                      raceBarColor.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        // Horse GIF
                        AnimatedBuilder(
                          animation: _horseAnimation,
                          builder: (context, child) {
                            final double horsePosition =
                                _horseAnimation.value * availableWidth;
                            final double horseWidth = 50.w;

                            return Positioned(
                              left: (horsePosition - horseWidth / 2)
                                  .clamp(0.0, availableWidth - horseWidth),
                              top: -32.h,
                              child: Image.asset(
                                'assets/images/jt1.gif',
                                height: 45.h,
                                width: horseWidth,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                        // ✅ Performance indicator at start for negative values
                        if (performance < 0)
                          Positioned(
                            left: 0,
                            top: 12.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Loss: ${performance.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0xFFE53935),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24.h),

                // Invested Amount (if subscribed)
                if (widget.isSubscribed && widget.investedAmount > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          typeColor.withOpacity(0.15),
                          typeColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: typeColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Invested: ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '₹${widget.investedAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                // Chips - Responsive Wrap
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _miniChip(
                      widget.basket.subscryptionType,
                      const Color(0xFF2196F3),
                    ),
                    _miniChip(
                      widget.basket.volatility,
                      _getVolatilityColor(widget.basket.volatility),
                    ),
                    if (!widget.basket.isFree)
                      _miniChip(
                        '₹${widget.basket.subscriptionAmountValue}',
                        typeColor,
                      ),
                    _miniChip(
                      '${widget.basket.holdingsCount} Holdings',
                      const Color(0xFF9C27B0),
                    ),
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
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
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