import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'jt_trade_deatils_screen.dart';

class JtTradeCard extends StatefulWidget {
  final String logo;
  final String name;
  final String fundName;
  final double value;
  final Map<String, dynamic> fundData;

  const JtTradeCard({
    Key? key,
    required this.logo,
    required this.name,
    required this.fundName,
    required this.value,
    required this.fundData,
  }) : super(key: key);

  @override
  _JtTradeCardState createState() => _JtTradeCardState();
}

class _JtTradeCardState extends State<JtTradeCard> with SingleTickerProviderStateMixin {
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

  @override
  void didUpdateWidget(covariant JtTradeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateHorseAnimation();
    }
  }

  void _updateHorseAnimation() {
    double normalizedValue = (widget.value.abs() / 20).clamp(0.0, 1.0);
    _horseAnimation = Tween<double>(
      begin: 0,
      end: normalizedValue,
    ).animate(CurvedAnimation(parent: _horseController, curve: Curves.easeInOut));
    _horseController.forward(from: 0);
  }

  @override
  void dispose() {
    _horseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositive = widget.value >= 0;
    final double cardWidth = MediaQuery.of(context).size.width - 32.w;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JtTradeDeatilsScreen(
                  logo: widget.logo,
                  name: widget.name,
                  fundName: widget.fundName,
                  value: widget.value,
                  fundData: widget.fundData,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: const Color(0xFFFFD700).withOpacity(0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.network(
                          widget.logo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.account_balance,
                            color: const Color(0xFFFFD700),
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fundName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0A1F3A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : const Color(0xFFE53935).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                            size: 12.sp,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            '${widget.value.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Horse Race Animation
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: cardWidth,
                      height: 5.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5.r),
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _horseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: _horseAnimation.value * cardWidth,
                          height: 5.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.5.r),
                            gradient: LinearGradient(
                              colors: isPositive
                                  ? [const Color(0xFFFFD700), const Color(0xFFDAA520)]
                                  : [const Color(0xFFE53935), const Color(0xFFC62828)],
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
                          left: (horsePosition - 18.w).clamp(0.0, cardWidth - 36.w),
                          top: -26.h,
                          child: Image.asset(
                            'assets/images/jt1.gif',
                            height: 36.h,
                            width: 40.w,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
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
}