
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';
import '../screenutills/trade_details_screen.dart';

class TradingCard extends StatefulWidget {
  final String logo;
  final String name;
  final String fundName;
  final double value;

  const TradingCard({
    Key? key,
    required this.logo,
    required this.name,
    required this.fundName,
    required this.value,
  }) : super(key: key);

  @override
  _TradingCardState createState() => _TradingCardState();
}

class _TradingCardState extends State<TradingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant TradingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    // Normalize value for animation (map percentage to 0.0-1.0 range)
    // Cap the value at ±100% to prevent animation overflow
    double normalizedValue = (widget.value.abs() / 100).clamp(0.0, 1.0);
    _animation = Tween<double>(
      begin: 0,
      end: normalizedValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _truncateText(String text, {int maxWords = 4}) {
    // Normalize non-breaking or narrow spaces to regular space
    final normalized = text.replaceAll(RegExp(r'[\u00A0\u202F]'), ' ').trim();
    final words = normalized.split(RegExp(r'\s+'));
    if (words.length <= maxWords) return normalized;
    return '${words.sublist(0, maxWords).join(' ')}...';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isPositive = widget.value >= 0;
    final Color textColor = isPositive
        ? AppColors.success ?? Colors.teal[700]!
        : AppColors.error ?? Colors.red[700]!;
    final double cardWidth = MediaQuery.of(context).size.width * 0.9; // Adjusted for responsiveness

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradingDetailsScreen(
              logo: widget.logo,
              name: widget.name,
              fundName: widget.fundName,
              value: widget.value,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isDarkMode ? 0.3 : 0.15),
              blurRadius: 6.r,
              spreadRadius: 1.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        ),
                        child: widget.logo.isNotEmpty
                            ? ClipOval(
                          child: Image.network(
                            widget.logo,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : SizedBox(
                                height: 16.w,
                                width: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.account_balance,
                              color: Colors.grey[400],
                              size: 20.sp,
                            ),
                          ),
                        )
                            : Icon(
                          Icons.account_balance,
                          color: Colors.grey[400],
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _truncateText(widget.name, maxWords: 3),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _truncateText(widget.fundName, maxWords: 4),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDarkMode ? Colors.grey[400] : Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.value.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isPositive ? 'Growth' : 'Decline',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isDarkMode ? Colors.grey[400] : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              // Progress Bar + Horse
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: cardWidth,
                    height: 6.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: _animation.value * cardWidth,
                        height: 6.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          gradient: LinearGradient(
                            colors: isPositive
                                ? [
                              AppColors.primaryGold ?? Colors.amber[700]!,
                              (AppColors.primaryGold ?? Colors.amber[700]!).withOpacity(0.8),
                            ]
                                : [
                              AppColors.error ?? Colors.red[400]!,
                              (AppColors.error ?? Colors.red[400]!).withOpacity(0.8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double horsePosition = _animation.value * cardWidth;
                      return Positioned(
                        left: (horsePosition - 20.w).clamp(0.0, cardWidth - 20.w),
                        top: -30.h,
                        child: SizedBox(
                          height: 70.h,
                          width: 90.w,
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
            ],
          ),
        ),
      ),
    );
  }
}